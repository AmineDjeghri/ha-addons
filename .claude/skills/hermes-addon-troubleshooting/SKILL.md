---
name: hermes-addon-troubleshooting
description: Diagnose a Hermes HA addon that won't restart or whose tool calls/gateway all fail.
---

# Hermes Add-on Troubleshooting

Diagnose and repair a Hermes Agent deployment running as a Home Assistant (HA) add-on — most often the "Hermes WebUI"/"Hermes Agent" addon whose dashboard, ttyd terminal, and gateway all share one container and one venv.

## Trigger Conditions
- An HA add-on (Hermes WebUI / Hermes Agent) "won't restart" or the gateway won't come back up.
- Duplicate gateway errors, lock conflicts, stale PID files.
- You need to inspect addon internals (logs, processes, config, nginx routes) that HA entities can't show.
- Before editing anything, the user asks for a read-only diagnosis.

## Two Access Paths to HA (know which one you're using)
The agent has TWO ways to reach a Hermes HA addon — pick the right one:

1. **HA entity/API layer** (`ha_list_entities`, `ha_get_state`, `ha_call_service`). Shows devices/sensors/services ONLY. It cannot see addon internals, processes, or logs.
2. **Shell inside the shared container** (`terminal`, `read_file`, `search_files`, `write_file`). If you are running as the Hermes addon's gateway, you share the container and venv with the WebUI/dashboard. You have root shell on that exact host — THIS is how you inspect addon internals.

**Key insight:** when the user says "inspect the addon," use the shell, not the entity tools. Confirm which addon you're in via `/data/options.json` (`git_url`, `hermes_home`, `enable_dashboard`, etc.). The entity layer is only for confirming HA connectivity.

## Diagnostic Workflow (read-only)
1. **Map the processes** — `ps aux | grep -iE "hermes|webui|uvicorn|nginx|ttyd"` and `ps -o pid,ppid,stat,etime,cmd -p <pid>`.
   - Typical layout: `nginx` (front), `web_server` = the WebUI/dashboard (`hermes_cli.web_server ... start_server(port=...)`), and `gateway` (`hermes_cli.main gateway run`). A `tmux ... start-hermes` session runs the interactive TUI launcher.
2. **Read the addon config** — `cat /data/options.json` (per-addon, in container).
3. **Read the logs** in `/config/.hermes/logs/` (or `$HERMES_HOME/logs`): `gateway.log`, `errors.log`, `gateway-exit-diag.log`, `gateway-restart.log`, `update.log`. Note log rotation — check total line count (`wc -l`) before trusting that recent entries = the whole story.
4. **Check lock/pid state** — `cat $HERMES_HOME/gateway.pid`, `ls $HERMES_HOME/*.lock`. The pid file records the live gateway's pid, argv, and start_time.
5. **Test responsiveness** — `curl -sS -o /dev/null -w "%{http_code}" http://127.0.0.1:<port>/` both directly and through nginx; inspect `nginx -T` to map routes (`/dashboard/`, `/hermes/`, `/v1/`) to upstreams.
6. **Trace the error to source** — `grep -rn "<error string>" $HERMES_HOME/hermes-agent/` to find the guard that produced it, then read around it. Don't guess at the mechanism.

## The "Addon won't restart" deadlock (most common failure)
Symptom: `gateway.log` is flooded with:
```
✗ Another gateway instance is already running (PID <X>).
  Use 'hermes gateway restart' to replace it,
  or 'hermes gateway stop' first.
  Or use 'hermes gateway run --replace' to auto-replace.
```
Root cause: **two gateway lifecycle managers fighting.** The dashboard/WebUI spawns a *managed* gateway via bare `hermes gateway run`, but a **detached gateway** (started earlier with `--replace` from a different launcher, reparented to PID 1 so the dashboard no longer owns it) already holds the lock. The dashboard cannot stop or replace a process it doesn't own, so every restart attempt fails.
- The guard is `_guard_existing_gateway_process_conflict()` in `hermes_cli/gateway.py` (printed at exit code 1 when not `--replace`).
- Fix direction (confirm with user first): stop the stale detached gateway (kill the pid in `gateway.pid` or `hermes gateway stop`), and/or remove the conflicting launcher (the `start-hermes` tmux session), so the WebUI can cleanly own and restart the gateway. Use `--replace` where a takeover is intended.
- Related: the dashboard's restart endpoint `POST /api/gateway/restart` spawns `hermes gateway restart` and dedupes concurrent restarts (`_spawn_gateway_restart`), so double-clicks aren't the cause — the stale-lock holder is.

## WebUI fails at boot: hermes-agent wheel build refused (second root cause)
Symptom: the addon's WebUI terminal shows an install failing with:
```
× Failed to build `hermes-agent @ file:///tmp/hermes-agent-build`
  ╰─▶ RuntimeError: Building wheels or sdists for hermes-agent is not supported.
      If you are developing, use an editable install instead:
        uv sync          # or: uv pip install -e .
!! ERROR: Failed to install hermes-agent's requirements
!! Exiting script (ID: 1)
```
Root cause: **Hermes cannot be installed as a non-editable (wheel) build from source — it must be installed editable, or from a PyPI/Docker/Nix release.** The upstream WebUI init script (`docker_init.bash`, shipped in the base image) runs a bare `uv pip install "$_stage_src[all]"` on a staged copy of the agent source (`/tmp/hermes-agent-build`). That non-editable install triggers the wheel build → Hermes refuses → init exits 1 → WebUI never starts. It fires on every boot because the addon's `run.sh` symlinks the agent source into the path the init checks (`/home/hermeswebui/.hermes/hermes-agent`), and `requirements.txt` does NOT ship `hermes-agent` (so the source install is required, not skippable).

Fix: make the install **editable** and keep the staged source (an editable install points at the source dir, so `rm -rf`ing it breaks the `.pth`):
```bash
uv pip install -e "$_stage_src[all]" ...   # add -e
# and DON'T `rm -rf "$_stage_src"` afterwards
```
Because the init script lives in the **base image**, not the addon's own repo, patch it at boot from the addon's `run.sh` with a `sed -i` on `/hermeswebui_init.bash` before `exec` (or rebuild the base image). In the shared-venv HA addon, `/app` and `/tmp` are both ephemeral and rebuilt in sync each start, so an editable install pointing into `/tmp` is safe.

### Locating a failing script that isn't in the addon repo
When the failing install/init script is absent from the addon's own repo, it comes from the **upstream base image**. Read `build.json` → `build_from` (e.g. `ghcr.io/nesquena/hermes-webui:0.52.106`), then clone the upstream repo and read `docker_init.bash` — that's the file `run.sh` execs as `/hermeswebui_init.bash`. Don't guess at the mechanism; read the exact install line and patch it.

### Choosing the fix: Tier 1 / Tier 2 / Tier 3
When the WebUI won't boot because of the wheel-build refusal, three escalating fixes exist. Prefer the higher tier that fits the user's appetite — don't default to the quickest patch:
- **Tier 1 — Editable install (unblock only).** Add `-e` to the init's `uv pip install "$_stage_src[all]"` and don't `rm -rf` the staged source. Fast, but still re-installs hermes from the shared source every boot and stays coupled to it. Fine to unblock while a better fix lands.
- **Tier 2 — Install hermes-agent from PyPI (RECOMMENDED default).** Replace the install with `uv pip install "hermes-agent[all]"` (drop `$_stage_src`). Decouples the WebUI from the agent's source tree — no build, no drift from the local checkout. Still shares `.hermes` **data** + workspace exactly as before. One-line `sed` in `run.sh`. This is the fix the user chose for this addon.
- **Tier 3 — WebUI as a pure frontend over the Agent's HTTP API (endgame).** Remove the WebUI's hermes-agent install entirely; enable the Agent addon's API server (`API_SERVER_ENABLED`, `API_SERVER_KEY` in `.env`; nginx already proxies `/v1/` → `hermes_api_0`), and make the WebUI a static client over that API (WebSockets for streaming). One hermes install = one source of truth, zero build fragility. **Major work**: upstream `nesquena/hermes-webui` imports `AIAgent` in-process and has no API-client mode, so it needs a fork or upstream feature. Fits a modular-monolith preference but is a multi-week project.

Rule of thumb: **Tier 2 is the effort/robustness sweet spot.** Mention Tier 3 only if the user is planning a redesign.

### The "shared venv" misconception (two containers, not one)
Users often believe both addons share *the same venv/code*. They do **not**: the Hermes Agent addon and the Hermes WebUI addon are separate containers with separate venvs and separate filesystems. What's genuinely shared is **data**, and that's the correct part of the design:
- `.hermes` data (sessions, memory, skills, config, API keys) via `HERMES_HOME` pointing at the agent's addon-config dir.
- Workspace, `.config`, `.local`, `.gitconfig` via symlinks into the agent's dir.

Code/venv should NOT be "shared" by rebuilding hermes from the shared source into a second venv every boot — that's the fragile coupling that keeps breaking. Real cross-container venv sharing isn't practical (venvs aren't portable across filesystems/users). Share data; install code independently (PyPI) or, best, make one container the sole owner of hermes (Tier 3).

### Why the `hermes` CLI is broken in the WebUI container (mount-path duality)
Symptom: `hermes` in the WebUI container fails with `exec: .../venv/bin/python3: not found`, while Telegram and the WebUI keep working.
Root cause: the **shared** venv `<HERMES_HOME>/hermes-agent/venv` was created by the AGENT addon and its absolute symlinks are baked for the agent container's mount namespace:
- `readlink venv/bin/python3.11` → `/config/.hermes/hermes-agent/.hermes-runtime/python/generation-*/cpython-3.11-linux-x86_64-gnu/bin/python3.11`
- `cat venv/pyvenv.cfg` → `home = /config/.hermes/...` (uv-managed runtime, CPython 3.11, `relocatable = true`)
The agent addon (WolframRavenwolf/hermes-ha-addon) mounts its private addon-config dir at `/config` (per its README: "`~` is `/config` ... the add-on's private `addon_config` mount, not HA Core `/config`"), so `/config/.hermes` == `/addon_configs/<slug>_hermes_agent/.hermes` on the host. The WebUI container mounts that same dir at `/addon_configs/<slug>_hermes_agent/.hermes` only — `/config/.hermes` does NOT exist there, so the chain dangles. The shared venv is therefore agent-only **by construction**; the WebUI runs its own `/app/venv` (CPython 3.12, `hermes-agent[all]` from PyPI, `.deps_installed` fast-restart marker). This deployment has since drifted: shared-log tracebacks show the WebUI process running the SHARED checkout (editable) under a NEWER uv CPython (3.14.7, runtime cache under the shared `~/.local/share/uv/python/`). The traceback's code + interpreter paths, never assumptions, tell which install a failing process runs — see the 3.14 section below and `references/python-version-stdlib-drift.md`. Run `hermes` CLI commands from the AGENT addon's terminal — or build a disposable venv OUTSIDE the shared checkout (ask first, see Pitfalls). Full verified detail: `references/venv-mount-diagnosis.md`.

## Nothing loads from `config.yaml` skill paths (container-vs-host path split)
Symptom: `skills.external_dirs` / `skills.trusted_project_dirs` are set in `config.yaml` yet **zero** skills from those dirs appear — no warning anywhere, and `hermes config check` does not validate skill dirs.
Cause: those entries are written the way the **host** names the directory (`/addon_configs/<slug>_hermes_agent/…`, renamed `/app_configs/…` in current HA releases). **Neither name exists inside the agent container** — there the same directory is mounted at `/config` (= `$HOME`), so both entries resolve to nothing and Hermes silently skips them.
Rule: always write **container-native** paths — `/config/.claude/skills` (deployed shared skills) and `/config/workspace/<repo>` (repo-local skills). The WebUI container is unaffected: its `run.sh` symlinks `/config` → the agent's dir on every boot precisely so `/config/…`-based paths resolve identically in both containers.
Diagnose read-only: `ls -d /addon_configs /app_configs` (both missing ⇒ the entries cannot resolve); `hermes skills list --source all` (header counts + a grep for the expected names; project-scoped skills are deliberately NOT listed); `hermes skills inspect <name>` (fails `No skill named '<x>' found in any source` when nothing resolves, but does resolve project skills by name once in scope); `hermes skills trust [path]` is what writes `trusted_project_dirs`. Verified detail: `references/venv-mount-diagnosis.md`.

## All tool calls fail: `'DaemonThreadPoolExecutor' object has no attribute '_initializer'`
Symptom: every model tool (`web_search`, `terminal`, `execute_code`, `search_files`, ...) returns the SAME AttributeError in ~0s while the agent chat itself works; the crash repeats after every restart. It is NOT transient executor state — "restart the addon" fixes nothing.

Root cause: the failing process runs Hermes under **CPython >= 3.14**. `tools/daemon_pool.py` `DaemonThreadPoolExecutor._adjust_thread_count()` is a hand-port of CPython 3.8–3.13 stdlib internals (its own comment says so) and reads `self._initializer`/`self._initargs`; CPython 3.14 refactored `ThreadPoolExecutor` — those attributes no longer exist (workers spawn via `_create_worker_context()`, `_worker(ref, ctx, queue)`), so the first `submit()` needing a new worker raises AttributeError. Every tool executes through this daemon pool (`agent/tool_executor.py`), hence total uniformity. Typical split: the agent addon is fine (its venv pins an older uv CPython) while a WebUI venv rebuilt by a newer uv resolved CPython 3.14.7 — same checkout, one surface dead, one alive. Both write to the SAME `$HERMES_HOME/logs`, so errors.log carries the other container's traces; attribute by session source.

Verify which interpreter crashed from the traceback in `$HERMES_HOME/logs/errors.log`: the stdlib frame path names the interpreter AND the uv layout — `.../.local/share/uv/python/cpython-3.14.7-.../lib/python3.14/...` = new uv layout (>= 3.14, the crasher); `.../.hermes-runtime/python/generation-*/cpython-3.11...` = the agent's pinned older runtime. Compare with `readlink -f <venv>/bin/python3`.

Fix ladder (confirm with user first): pin/rebuild the affected venv onto the same CPython the agent's venv uses (Hermes's stdlib-internals mirrors are validated 3.11–3.13); or version-gate `_adjust_thread_count` in the shared checkout to mirror the 3.14 spawn (3.14 stdlib still registers `_threads_queues` and uses non-daemon threads, so the override must keep `daemon=True` + no registration) — a checkout edit agent updates will stomp unless added to the patch set; or upstream PR. Before promising "an update fixes it", fetch upstream `main`'s `tools/daemon_pool.py` — it can still carry the identical 3.8–3.13 mirror. Full recipe: `references/python-version-stdlib-drift.md`.

## Routine health check ("/doctor" pass) — when the system is UP
Triggered by `/doctor` in the WebUI or "is everything OK?". Note: `/doctor` is a CLI command (`hermes doctor`), NOT an in-session slash command — in the WebUI it arrives as a chat message meaning "run the health check". The CLI venv is broken in the WebUI container, so run the pass manually with NATIVE read tools (see Pitfalls re: the approval gate):

1. **Gateway health** — read `$HERMES_HOME/gateway_state.json`: `pid`, `gateway_state`, per-platform `state`/`error_code`/`updated_at`. Telegram + `homeassistant` should be `connected`; `api_server` often `disconnected` (no active key) = benign. Cross-check `gateway.pid`, and count `gateway-starts.log` lines (epoch timestamps, one per start — a handful over days with a recent last stamp = healthy; many recent = crash loop).
2. **Config sanity** — `read_file` `$HERMES_HOME/config.yaml`; if it parses/reads cleanly and the live gateway is running, it's valid. Note model/provider, fallback_providers, compression, `approvals` mode.
3. **Network** — `curl -s -o /dev/null -w "%{http_code}"` provider roots: HTTP 401 from an API root = reachable (key is checked separately by the provider tooling); 200 = reachable.
4. **Log scan** — `search_files` for `CRITICAL|FATAL|Traceback` in `logs/errors.log` (0 hits = clean), then scan `logs/gateway.log` WARNINGs for known signatures (below).
5. **Cron/kanban** — `cronjob action=list` (0 jobs is normal for this setup); kanban status from config `kanban.dispatch_in_gateway` + `kanban.db` presence.
6. **Disk/log hygiene** — `df -h`; check `gateway-exit-diag.log` size (observed at 42 MB — rotate it) and rotated `gateway.log.N`.

### Diagnostic signatures (gateway.log / errors.log)
- `Auxiliary: marking <provider> unhealthy for 60s (payment / credit error)` — the aux/fallback chain (here OpenRouter → Nous Portal) is OUT OF CREDITS. Main provider unaffected; aux work (compression summaries, etc.) is skipped until it recovers. Fix: top up credits or trim the aux chain.
- `Refusing background curator patch for ...` — benign curator guard, not an error.
- WARNING `agent.tool_executor: Tool ... returned error` — usually the session's own tool hiccups; look for a repeated pattern, not one-off lines.

## Dashboard says "gateway is not running" but the gateway IS running (liveness false negative)
Symptom: the dashboard Channels tab renders *"The gateway is not running… restart the gateway to connect this platform"* (and a red `TELEGRAM: GATEWAY IS NOT RUNNING` banner) while Telegram chat works fine and `gateway_state.json` says `"gateway_state": "running"`, `telegram: connected`.

Root cause: the dashboard's liveness ladder (`resolve_gateway_liveness` in `gateway/status.py`) fails CLOSED on launcher-managed (s6/addon) gateways — all three rungs can miss:
1. **PID file rung** — reads `$HERMES_HOME/gateway.pid`; launcher-managed gateways write only `gateway_state.json`, so `gateway.pid`/`gateway.lock` don't exist → rung fails.
2. **HTTP health rung** — runs only when `GATEWAY_HEALTH_URL` is set (dashboard env); unset in addon deployments → skipped.
3. **Runtime-status PID rung** — reads `gateway_state.json` (pid alive, state running) then validates the live command line with `_gateway_command_subcommand()`: it recognizes `hermes gateway run` (basename `hermes`), `hermes-gateway`, `gateway/run.py` — but NOT `hermes-gateway-launcher.py gateway run` (`has_gateway_entry` → False) → rung fails.

Result: all rungs return "down" → dashboard lies. Gateway is fine; pure false negative.
Fix directions (confirm with user first): set `GATEWAY_HEALTH_URL` (e.g. `http://localhost:8642`) in the dashboard/webui env so rung 2 confirms liveness via HTTP; or upstream fix — teach `_gateway_command_subcommand` to recognize `hermes-gateway-launcher.py`; or ignore (cosmetic — everything works).
Full verified detail + code paths: `references/gateway-liveness-false-negative.md`.

## Update-time failures: npm workspace OOM (exit 137)
Symptom: `hermes update` (agent addon) prints `⚠ npm workspace install failed` / `⚠ Web UI npm install failed (hermes web will not be available)` / `⚠ Update partially complete`, with `npm error code 137` on `sh -c tsc -b && vite build` (web workspace).

**137 = SIGKILL = OOM-kill** — the web build peaks ~1.5–2 GB. Check BOTH scopes before touching anything:
1. `cat /sys/fs/cgroup/memory.max` → `max` = NO container limit ⇒ **raising the addon's `mem_limit` is useless** (verified — don't edit the addon config on this evidence).
2. `free -m` → host starved (observed: 4 GB total, ~3.5 GB used, swap full) ⇒ host-level OOM, structural (HA Core + 2 addons ≈ 2.5–3 GB baseline), not a leak.

Fixes: add host/VM RAM (durable — HAOS on KVM, see `references/haos-on-kvm-notes.md`); or bound the heap: `NODE_OPTIONS="--max-old-space-size=1024" hermes update` (inherited by npm/tsc/vite); or accept the stale dashboard (it keeps serving the last good `web_dist`).

Key mechanics (from `hermes_cli/update_cmd.py`): the npm refresh installs root (`--workspaces=false`) then `--workspace ui-tui --workspace web` (desktop excluded); the lockfile hash is recorded only on SUCCESS and `_build_web_ui` skips when `web_dist` is fresh ⇒ **one fully-successful update makes later updates skip npm + build**. Partial updates still exit 0 — verify with `stat -c '%y' hermes_cli/web_dist/index.html`, never trust the exit code.

Two dashboards: the WebUI container serves its PyPI wheel's pre-built `web_dist` (release-CI build, zero local npm → always works); the agent container serves the checkout's `web_dist` (needs the local build → OOMs on starved hosts). Compare `index-<hash>.js` in each `web_dist/index.html` to tell which build a surface serves. Agent addon nginx surfaces: `/hermes/`, `/dashboard/`, `/terminal/`, `/v1/`.

Updates run via Telegram in this deployment: the gateway relays prompts (`Forwarded update prompt to agent:main:telegram:dm:...`) and applies replies (`Telegram update prompt answered 'y'`). The `Restore local changes now?` prompt is the normal autostash flow — user answers **y**, the HA patches re-apply; the leftover `hermes-update-autostash` stash is STALE → drop it, never restore it later. Full detail: `references/hermes-update-oom-npm-build.md`.

## Pitfalls
- **Logs rotate** — a short `gateway.log` full of one error may mean it was recently cleared; don't conclude "rare" from a small file. Grep for first/last occurrence and count.
- **A repo venv created outside the container is dead inside it — recreate it, don't debug it.** Symptom: `pre-commit`/`pytest` "not found" (or a `#!/addon_configs/...` shebang pointing nowhere) while the files exist, so every commit gets forced onto `--no-verify`. Cause: the venv was built where the *host-side* path resolved, baking that path into the script shebangs and `pyvenv.cfg`. Fix (verified): `rm -rf venv && make install-dev` **from inside the container** → uv creates `.venv` with container-valid shebangs; prove it with `pre-commit run --all-files` (every hook must Pass). Then check `git status`: the sync can also correct a stale lockfile entry (a `uv.lock` diff limited to the project's own `version =` line is a legitimate sync, not dependency drift) — surface that to the user instead of leaving unexplained dirt.
- **Before changing a user's published repo, explain in plain language what you're about to do.** The user owns the addon repo and must approve the change; technical shorthand (sed/editable-install/.pth mechanics) confuses and stalls the fix. State plainly: what's broken, the one-line fix, which file it touches, and ask before pushing. "What do you want to do exactly?" is the signal you over-explained in jargon. When you open the PR for that change, keep the body to ~1-2 lines and drop internal labels (e.g. "Tier 2") — this user asked to trim a verbose PR body and strip such jargon.
- **Hermes is never wheel-built from source** — any install script doing `uv pip install <src>` without `-e` will hit "Building wheels ... not supported". Reach for an editable install or a release artifact, not a `setup.py build`/wheel workaround. TESTED Aug 2026: upstream `docker_init.bash` staging (writable copy + `chmod -R u+w`, present since v0.52.106) does NOT change this — the refusal is a deliberate RuntimeError in hermes-agent's build config, not a filesystem/EROFS issue; the repo's PyPI `sed` (Tier 2) is the validated permanent fix. To re-test any install hypothesis safely: stage the checkout with rsync + `chmod -R u+w` into a throwaway `/tmp` venv — never the live `/app/venv`.
- **The venv you see may not be the addon's venv.** `update.log` may reference `/app/venv` (python 3.12.13) while your session runs `/config/.hermes/hermes-agent/venv` (python 3.11.x). There can be two Hermes installs; verify which one the *gateway* actually runs from (`ps` argv) before editing.
- **Updates are externally managed in addon envs** — `hermes-update.log` may say "updates are managed outside this dashboard in containerized environments." The WebUI's built-in updater/restarter is disabled; restarts come from the addon's supervisor, not the dashboard.
- **Don't edit during a diagnostic pass** unless asked — the user may explicitly want read-only inspection first.
- **NEVER auto-proceed after a `clarify` timeout — timeout ≠ consent.** This user's explicit hard rule: any system-modifying action (installs, venv creation, edits to config/repo/addon files, container changes, pushes, cron) requires their explicit confirmation **in the conversation**. When a question times out, STOP: do nothing, report the exact state, and list the precise commands you will run on their word. Picking "best judgement" and executing the most invasive option is exactly what put this user's WebUI at risk once — do not repeat it. This overrides any "use your best judgement" instruction in the timeout notice.
- **The shared checkout `.hermes/hermes-agent/` is off-limits for writes without explicit approval.** No `uv venv`, no `pip install -e`, no package builds there. Reasons: (a) the user forbids it — the WebUI installs `hermes-agent[all]` from PyPI and editable installs in the shared tree are rejected; (b) the WebUI boot rsync-stages the whole tree to `/tmp` on fresh-image boots and does NOT exclude extra venv dirs (a `venv-cli/` cost ~128 MB of copied litter per boot); (c) an `hermes_agent.egg-info` left by an editable build pollutes the tree the agent's own editable install builds from. If a working CLI is needed in the WebUI container, propose a venv OUTSIDE the checkout and get approval first.
- **Verify ownership before blaming git dirt** — in this deployment `web/src/lib/api.ts` and `web/vite.config.ts` are intentionally patched (markers `HA-ADDON-BASE-INJECTED`, `HA-ADDON-IMPORT-META-FALLBACK-PATCHED`); check `stat` mtimes / diff content before assuming your own action modified tracked files. A third patch, `hermes_cli/dashboard_auth/prefix.py` (64→256 prefix limit, marker `HA-ADDON-PREFIX-LIMIT-PATCHED`), is now OBSOLETE — upstream merged it (`ef79ad014d fix(dashboard): accept HA ingress prefix paths`; `_MAX_PREFIX_LENGTH = 256`), so it correctly does NOT re-apply after updates; don't restore it from an old stash.
- **"Clone latest main" means clone fresh** — existing local clones may carry unpushed commits (observed: `ha-addons` at `440f703` had a local bump commit while origin main was `f2c5321`). Never build a branch on a stale/divergent local clone; clone into a new dir and branch from the fetched origin.
- **Manual approval gate blocks terminal AND execute_code** (approvals=manual here): compound read-only shell commands and `execute_code` scripts hang on the consent prompt and come back `BLOCKED: ... Silence is not consent` if unanswered. For read-only diagnostic passes use native tools (`read_file`, `search_files`, `cronjob`, `session_search`) — they need no consent. When a command gets BLOCKED, do NOT retry it or an equivalent (the block message forbids it); pivot to native read tools. Also note `search_files` refuses `.env` (credential-store guard, by design) — don't inventory keys that way. Approval here is inconsistent: plain shell probes (ls/grep/cd/readlink/for-loops) usually pass, but script-like invocations (heredoc `python3 - <<'EOF'`, multi-statement `python3 -c`) hang and come back BLOCKED — to inspect stdlib/source internals (e.g. CPython `thread.py` signatures) use `read_file`, not python one-liners.
- **`/doctor` in the WebUI is a health-check request, not a slash command** — map it to the manual pass above when the CLI venv is broken (see `references/health-check-pass.md`).
- **`hermes update` can exit 0 while the web UI is NOT rebuilt** — "Update partially complete" still reports exit 0 (gateway.log `Update finished (exit=0)`). Verify with `stat -c '%y' hermes_cli/web_dist/index.html` — a stale mtime after an update means the build silently failed (npm workspace OOM).
- **The leftover `hermes-update-autostash` stash is STALE** — after an update restored the patches, the stash entry may remain (apply-style restore). Do NOT restore it at the next update prompt: its base is pre-update code and its prefix.py hunk is obsolete. Confirm the working-tree patches are in place, then `git stash drop`.
- **Supervisor API returns 403 from addon containers without `supervisor_api: true`** — the WebUI addon gets `403 Forbidden` on `http://supervisor/addons` even with a valid `SUPERVISOR_TOKEN` (the token alone is not enough; the addon config must grant the permission). Per-addon RAM/CPU stats are NOT readable from there; use `docker stats` on the HAOS host, or `ps aux --sort=-rss` in the agent addon's Terminal.
- **`hermes doctor` / `hermes update` on a PyPI install: two benign false alarms** — doctor flags "Venv entry point not found ... reinstall with pip install -e '.[all]'" (benign: the CLI lives at /app/venv/bin/hermes via run.sh; do NOT run the suggested editable install — forbidden in the shared checkout); `hermes update --check` says "pip installs are no longer an officially supported platform and will not receive further updates" → a pip install only changes via addon rebuild, never via the built-in updater.
- **`hermes --version`'s `upstream <sha>` is NOT the install's provenance** — that line is read from the SHARED checkout's git HEAD at runtime: the webui wheel (v0.19.0, unchanged) showed `upstream f5be9236` then `upstream b3e45a3d` purely because the AGENT updated the checkout. The real code version is `vX.Y.Z (date)` + `Install directory` (`pip show hermes-agent` for the wheel). Related dual-versioning gotcha: the WebUI addon carries TWO versions — the nesquena webui app (config.yaml `version:` = pinned upstream release; exact baked badge in `/app/api/_version.py`, e.g. `v0.52.106`; `/app` is a snapshot copy with no .git, dated by file mtimes) and the hermes CLI in `/app/venv` (PyPI, frozen — `pip index versions hermes-agent` → LATEST 0.19.0, so rebuilding the webui addon changes the APP version but NOT the CLI version). Say which one you mean before claiming "up to date".

## Verification
- [ ] Identified which addon container you're in (`/data/options.json`).
- [ ] Mapped nginx → web_server → gateway process chain.
- [ ] Read the relevant log(s) and grepped the error to its source guard.
- [ ] Reported the access path used (shell, not entities) and the deadlock if present.

## Linked Files
- `references/gateway-liveness-false-negative.md` — dashboard "gateway is not running" false negative: the 3-rung liveness ladder in `gateway/status.py`, why launcher-managed (s6/addon) gateways fail all rungs, GATEWAY_HEALTH_URL fix, upstream matcher gap.
- `references/hermes-webui-restart-deadlock.md` — full case study: process tree, log evidence, lock files, and the source guard, from a real "WebUI won't restart" diagnosis.
- `references/hermes-webui-build-refused.md` — the SECOND root cause (gateway lock is clean but WebUI still won't start): upstream `docker_init.bash` non-editable `uv pip install` of the agent source → Hermes wheel-build refusal → editable-install fix + base-image init script location.
- `references/hermes-webui-two-container-architecture.md` — the two-container data-vs-venv sharing model, the Tier-1/2/3 fix ladder, and the exact Tier-2 PyPI `sed` applied to this addon.
- `references/health-check-pass.md` — the manual `/doctor` recipe for a HEALTHY stack: exact health files (gateway_state.json, gateway-starts.log), aux-chain credit-error signature, the approval-gate behavior, and a working report shape.
- `references/venv-mount-diagnosis.md` — verified venv/mount architecture of the two-container deployment: `pyvenv.cfg` + symlink-chain proof of why the shared CLI venv is agent-only, per-container Python/venv comparison (agent editable + uv runtime vs WebUI `/app/venv` PyPI + `.deps_installed`), boot mechanics (run.sh → init staging/rsync excludes), host-paths/mounts table incl. the `addon_configs` → `app_configs` rename and why `config.yaml` must use `/config/…` paths, the dead-venv symptom + recreate recipe, and the source-verification recipe for claim-checking Hermes features.
- `references/python-version-stdlib-drift.md` — all-tools-fail `_initializer` AttributeError: CPython 3.14's ThreadPoolExecutor refactor vs Hermes `daemon_pool.py`'s 3.8–3.13 mirror, how to name the crashing interpreter from the traceback (uv layouts), the 3.14-compatible override requirements, and the fix ladder incl. the upstream-`main` check.
- `references/hermes-update-oom-npm-build.md` — npm workspace OOM (exit 137) during `hermes update` on memory-starved hosts: cgroup-vs-host diagnosis, `NODE_OPTIONS` band-aid, one-success-skips-future-builds mechanics, two-dashboards (PyPI vs checkout web_dist), Telegram-relayed update prompts, real afternoon timeline.
- `references/haos-on-kvm-notes.md` — HAOS-on-KVM host admin: virsh session-vs-system connection (empty list without sudo), libvirt group fix, VM RAM resize commands and the sizing rule for an 8 GB dedicated host.
