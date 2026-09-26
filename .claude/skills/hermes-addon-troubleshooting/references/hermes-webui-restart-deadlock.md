# Case study — Hermes WebUI addon "won't restart"

Real diagnosis of a Hermes Agent HA addon where the dashboard/WebUI refused to restart the gateway.

## Environment (the addon container)
- Same container runs: `nginx` (front, port 49169) → `web_server` = WebUI/dashboard (`python -c "from hermes_cli.web_server import start_server; ...port=49469..."`) + `gateway` (`python -m hermes_cli.main gateway run`) + two `ttyd` terminals (`/hermes/`, `/terminal/`).
- `/data/options.json` identifies the addon: `git_url=NousResearch/hermes-agent`, `hermes_home=.hermes`, `hass_url=http://homeassistant.local:8123`, `enable_dashboard/terminal/api=false`.
- The gateway ran `...main.py gateway run --replace`, PPID=1 (detached/reparented from its launcher).

## Process snapshot
```
363   web_server (port 49469)   PPID 80 (s6 supervisor), no children
104812 tmux -L hermes-hermes start-hermes   PPID 1
105402 gateway run --replace                PPID 1   <- holds the lock
```
`gateway.pid` = `{"pid":105402,"kind":"hermes-gateway","argv":[...,"gateway","run","--replace"],...}`

## Evidence
- `gateway.log` (86 lines, recently rotated) dominated by ~19 repeats of:
  `✗ Another gateway instance is already running (PID 105402).`
- Those bare lines carry no timestamp; they interleave with timestamped Telegram inbound/outbound lines.
- `gateway-exit-diag.log` history showed earlier clean restarts and repeated `SystemExit: 75` on `gateway run` (the conflict guard exits 1; related exit path logs `exit_nonzero`).

## Root cause
The dashboard/WebUI spawns a gateway it can *manage* via bare `hermes gateway run`. But a gateway already started with `--replace` from another launcher (the `start-hermes` tmux session) got reparented to PID 1, so the dashboard no longer owns it and can't stop/replace it. Every dashboard restart attempt hits the preflight guard and fails.

## The guard in source
`hermes_cli/gateway.py::_guard_existing_gateway_process_conflict(replace=False)`:
- Reads `gateway.pid` via `get_running_pid()`.
- If a pid exists and `replace=False` (and not under the gateway supervisor), prints the "Another gateway instance is already running" block and `sys.exit(1)`.
- `--replace` or a supervisor context skips the guard.
- Comment explains a supervisor/dashboard loop repeatedly running bare `hermes gateway run` burns memory/CPU just to fail — exactly the observed flood.

Dashboard restart side: `POST /api/gateway/restart` → `_spawn_gateway_restart()` → `_spawn_hermes_action(["gateway","restart"],"gateway-restart")`, with in-flight dedup via `_ACTION_PROCS` (so double-clicks are not the cause).

## Fix direction (confirm with user before applying)
- Remove the stale detached lock holder: `hermes gateway stop` or kill the pid in `gateway.pid`.
- Remove the conflicting launcher (the `start-hermes` tmux session) so the WebUI owns the gateway lifecycle.
- For an intended takeover, launch with `--replace`.
- Then trigger restart from the dashboard and verify a NEW gateway pid appears.

## Read-only verification that confirmed diagnosis
- `curl` to 49469 and 49169 both returned HTTP 200 (WebUI itself was healthy; the failure was purely the restart path).
- `nginx -T` mapped `/dashboard/`, `/hermes/`, `/terminal/`, `/v1/` to separate upstreams.
