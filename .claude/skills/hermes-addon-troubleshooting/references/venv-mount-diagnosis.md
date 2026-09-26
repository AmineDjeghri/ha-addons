# Venv & mount-point diagnosis for the two-container Hermes HA deployment

Verified facts from a live audit (Aug 2026) of the user's deployment:
agent addon **WolframRavenwolf/hermes-ha-addon** + webui addon **ha-addons** (`addons/hermes-webui`).

## Why `hermes` CLI is broken in the WebUI container
- Shared venv: `<HERMES_HOME>/hermes-agent/venv` (HERMES_HOME = `/addon_configs/<slug>_hermes_agent/.hermes` here).
- `readlink venv/bin/python3.11` → `/config/.hermes/hermes-agent/.hermes-runtime/python/generation-1785084874-104871-262496af/cpython-3.11-linux-x86_64-gnu/bin/python3.11`
- `venv/pyvenv.cfg`: `home = /config/.hermes/hermes-agent/.hermes-runtime/python/generation-*/...`, `implementation = CPython`, `version_info = 3.11.15`, `uv = 0.11.19`, `relocatable = true`.
- The AGENT addon mounts its private addon-config dir at `/config` (README: "`~` is `/config` ... the add-on's private `addon_config` mount, not HA Core `/config`"). So `/config/.hermes` == `/addon_configs/<slug>_hermes_agent/.hermes` (host) — symlinks resolve fine there.
- The WEBUI container mounts the same dir at `/addon_configs/<slug>_hermes_agent/.hermes` only; `/config/.hermes` does not exist → chain dangles → `exec: ...venv/bin/python3: not found`.
- Telegram/WebUI unaffected: gateway runs in the agent container; the WebUI server uses its own `/app/venv`.

## How each container gets its Python (verified)
| | Agent addon | WebUI addon |
|---|---|---|
| Python | CPython 3.11, uv-managed in `.hermes-runtime/python/generation-*/` (inside shared checkout; `runtime-repair.lock` present) | CPython 3.12 from the image |
| venv | `.hermes/hermes-agent/venv/` on shared disk, **editable install** (self-modifiable source, per agent addon README) | `/app/venv/` container-local, disposable |
| install | editable from the git checkout | `uv pip install "hermes-agent[all]"` **from PyPI** (init script ~line 469) + webui `requirements.txt` + `hindsight-client>=0.4.22` |
| fast restart | n/a | `/app/venv/.deps_installed` marker skips the whole install+staging block on later boots |

## WebUI boot mechanics (run.sh → /hermeswebui_init.bash)
- run.sh: auto-discover HERMES_HOME (`find /addon_configs -maxdepth 2 -type d -name ".hermes" | grep _hermes_agent`); symlink `/home/hermeswebui/.hermes/hermes-agent` → shared checkout; `WANTED_UID=0` + whoami spoof (root needed: `/addon_configs` is root-owned 0700); `rsync -a /apptoo/ /app/`; `exec /hermeswebui_init.bash`.
- init: reuse `/app/venv` if present else `uv venv`; the `.deps_installed` guard wraps: webui deps + agent-source staging (`rsync -a` to `/tmp/hermes-agent-build`, excludes `.git`, `*.egg-info`, `build`, `dist`, `__pycache__`, `.playwright`; `chmod -R u+w` because `rsync -a` preserves `:ro` mode bits) + `uv pip install "hermes-agent[all]"` + `touch .deps_installed` + `rm -rf` the staging.
- The staging rsync does NOT exclude extra venv dirs — a `venv-cli/` (~128 MB) created inside the checkout would be copied on every fresh-image boot. Never create venvs inside the shared checkout.

## Host paths / mounts table
| Host path | Agent container | WebUI container |
|---|---|---|
| `addon_configs/<slug>_hermes_agent/.hermes` | `/config/.hermes` | `/addon_configs/<slug>_hermes_agent/.hermes` (HERMES_HOME) |
| `…/.hermes/hermes-agent` | `/config/.hermes/hermes-agent` | symlink `/home/hermeswebui/.hermes/hermes-agent` |
| `…/workspace` | `/config/workspace` | `HERMES_WEBUI_DEFAULT_WORKSPACE` |
| `…/.config` `.local` `.gitconfig` | `/config/…` | symlinks `/root/.config` `/root/.local` `/root/.gitconfig` + XDG vars |
| `/data/hermes-webui` | — | WebUI state (sessions, settings, model cache) |
On HAOS the host layout is `/mnt/data/supervisor/addon_configs/<slug>_hermes_agent/` (agent addon README). **HA has renamed the tree to `/app_configs/…`** (container names now carry the `app_` prefix, e.g. `app_<repo>_<slug>`); the legacy name still resolved inside the WebUI container on the same day the rename was reported, so treat both as live and make any probe try `/app_configs` then `/addon_configs` before concluding a directory is absent. **Neither name exists in the AGENT container** — there the same directory is `/config`, which is why host-side paths written into `config.yaml` (`skills.external_dirs`, `skills.trusted_project_dirs`) are silently inert (see below).

## Verified Hermes internals (from local source — claim-checking recipe)
When a doc/PDF makes claims about Hermes features, verify against the installed source checkout instead of trusting them:
- CLI subcommands: `hermes_cli/main.py` → `_BUILTIN_SUBCOMMANDS` frozenset (authoritative list).
- `hermes mcp` actions: `serve/picker/catalog/install/test` (`hermes_cli/mcp_config.py`; `test` is dispatched via a dict, `"test": cmd_mcp_test`, not an `action ==` branch). `memory status/setup` (`memory_setup.py`); `skills inspect/check/update` (`skills_hub.py`); `sessions optimize`, `logs errors`, `prompt-size`, `insights`, `pairing`, `doctor`, `config get`, `gateway restart` all present in this version.
- Aux-model auto chain (`agent/auxiliary_client.py` docstring): 1) main provider, 2) OpenRouter (`OPENROUTER_API_KEY`), 3) Nous Portal (`auth.json`). **Codex OAuth is intentionally NOT in the auto chain.** Vision tasks skip non-multimodal providers → a DeepSeek-only setup gets silent vision failure.
- Memory: `agent/memory_manager.py` — built-in provider plus **at most one** external provider.
- Slash commands: `hermes_cli/commands.py` `COMMAND_REGISTRY` (e.g. `/handoff` = handoff to another messaging **platform**, not model/persona; `/personality`, `/deny`, `/yolo`, `/reload-mcp` real).
- MCP: per-server `tools.include` allowlist supported (`mcp_config.py`); stdio env filtering (only PATH/HOME/USER/LANG/LC_ALL/TERM/SHELL/TMPDIR/XDG_* pass to subprocesses).
- Skills: agentskills.io open standard; progressive loading (~100 tokens metadata per skill at startup, body <5k tokens on trigger, resources as needed).
- Checked-but-absent: `hermes logs --since` flag, personas named "architect/codereviewer/ops/scribe", persistent deny-rules under YOLO mode.

## Host-side paths in `config.yaml` are silently inert (0 skills load)
**Neither `/addon_configs` nor `/app_configs` exists inside the agent container** — its own app-config dir is mounted at `/config` (= `$HOME`). An absolute host-side path in `config.yaml` therefore resolves to nothing, and Hermes skips a non-existent skill dir **without any warning** (`hermes config check` does not validate skill dirs):
- `skills.external_dirs` → the deployed shared skills (`make skills-deploy` → `~/.claude/skills`, i.e. `/config/.claude/skills`) never load.
- `skills.trusted_project_dirs` → repo-local skills (`./.agents/skills`, `./.hermes/skills`) never load for sessions whose project root is that repo.

Read-only diagnosis: `ls -d /addon_configs /app_configs` (both missing ⇒ nothing to resolve); `hermes skills list --source all` for the header counts (`N hub-installed, N builtin, N local`) plus a grep for the expected names — **project-scoped skills are deliberately not listed there**; `hermes skills inspect <name>` resolves by name and reports `No skill named '<x>' found in any source` when nothing is in scope; `hermes skills trust [path]` (path defaults to the enclosing git checkout of cwd) is the command that writes `trusted_project_dirs`.
Fix: write the **container-native** path (`/config/.claude/skills`, `/config/workspace/<repo>`); the host-side spelling can stay as an inert fallback. Two containers read the same `config.yaml` through different mount namespaces, so a path can be correct for one and inert in the other — the WebUI's `run.sh` symlinks `/config` for exactly that reason.

## A repo venv built outside the container is dead inside it
Symptom: `pre-commit` / `pytest` / `ruff` report "not found" while the files exist, or a script fails with a `#!/addon_configs/<hash>_hermes_agent/...` shebang that resolves nowhere; every commit ends up using `--no-verify`.
Cause: the venv was created in a context where the host-side path resolved, so its script shebangs and `pyvenv.cfg` are baked to a path that does not exist in the agent container.
Fix (verified): `rm -rf venv && make install-dev` **from inside the container** → uv creates `.venv` (its default name) with container-valid shebangs; the repo's own test runner already prefers `.venv`. Prove it with `pre-commit run --all-files` — all hooks must Pass, which also exercises `uv-lock` and `skills-check`.
Expected side effect: the sync may correct a stale lockfile entry. A `uv.lock` diff limited to the project's own `version =` line (lock lagging `pyproject.toml`) is a legitimate sync, not dependency drift; the `uv-lock` hook passes with it and would have failed without it. Report it to the user rather than leaving unexplained dirt in the tree.
