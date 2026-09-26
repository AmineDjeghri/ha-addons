# Case study: Hermes WebUI HA addon — hermes-agent wheel build refused

Real session where the gateway lock deadlock was already cleared (addon restarted
cleanly, `Another gateway instance is already running` gone) but the WebUI STILL
wouldn't start. Second, distinct root cause found in the WebUI's boot install.

## Environment (two separate containers)
- **Hermes Agent addon** (the gateway this agent runs in): home `/config`,
  venv `/config/.hermes/hermes-agent/venv`, Python 3.11.x, `gateway.pid` at
  `/config/.hermes/gateway.pid`, logs `/config/.hermes/logs/`.
- **Hermes WebUI addon** (the thing that "won't restart"): home
  `/home/hermeswebui`, Python 3.12.13 via `uv`, app staged `/apptoo → /app`,
  init script `/hermeswebui_init.bash`.
- The two are NOT the same container and do NOT share a venv (contrary to the
  common assumption). No docker socket / shared mount means you cannot exec into
  the other container from the gateway — you diagnose the WebUI from its own
  terminal output and from the addon's source repo.

## The failing error (from the WebUI terminal)
```
!! WARNING: hermes-agent source mount is writable from the WebUI container.
!!   Path: /home/hermeswebui/.hermes/hermes-agent
Using Python 3.12.13 environment at: venv
Resolved 95 packages in 714ms
   Building hermes-agent @ file:///tmp/hermes-agent-build
× Failed to build `hermes-agent @ file:///tmp/hermes-agent-build`
  ╰─▶ RuntimeError: Building wheels or sdists for hermes-agent is not supported.
      If you are developing, use an editable install instead:
        uv sync          # or: uv pip install -e .
!! ERROR: Failed to install hermes-agent's requirements
!! Exiting script (ID: 1)
```

## Root cause chain
1. The addon `run.sh` symlinks the agent source so both containers share code:
   `ln -sfn "${hermes_home}/hermes-agent" /home/hermeswebui/.hermes/hermes-agent`
   then `exec /hermeswebui_init.bash`.
2. `requirements.txt` is minimal and does NOT include `hermes-agent`, so the
   init MUST install it from that symlinked source.
3. Upstream `docker_init.bash` (line ~469) runs:
   `uv pip install "$_stage_src[all]" --trusted-host ...`
   where `$_stage_src=/tmp/hermes-agent-build` (an rsync copy of the source).
   A bare (non-`-e`) install of a local dir makes uv build a wheel.
4. `hermes-agent`'s build refuses wheel builds ("Building wheels or sdists ...
   is not supported") → `error_exit` → code 1 → server never runs.

## Fix applied — CURRENT (in the addon's `run.sh`, before `exec`)
The repo ships the **Tier-2 PyPI redirect** (commit `e3c0014`, "install hermes-agent
from PyPI to fix startup failure") — NOT the editable variant below:
```bash
sed -i \
  's|uv pip install "$_stage_src\[all\]"|uv pip install "hermes-agent[all]"|' \
  /hermeswebui_init.bash
```
This installs the released PyPI wheel (frozen at latest published, e.g. 0.19.0 —
pip is deprecated upstream) into the container-local `/app/venv`: no wheel build,
no drift from the shared checkout, no coupling to the agent's source. `run.sh`
comments record that the earlier source install "crashed the WebUI on boot".

## Earlier alternative (Tier 1 — editable, NOT what the repo ships)
```bash
sed -i \
  -e 's|uv pip install "$_stage_src\[all\]"|uv pip install -e "$_stage_src[all]"|' \
  -e '/rm -rf "$_stage_src"/d' \
  /hermeswebui_init.bash
```
Notes:
- Adding `-e` makes it editable (allowed). Must ALSO drop the `rm -rf "$_stage_src"`
  because an editable `.pth` points into that dir.
- `-e` + `/app`/`/tmp` ephemeral-in-sync is safe: both are rebuilt each boot.
- An editable install makes the WebUI CLI track the shared checkout (agent's
  version) but couples it to the agent's source — the design docs prefer the
  disposable PyPI snapshot (README: "check drift with `hermes --version`").
- Either fix is a boot-time patch of a **base-image** script, so it survives only
  while the addon image is rebuilt/reinstalled from this repo. A manual `sed` in
  a running container does NOT persist across restarts.

## Test verdict (Aug 2026): upstream staging does NOT fix the refusal
Hypothesis: nesquena's `docker_init.bash` staging (writable copy to
`/tmp/hermes-agent-build`, `chmod -R u+w`, excludes `.git`/`*.egg-info`/`build`/`dist`
— commits `70f371c8`/`60218c30`/`4b202d12`, present since v0.52.106) makes the
source install viable, so the PyPI sed could be dropped and the WebUI CLI would
follow the agent's checkout version.
Tested live in the webui container with a throwaway venv and the exact upstream
command:
```bash
rsync -a --exclude='*.egg-info' --exclude='build' --exclude='dist' \
  --exclude='__pycache__' --exclude='.git' --exclude='.playwright' \
  /home/hermeswebui/.hermes/hermes-agent/ /tmp/hermes-agent-build/
chmod -R u+w /tmp/hermes-agent-build
uv venv /tmp/test-venv
VIRTUAL_ENV=/tmp/test-venv uv pip install "/tmp/hermes-agent-build[all]" \
  --trusted-host pypi.org --trusted-host files.pythonhosted.org
```
Result: **exit 1, same RuntimeError** — "Building wheels or sdists for hermes-agent
is not supported ... use an editable install instead". The refusal is a DELIBERATE
guard in hermes-agent's build config (it ships via shell installer / Docker image /
Nix), NOT a filesystem/EROFS issue — the staging only fixes read-only source mounts.
Conclusion: **the PyPI sed (Tier 2) is the correct permanent fix**; don't re-test the
staging hypothesis; the only source-install path is editable (`-e`), with the design
trade-offs above.
Recipe notes: stage with rsync (not cp) + `chmod -R u+w`, exactly like the script;
test in a throwaway venv so the live `/app/venv` is never touched; `hermes-agent[all]`
is a large install — allow 1–3 min and ~1–2 GB in /tmp; clean the staging copy after.

## Where the init script actually lives (important)
`docker_init.bash` is NOT in the user's addon repo. It comes from the upstream
image referenced in `build.json`:
```
"build_from": { "aarch64": "ghcr.io/nesquena/hermes-webui:0.52.106",
                "amd64":   "ghcr.io/nesquena/hermes-webui:0.52.106" }
```
To find it: `git clone https://github.com/nesquena/hermes-webui` and read
`docker_init.bash`. The install section is under the comment
"== Adding hermes-agent's pyproject.toml base dependencies ...".

## Communication lesson
When the fix touches the user's OWN published repo, the user must approve the
change. The user replied "What do you want to do exactly? I don't understand"
when the explanation leaned on sed/editable/.pth jargon. Lead with: what's broken,
the one-line fix, which file, and ask before pushing. Keep the mechanism
explanation as a secondary paragraph for those who want it.
