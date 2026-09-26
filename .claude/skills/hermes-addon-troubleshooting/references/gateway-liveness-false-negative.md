# Dashboard "gateway is not running" false negative — verified diagnosis

From a real session (2026-08-17): the dashboard Channels tab showed *"The gateway is not running… restart the gateway to connect this platform"* plus a red `TELEGRAM: GATEWAY IS NOT RUNNING` banner — while Telegram chat worked perfectly and `gateway_state.json` reported `"gateway_state": "running"`, `telegram: connected`.

## The liveness ladder (`resolve_gateway_liveness`)

Located in `gateway/status.py` (`resolve_gateway_liveness`, ~line 1173). Single source of truth for "is the gateway up?" across dashboard surfaces (`/api/status`, `/api/messaging/platforms`, Channels page). Three rungs, most to least authoritative — **fails closed** when all miss:

1. **PID file + runtime lock** — `get_running_pid_cached()` reads `$HERMES_HOME/gateway.pid` (path from `_get_pid_path()`, respects HERMES_HOME). Cached 1s TTL.
2. **HTTP health probe** — only if `GATEWAY_HEALTH_URL` env is set in the dashboard/web_server process (`_GATEWAY_HEALTH_URL = os.getenv("GATEWAY_HEALTH_URL")`, `hermes_cli/web_server.py` ~line 1596). Probes `/health/detailed` then `/health`. **Deprecated** (scheduled for removal, "Docker-adjacent lore") but still the only cross-container escape hatch.
3. **Runtime status PID** — `read_runtime_status()` reads `$HERMES_HOME/gateway_state.json`, then `get_runtime_status_running_pid()` (line ~1293) validates: pid exists (`_pid_exists`), `start_time` fingerprint matches `/proc/<pid>/stat` field 22, and `_record_matches_live_gateway_pid()` (line ~537) checks the live command line.

## Why all three rungs failed in this deployment

| Rung | Expected signal | Observed | Result |
|---|---|---|---|
| PID file | `gateway.pid` exists, lock held | **No `gateway.pid`, no `gateway.lock`** in `$HERMES_HOME` | fail |
| Health URL | `GATEWAY_HEALTH_URL` set | **Unset** (not in `.env`, not in launcher/supervisor) | skipped |
| Runtime status | argv matches gateway matcher | `gateway_state.json` pid 427 alive, state `running` — but argv is `/usr/local/lib/hermes-gateway-launcher.py gateway run` | fail |

The killer: `_gateway_command_subcommand()` (`gateway/status.py` ~line 395-441) only recognizes:
- `gateway/run.py` token
- basename `hermes-gateway` / `hermes-gateway.exe`
- `hermes_cli.main` / `hermes_cli/main.py` in joined argv, or a token with basename `hermes` / `hermes.exe`, **followed by** a `gateway` token whose next token is the subcommand

`s6`/addon-managed gateways run as `hermes-gateway-launcher.py gateway run` → basename is `hermes-gateway-launcher.py` (not `hermes-gateway`), no `hermes_cli.main`, no bare `hermes` token → `has_gateway_entry` = False → returns None → `looks_like_gateway_runtime_command_line()` False → `_record_matches_live_gateway_pid()` False → rung 3 fails. All rungs down → dashboard renders "not running".

## The process chain observed (addon container)

```
python hermes-gateway-supervisor.py --environment-fd 4   ← s6 supervisor
python hermes-gateway-logger.py ...                      ← log relay
python hermes-gateway-launcher.py gateway run            ← pid in gateway_state.json
python -c "from hermes_cli.web_server ..."               ← dashboard web server (separate process)
ttyd --port 49269 / 49369                                ← terminal surfaces
tmux -L hermes-hermes -u                                 ← TUI launcher session
```

Launcher-managed = writes `gateway_state.json` (with `kind: hermes-gateway`, `argv`, `start_time`, `gateway_state`, `platforms`), **not** `gateway.pid`. This is the documented "launch-service-managed gateway" shape the code comments explicitly call out.

## Fixes (confirm with user before applying)

1. **Set `GATEWAY_HEALTH_URL`** in the dashboard/webui process env (e.g. `http://localhost:8642`) → rung 2 confirms liveness via HTTP and the Channels page goes green. This is the designed (if deprecated) cross-container escape hatch.
2. **Upstream fix** — teach `_gateway_command_subcommand()` to treat `hermes-gateway-launcher.py` (or any `*-gateway-launcher.py`) as a gateway entrypoint. Worth a bug report / PR to NousResearch.
3. **Ignore it** — purely cosmetic; the gateway, Telegram, and dashboard all work. Verify via `gateway_state.json` + `ps` before assuming real trouble.

## Fast truth-check for "is the gateway really down?"

```bash
cat $HERMES_HOME/gateway_state.json        # gateway_state: running? platforms.telegram.state: connected?
ps aux | grep -E "gateway.*run|gateway-launcher"  # live process?
ls $HERMES_HOME/gateway.pid                # absent is NORMAL for launcher-managed — not proof of down
```
If state says running + process alive + Telegram works, the dashboard banner is a false negative regardless of what it claims.
