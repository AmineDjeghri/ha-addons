# Hermes WebUI addon — two-container shared architecture & the Tier-2 fix

Concrete case study: the user's `ha-addons/addons/hermes-webui`, built on the
upstream `ghcr.io/nesquena/hermes-webui:0.52.106` image. Goal: share the same `.hermes` data,
workspace, and tool config between the **Hermes Agent addon** and the **Hermes WebUI addon**
so the browser UI sees everything the CLI agent sees.

## What is shared (data) vs what is NOT shared (code/venv)

**Shared correctly (data) — done in `run.sh`:**
- `HERMES_HOME` → auto-discovered agent addon dir (`/addon_configs/<slug>_hermes_agent/.hermes`),
  or from the `hermes_home` option. Gives the WebUI the same sessions, memory, skills, config, API keys.
- Workspace → `HERMES_AGENT_HOME/workspace`, exposed via `HERMES_WEBUI_DEFAULT_WORKSPACE`.
- `.config`, `.local`, `.gitconfig` → symlinked into the WebUI's `/root`/`/home/hermeswebui`, plus
  `XDG_CONFIG_HOME` / `XDG_DATA_HOME` — shares `gh` auth, npm/pip caches, git credential helper.

**Not actually shared — code/venv:** the two containers have separate venvs and filesystems.
The addon symlinks the agent *source* (`${hermes_home}/hermes-agent` →
`/home/hermeswebui/.hermes/hermes-agent`) so the upstream init rebuilds hermes into the WebUI's
own `/app/venv` every boot. That is NOT "sharing a venv" — it's a second copy of the dependency
tree, rebuilt each start, and it is what breaks.

## Why it broke
The upstream `docker_init.bash` (base image) installs the agent source with a **non-editable**
`uv pip install "$_stage_src[all]"` (staged copy at `/tmp/hermes-agent-build`). Hermes refuses
wheel builds (`setup.py:35`), so the install errors and the WebUI exits 1 every boot. It worked
before because an older hermes allowed source builds; a newer hermes added the refusal.

## The Tier-2 fix (applied)
In the addon's `run.sh`, before `exec /hermeswebui_init.bash`, one `sed` rewrites the install to
pull from PyPI (decoupling from the source tree):

```bash
sed -i \
  's|uv pip install "$_stage_src\[all\]"|uv pip install "hermes-agent[all]"|' \
  /hermeswebui_init.bash
```

Keep the agent-source symlink so the init's `if [ -n "$_agent_src" ]` block is entered (otherwise
no hermes-agent gets installed at all, since `requirements.txt` does not ship it). The init still
rsync-stages the source (harmless wasted copy) but installs the released wheel from PyPI.

## Upstream init file location
Not in the addon repo — it's in the base image. Resolve via `build.json` → `build_from`
(e.g. `ghcr.io/nesquena/hermes-webui:<ver>`), then read the upstream repo's `docker_init.bash`.
`run.sh` execs it as `/hermeswebui_init.bash`; patch it at boot with `sed -i` since you can't
rewrite the base image without rebuilding it.

## Tier 3 note (future)
The clean end-state is to drop hermes-agent from the WebUI entirely and make it a static frontend
over the Agent addon's HTTP API (`/v1/` → `hermes_api_0`; enable `API_SERVER_ENABLED` +
`API_SERVER_KEY`). Blocked today because upstream `nesquena/hermes-webui` imports `AIAgent`
in-process and has no API-client mode — needs a fork or upstream feature.
