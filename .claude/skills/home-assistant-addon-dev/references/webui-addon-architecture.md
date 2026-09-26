# Hermes Agent + WebUI two-addon architecture (HA)

Verified against the live install and the ha-addons repo (Aug 2026). Use for any work on
`addons/hermes-webui` in ha-addons, or for diagnosing the agent↔webui pairing.

## Two containers, one shared directory

- **Agent addon** (WolframRavenwolf/hermes-ha-addon): `~` = `/config` = its private
  `addon_configs/<slug>_hermes_agent/` mount (NOT HA Core `/config`). HERMES_HOME = `/config/.hermes`.
- **WebUI addon** (ha-addons/addons/hermes-webui): `map: all_addon_configs:rw` (`config:rw` was dropped — see the Read-only HA access section); auto-discovers
  HERMES_HOME at `/addon_configs/*_hermes_agent/.hermes`; image is built FROM
  `ghcr.io/nesquena/hermes-webui:<tag>` + a `run.sh` wrapper (bashio).
- Consequence: the SAME host dir `/addon_configs/<slug>_hermes_agent/` appears at
  `/config/.hermes` (agent container) and `/addon_configs/<slug>/.hermes` (webui container).
  Since Sep 2026 the webui's `run.sh` ALSO symlinks `/config` → the agent addon-config dir at
  boot (shared mode only, guarded `[ ! -e /config ]` — see boot mechanics), so `/config`-based
  shared paths — `skills.external_dirs`, uv-tool shim shebangs (`/config/.local/share/uv/...`),
  the claude binary — resolve identically in BOTH containers. Before that fix, every stored
  `/config/...` path in shared config/symlinks dangled in the webui (symptom: `/root/.local/bin/<tool>`
  shims failing with "required file not found" = a dead `/config` shebang, not a broken install).
  There are no bind mounts between the containers themselves.

## Venv handling (the confusing part)

| | Agent addon | WebUI addon |
|---|---|---|
| Python | CPython 3.11, uv-managed in `.hermes/hermes-agent/.hermes-runtime/python/generation-*/` (inside the shared checkout) | CPython 3.12 from the image |
| Venv | `.hermes/hermes-agent/venv/` — shared on disk, **editable** install (agent modifies its own code) | `/app/venv/` — container-local, disposable, recreated on image re-init |
| Deps | editable from the shared git checkout | `hermes-agent[all]` **editable from the shared git checkout** (PyPI fallback in isolated mode; PR `fix/hermes-webui-editable-install`, Aug 2026) + `requirements.txt` + `hindsight-client`; `.deps_installed` marker skips install on fast restarts |

- The shared venv's `bin/python3.11` symlink is **absolute** → `/config/.hermes/.../.hermes-runtime/...`,
  which only resolved in the agent container before the webui's run.sh gained the `/config`
  symlink (Sep 2026). Regardless, treat the SHARED `hermes` CLI as not usable in the webui
  container — **the webui has its own working CLI**: `/app/venv/bin/hermes` (PyPI `hermes-agent` — NOT the
  same version as the checkout: the wheel is frozen at 0.19.0 while the agent checkout runs 0.20+;
  check both sides with `hermes --version`). It is simply not on PATH: fresh shells (docker exec,
  the webui's terminal surface) get `hermes: command not found` — use the full path
  `/app/venv/bin/hermes --version` or `export PATH="/app/venv/bin:$PATH"` in the session.
  User-approved fix (approach A): bake the export into `run.sh` — zero install, self-healing via
  the `.deps_installed` re-init. Note: `hermes --version`'s `upstream <sha>` line reads the SHARED
  checkout's git HEAD, not the wheel — don't mistake it for code alignment. Rejected alternatives:
  (B) dedicated venv with `uv venv --relocatable` (uv 0.12 DOES support it) + `uv pip install "hermes-agent[all]"` — works but duplicates ~300-800 MB and bloats HA backups if placed in `addon_configs`; (C) repairing the shared venv's symlinks to relative — risky, touches the gateway's live venv. Telegram and WebUI keep working regardless: they are served by the gateway (agent container) and the webui's own `/app/venv`.

## Update semantics (`/update`, `hermes update`)

- `hermes update` (agent container) = **git pull in the shared checkout + `uv pip install -e .[all]`**
  (editable reinstall — verified in `hermes_cli/subcommands/update.py` and `main.py`). One shared
  code checkout (both containers see it via mount/symlink) but TWO independent venvs → package
  versions can drift between agent (editable/git) and webui (PyPI at addon init).
- **Update ONLY from the agent addon.** The webui CLI is a **pip install** (`hermes --version`
  reports `Install method: pip`, dir `/app/venv/lib/python3.12/site-packages`) — it has NO git
  checkout, so `hermes update` there pulls no code. Verified Aug 2026: `hermes update --check` in
  the webui prints **"pip installs are no longer an officially supported platform and will not
  receive further updates"** + "Already up to date". A full `hermes update` on pip is therefore a
  no-op for code but still has side effects: pre-update backup (quick state snapshot + **full
  HERMES_HOME zip** — writes into the SHARED `.hermes`), an interactive config-migration prompt
  (`--yes` skips), and dependency-reinstall churn in `/app/venv` (a mid-way pip failure can leave
  it half-updated). It would NOT race the agent's gateway, but it pokes at shared state.
- Drift self-heals at the next addon update (init re-installs: PyPI historically; editable from
  the checkout per the Aug 2026 PR — the webui then follows the agent's version automatically).
- **Strategic heads-up:** pip installs are officially deprecated as an install method → approach A
  (PyPI for the webui) is on borrowed time. When PyPI publishing stops, the webui addon will need
  a wheel-bundled install or a build-time checkout (Dockerfile `git clone`/`pip install` of a
  pinned release) instead of `uv pip install hermes-agent[all]`.

## Agent-side update (the checkout's local patches & npm build)

Verified Aug 2026. `hermes update` in the agent container pulls the shared checkout, rebuilds the
dashboard (`tsc -b && vite build` in workspace `web`), refreshes `ui-tui`, then syncs skills/config.

### Local patches: HA ingress compatibility (`HA-ADDON-*` markers)
The shared checkout carries uncommitted patches, identified by `HA-ADDON-*` comments, so the
dashboard works behind the HA ingress reverse proxy:

| File | Patch (`marker`) | Why |
|---|---|---|
| `hermes_cli/dashboard_auth/prefix.py` | prefix length 64 → 256 (`HA-ADDON-PREFIX-LIMIT-PATCHED`) | ingress URLs embed a long token; the 64-char cap rejected the prefix |
| `web/src/lib/api.ts` | `HERMES_BASE_PATH` fallback via `import.meta.url` (`HA-ADDON-IMPORT-META-FALLBACK-PATCHED`) | `readBasePath()` can miss the ingress sub-path at load time |
| `web/vite.config.ts` | `base: "./"` (`HA-ADDON-BASE-INJECTED`) | built assets resolve under any ingress sub-path |

- **prefix.py patch is now OBSOLETE**: upstream merged the same fix natively (`ef79ad014d fix(dashboard): accept HA ingress prefix paths`; `_MAX_PREFIX_LENGTH = 256`). Expect it ABSENT from the working tree after an update — do NOT re-apply it.
- The two web patches reappear in the working tree after an update (re-applied by the addon's patch mechanism).

### The autostash dance
`hermes update` runs `git stash push --include-untracked -m hermes-update-autostash-*` before the
`git pull --ff-only`, then prompts: "Local changes were stashed… Restore local changes now? [Y/n]".

- Answer **y** (restore) is safe and correct — verified live Aug 2026: answered 'y' 4/4 times and each time the two web patches came back cleanly while the obsolete prefix.py hunk skipped (upstream code already has the 256 limit). The prompt is forwarded to the gateway platform (`gateway.log`: "Forwarded update prompt to agent:main:telegram:dm:<id>: Restore local changes now? [Y/n]").
- The stash entry can PERSIST after a successful restore (apply-like semantics — observed `stash@{0}` still present after 3 restores). Afterwards it is stale (base = old code; prefix.py hunk obsolete). Verify the working tree (`git status` shows exactly the two web patches), then `git stash drop`. Dropping is a git mutation in the shared checkout → user confirmation required (their hard rule).

### npm web build OOM (`npm error code 137`)
- `137` = 128+9 = SIGKILL → OOM-kill during `tsc -b && vite build` (workspace `web`). NOT a code problem. `EBADENGINE` warnings (e.g. `@icons-pack/react-simple-icons` wants node ≥24, container has v22) are harmless.
- **DIAGNOSE container-cap vs host-starvation FIRST** (agent-container shell):
  - `cat /sys/fs/cgroup/memory.max` (cgroup v2) — `max` = no cap; a number = the cap.
  - `free -m` — host total/available + swap.
  Verified live Aug 2026: cgroup = `max` but the HOST has 4GB total, ~360MB free, swap 1292/1292 FULL → the kill is **host-level**. Raising `mem_limit` on the addon is USELESS there (no cap to raise); it only helps when `memory.max` is an actual number. tsc+vite needs ~1.5-2GB peak, so on a 4GB host the build is a lottery depending on current load (3 failures in one day, success 11.5 s later on 2026-06-22).
- Update output in this case: "npm workspace install failed" / "Web UI npm install failed (hermes web will not be available)" / "Update partially complete — Node.js dependencies for ui-tui, web workspaces did not refresh." Impact is low: code + Python deps are updated; only the agent's dashboard/TUI is mixed; running dashboard processes are left untouched. The WebUI surface the user actually uses is served by the webui container from its PyPI package assets — independent of this build.
- **Two dashboards, two asset sources (verified):** webui container serves `site-packages/hermes_cli/web_dist` (assets BUILT AT RELEASE CI and shipped inside the PyPI wheel → works even with 0 free RAM; refreshed at addon re-init); agent container serves the checkout's `hermes_cli/web_dist` (built locally at update). They differ until the checkout build succeeds — compare `index-*.js` hashes (`index-urPBKRY1.js` new vs `index-BQoEq1zD.js` old) and asset mtimes. The wheel can even land on the SAME upstream commit as the checkout (`v0.19.0 → upstream b3e45a3d` = checkout HEAD after update) — two install tracks that converge.
- **Fix 1 (works now, no config change)**: from an agent-container shell, `NODE_OPTIONS="--max-old-space-size=1024" hermes update` — NODE_OPTIONS is inherited by npm/tsc/vite automatically (standard Node); drop to 768 if it still dies.
- **Fix 2**: retry at a low-load moment (host `available` > 1GB).
- **Fix 3 (fix-once, ends the pain)**: one successful workspace install + web build makes later updates skip npm entirely — `update_cmd.py` records the lockfile hash only after a successful workspace install (`_record_npm_lockfile_hash`) and `_build_web_ui` skips when `web_dist` is fresh vs sources (`_web_ui_build_needed`). So updates only keep re-trying while the build keeps failing.
- **Fix 4 (durable on KVM — what actually worked Aug 2026)**: raise the HAOS VM's RAM at the hypervisor, not the addon. `virsh shutdown haos` → `virsh setmaxmem haos 6291456 --config` + `virsh setmem haos 6291456 --config` (BOTH, same KiB value; only maxmem → boots with the old allocation, only setmem → libvirt rejects) → `virsh start haos`. Verify from any addon container: `grep MemTotal /proc/meminfo` (was 6069968 kB after the bump) + MemAvailable ~2.8GB (was ~360MB). Then `hermes update` built the web UI in ~1.4s ("✓ Web UI built"). Sizing: baseline (~3.5GB) + build peak (~1.5-2GB) → 6GB on an 8GB host leaves ~2GB for Ubuntu+KVM. Full virsh detail: `references/kvm-virsh-notes.md`.
- If `memory.max` IS a number: raising `mem_limit` in the agent addon's `config.yaml` (2g/4g) + addon update (limits apply at container creation) is the durable fix.
- The webui container has NO Node.js → the rebuild cannot be done from the webui side; it must run in the agent container (its shell, or a Telegram-triggered update).

### How agent updates actually run (Telegram-gated)
In this setup `hermes update` is triggered from Telegram (the gateway platform): the update process runs in the agent container and its interactive prompts are forwarded to the DM, answers ('y'/'n') come back the same way. The whole lifecycle (start, prompts, "Update finished (exit=N)") is in `gateway.log`; `update.log` is only written by CLI-run updates.
- **Reconstructing what happened = shared log mtimes.** `.hermes/logs/` is written by BOTH containers: `update.log` (CLI updates, full detail), `hermes-update.log`, `gateway.log` (gateway-run updates, restarts, SIGTERM/shutdown phases), `agent.log` (webui-container agent turns + tool calls), `errors.log` (warnings from both). File mtimes + tails reconstruct the day's timeline without any supervisor access.
- **npm state = file mtimes.** `node_modules` (root vs `web/` vs `ui-tui/`) and `hermes_cli/web_dist/assets/` tell whether install/build completed: root-only refresh = workspace install failed again; web_dist assets dated before the update = build never finished.
- **update flow internals** (`hermes_cli/update_cmd.py` + `main.py::_build_web_ui`): root install (`npm install --workspaces=false`) → workspace install (`--workspace ui-tui --workspace web`) → `_build_web_ui`; builds serialize via an flock on `.web_ui_build.lock` (concurrent dashboard boots serve stale dist instead of piling a second build onto the same tree).
- Supervisor-API reads from the WEBUI container return **403 Forbidden even when the user approves the call** — the webui addon lacks `supervisor_api: true` in its config, so the 403 is the real answer, not just the approval gate. Don't loop on it: the shared-file trail above answers the same questions with zero approval, and per-addon RAM needs `docker stats --no-stream` on the HAOS host or `ps aux --sort=-rss` in the addon's own terminal.

## Diagnostics in the webui container

- `hermes doctor` flags exactly ONE issue on a healthy pip install: **"Venv entry point not found
  (hermes not in venv/bin/ or .venv/bin/ — reinstall with pip install -e '.[all]')"**. False
  positive: the working CLI is `/app/venv/bin/hermes` (PyPI, on PATH via run.sh). Never run
  `hermes doctor --fix` in the webui container — it proposes the exact editable install the user
  forbade. Other doctor warnings here are expected/optional (auth providers not logged in, no
  GITHUB_TOKEN → Skills Hub at 60 req/h, missing ripgrep/Node.js, browser/homeassistant tools
  "system dependency not met" while the gateway still serves those platforms from the agent side).
- **WebUI slash commands are not intercepted:** `/hermes doctor` reached the agent as plain text
  (there is no `/doctor` in the registry anyway — `/help` is authoritative). Treat unknown slash
  commands as requests and map them to CLI equivalents: `hermes doctor`, `hermes update --check`,
  `hermes --version`.

## WebUI boot mechanics

- `run.sh`: exports bashio options; auto-discovers HERMES_HOME; symlinks
  `/home/hermeswebui/.hermes/hermes-agent` → shared checkout; `/root/.config`, `/root/.local`,
  `/root/.gitconfig` → agent's versions + XDG vars; `/config` → `$HERMES_AGENT_HOME` (shared
  mode only, `[ ! -e /config ]` guard — the same view the agent addon has, so shared
  `/config/...` paths resolve here too); workspace = `$HERMES_AGENT_HOME/workspace`
  (created, chmod 777, `HERMES_WEBUI_DEFAULT_WORKSPACE`); `WANTED_UID=0` + `whoami` spoof
  (upstream image runs UID 1024 but `/addon_configs` is root-owned 0700); rsync `/apptoo → /app`;
  exec `/hermeswebui_init.bash`.
- `init`: first boot only — install webui deps, then **stage** the agent source to
  `/tmp/hermes-agent-build` via rsync (excludes `*.egg-info`, `build`, `dist`, `__pycache__`,
  `.git`, `.playwright`; `--reflink=auto`; then `chmod -R u+w` because `rsync -a` preserves the
  `:ro` mount's mode 555), then the run.sh sed picks the agent install: PyPI
  (`uv pip install "hermes-agent[all]"`) historically, **editable from the checkout**
  (`uv pip install -e "$_agent_src[all]"`) per the Aug 2026 PR (PyPI fallback in isolated mode),
  `rm -rf` the staging, `touch /app/venv/.deps_installed`.

### Why rsync (staging)?
setuptools' `egg_info` build step writes `hermes_agent.egg-info/` INTO the source tree even
under PEP 517 build isolation. The agent source is mounted read-only from the webui
(defence-in-depth); on `:ro` that write fails with EROFS and, under `set -e`, kills startup.
Staging gives the build a writable tmpfs copy without ever writing the shared checkout.

### Why the addon installs from PyPI — and the editable escape hatch (verified Aug 2026)

The staging only fixes the EROFS/egg-info class of failure. It CANNOT make a source install
work in the webui, because hermes-agent **refuses non-editable wheel/sdist builds by design** —
its packaging raises a hard `RuntimeError` at build time:

```
RuntimeError: Building wheels or sdists for hermes-agent is not supported.
Hermes is distributed via the shell installer, Docker image, or Nix.
If you are developing, use an editable install instead: uv sync  # or: uv pip install -e .
```

That refusal is why `run.sh` carries the sed that redirects the init's install line
(`uv pip install "$_stage_src[all]"`) to `uv pip install "hermes-agent[all]"` (PyPI). The
sed is a WORKAROUND for a deliberate upstream constraint, not a workaround for a bug.

**Editable installs bypass the refusal and work** — proven end-to-end in a throwaway venv
(no checkout/venv touched): stage the checkout to `/tmp/hermes-agent-build` (rsync with the
usual excludes + `chmod -R u+w`), then
`VIRTUAL_ENV=/tmp/test-venv uv pip install -e "/tmp/hermes-agent-build[all]"` → exit 0, a
`__editable__.hermes_agent-0.20.0.pth` in the venv, and `hermes --version` reports
**v0.20.0 (2026.8.3)** — the checkout's version. The agent's own venv has the identical
mechanism (`__editable__.hermes_agent-0.20.0.pth` since day one).

**Aug 2026 PR #13 `fix/hermes-webui-editable-install`** (this repo's PR #13 —
created, open + mergeable): `run.sh` now conditionally seds the init to `uv pip install -e "$_agent_src[all]"`
(editable from the persistent checkout — NOT the deleted `/tmp` stage) when the checkout is
reachable, and keeps the PyPI fallback otherwise (isolated mode). Side notes:
- `hermes_agent.egg-info/` already exists in the shared checkout (agent's own install) and is
  gitignored — an editable install from the webui adds no dirty state.
- Two editable installs (agent + webui) pointing at one checkout = two `.pth` files, benign.
- Editable must target the PERSISTENT path; the staged copy is `rm -rf`'d after install, so an
  editable pointed at `/tmp/hermes-agent-build` breaks on the next boot.
- The staging rsync (~844MB) still runs at re-init (harmless waste; one-time per image init).
- Trade-off: the webui's venv stops being a "disposable snapshot" — it now depends on the
  shared checkout being present/valid (mitigated by the isolated-mode PyPI fallback).

### Export / backup (data vs code)

Skills/plugins/memories/sessions/config = `HERMES_HOME` (`.hermes/skills/`, `.hermes/plugins/`,
`state.db`, `config.yaml`, `.env`, `auth.json`, `SOUL.md`, `cron/`, `hooks/`) — durable and
uninstall-safe. The checkout = code + bundled-skill SOURCES only (synced copies live in
`.hermes/skills/`). Export: `hermes backup -o file.zip` (excludes the codebase) or `-q` quick
(config/state.db/.env/auth/cron); restore: `hermes import`. HAOS full backups include
`/addon_configs` → both `.hermes` and `workspace/`. Manual rsync from the Ubuntu host: exclude
`.hermes/hermes-agent` (1GB+), `.hermes/logs`, `.hermes/cache`, `audio_cache`, `image_cache`.

### Why symlinks (not bind mounts)?
HA bind mounts are static (declared in `config.yaml` `map:` at container creation). The webui
needs runtime-computed targets (auto-discovered slug; shared vs isolated mode) re-exposed at
fixed upstream paths (`/home/hermeswebui/.hermes/hermes-agent`, `$HOME/.config`, …).
`ln -sfn` is atomic, idempotent, survives reinstall, and requires no supervisor changes.

## Folder ownership (who owns what)

- **Shared, agent-owned**: `.hermes/` (all agent data: config.yaml, .env, SOUL.md, memories/,
  skills/, sessions/, logs/, cron/, state.db, auth.json, hermes-agent/), `workspace/`
  (working dir — a Hermes concept, created by webui run.sh but stored with agent data),
  `.config/`, `.local/`, `.gitconfig` (mirrored into webui via symlinks).
- **Agent-only** (HOME of the agent container): `.bashrc`, `.certs/`, `.go/`, `.linuxbrew/`,
  `.npm-global/`, `.tmux.conf`, `.hermes_profile`, `.cache/`.
- **WebUI-only**: `/data/hermes-webui` (browser state: session list, settings, model cache);
  `/app` + `/app/venv` (disposable). **Nothing in the shared addon_configs is WebUI-only.**

## ha-addons repo workflow conventions

- **Clone FRESH from origin/main** — the local workspace clone may hold unpushed commits
  (observed: local `ha-addons` had an unpushed `440f703 Bump hermes-webui …` while origin
  main was `f2c5321`). Check `git log --oneline -1` on origin vs local before reusing a clone.
- Read the repo `CONTRIBUTING.md` first: branch from `main`, PR targets `main`; branch names
  `feature/*` / `fix/*` / `docs/*`; conventional commits with **optional emoji** (`📝 docs(...)`
  or `docs(...)`); `docs` type = **no release**; the PR title becomes the squash commit message
  so it must be conventional; `personal-app` has its own CONTRIBUTING (Makefile/uv/pre-commit) —
  other addons use repo-wide rules.
- The `gh` token lacks the `workflow` scope → never include `.github/workflows/*` changes in a PR.
- git identity may be unset in the container: derive from existing commits
  (`git log -1 --format='%an <%ae>'`) and set repo-local config before committing.

## Rendering mermaid to PNG without installing anything

- kroki.io (validates syntax too): `curl -sS -X POST https://kroki.io/mermaid/png -H 'Content-Type: text/plain' --data-binary @diagram.mmd -o out.png` — PNG magic bytes `\x89PNG` + non-zero size = success.
- Note: terminal calls to external hosts hit the approval gate in this setup — expect a prompt
  and don't retry a blocked call without the user's go-ahead.
- GitHub renders mermaid natively in READMEs — the PNG is only for local review/attachments.

## Read-only HA access without mounting `/config` (logs + automations)

Verified Aug 2026. Goal: let the addons read addon logs and automation configs without any
filesystem mount of HA Core — then `map: config:rw` can be dropped or downgraded to `config:ro`.

- **Addon logs → Supervisor API.** Every addon container gets `SUPERVISOR_TOKEN`
  auto-injected (verified present in the webui container) and `supervisor` resolves as a
  hostname. Endpoints (developers.home-assistant.io/docs/api/supervisor/endpoints):
  `GET /addons` (list + state), `GET /addons/{slug}/logs`, `GET /core/logs`,
  `GET /supervisor/logs`, `GET /host/logs` — all with
  `Authorization: Bearer $SUPERVISOR_TOKEN`. The old `/api/hassio/*` proxy on HA Core
  is deprecated.
- **Automations → HA Core API (read-only).** `GET /api/states` lists `automation.*`
  entities (state, `id`, `last_triggered`, mode); full config comes from
  `GET /config/automation/config/<id>` (REST) or WebSocket `config/automation/list` /
  `config/automation/config` — no file access needed. Requires a long-lived token
  (agent addon option `homeassistant_token`; NOTE: no HASS_TOKEN in the shared .env yet).
- **`map: config:rw` is a security liability**: rw access to the whole HA Core config,
  incl. `secrets.yaml`. Downgrade to `config:ro` (keeps direct reads of `automations.yaml`
  in YAML mode) or remove once API access is wired — removal was applied in Aug 2026 (PR #12 dropped `config:rw`
  entirely, keeping only `all_addon_configs:rw`). `all_addon_configs:rw` stays REQUIRED
  (workspace writes).
- **MCP packaging**: `homeassistant-ai/ha-mcp` ("Unofficial and Awesome") talks REST+WS
  directly — reads automation/script bodies, logs, traces, config files, with
  read-only/enforcement modes and entity hiding. Restrict in Hermes via
  `mcp_servers.<name>.tools.include` allowlist; don't expose to Telegram before testing.
  The official HA `mcp_server` integration routes through Assist (entities/services only —
  no config or log reads).
- **Addon options ≠ mounts**: the Configuration tab writes `/data/options.json` (supervisor)
  → `bashio::config` → env vars in `run.sh`. Changing `map:` never breaks it.

## When addon changes take effect (map: vs run.sh)

- `config.yaml` `map:` → read by the **Supervisor at container CREATION** to build mounts.
  A plain restart reuses the same container with the same mounts; only reinstall/update
  (container re-creation) applies a `map:` change.
- `run.sh` → **baked into the image** (Dockerfile `COPY run.sh /`). A restart of the current
  image does NOT pick up repo changes; the image must be rebuilt (update/rebuild). After that
  the change applies at EVERY boot (entrypoint re-runs).
- One addon update does both (rebuild + re-create). Don't tell the user a `run.sh` change
  applies on "the next restart" without mentioning the image rebuild first.
