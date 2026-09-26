# Health-check pass (`/doctor`) — live-run recipe

From a real pass on 2026-08-03 in the hermes-webui addon container (approvals=manual, CLI venv broken, gateway live in the AGENT container sharing `$HERMES_HOME`).

## Environment facts that shape the pass
- `hermes` is not on PATH; `$HERMES_HOME/hermes-agent/venv/bin/hermes` exists but its python3 binary is missing (relocatable venv whose `pyvenv.cfg` `home` points into the agent container's runtime). `hermes doctor` cannot run in this container — run it in the agent container, or do the manual pass below.
- System python3 (3.12.13) exists at `/usr/local/bin/python3`, BUT routing diagnostics through `execute_code` still hits the approval gate — native read tools are the reliable path when the user isn't responding to prompts.
- `search_files` refuses `$HERMES_HOME/.env` with "credential store — cannot be read directly". Expected guard, by design; don't burn calls trying.

## Exact files
| File | What it tells you |
|---|---|
| `$HERMES_HOME/gateway_state.json` | `pid`, `gateway_state`, per-platform `state`/`error_code`/`updated_at` — the canonical health source |
| `$HERMES_HOME/gateway.pid` | live gateway pid + argv + hermes_home (agent container's) |
| `$HERMES_HOME/gateway-starts.log` | one epoch per gateway start; count + recency = crash-loop check |
| `$HERMES_HOME/config.yaml` | validity + model/provider/fallbacks/compression/approvals mode |
| `$HERMES_HOME/logs/{errors,agent,gateway}.log` | error + aux signatures |
| `$HERMES_HOME/logs/gateway-exit-diag.log` | grows unbounded (42 MB observed) — hygiene item, suggest rotation |
| `$HERMES_HOME/config.yaml.corrupt.*.bak` | evidence of a past corruption event that was recovered — cleanup candidate once user is confident |

## Signatures observed on a healthy system
- errors.log with zero `CRITICAL|FATAL|Traceback` hits = clean.
- gateway_state platforms `connected`; 4 start-lines spread over days = no crash loop.
- `api_server` platform `disconnected` since no API key configured = benign, not a fault.

## Signatures on a degraded aux chain
```
WARNING agent.auxiliary_client: Auxiliary: marking openrouter unhealthy for 60s (payment / credit error)
WARNING agent.auxiliary_client: Auxiliary: marking nous unhealthy for 60s (payment / credit error)
```
Repeated in 60s windows = both fallback providers out of credits. Main provider (deepseek) unaffected; aux calls skipped until recovery. Report as the ONE actionable finding; fix = top up credits or trim the aux chain.

## The approval-gate trap (as observed)
- A compound read-only `terminal` command → `BLOCKED: Command timed out without user response. ... Silence is not consent.`
- An `execute_code` script → same BLOCK (it is not a bypass).
- Native tools — `read_file`, `search_files`, `cronjob`, `session_search` — ran fine with no gate.
- Rules: read-only diagnostics use native tools FIRST; reserve terminal/execute_code for when they're genuinely needed, and expect the consent prompt; NEVER retry a blocked command or an equivalent (the block message forbids it and the user may be away) — pivot to native tools to finish the pass.

## Report shape that worked
A `Check | Status | Detail` table (gateway, config, network, logs, cron, disk, CLI-venv caveat), plus: call out the single actionable problem (aux credits), list suggested housekeeping (rotate the 42 MB diag log, drop dead aux providers), and explicitly flag which deeper checks were skipped pending approval. Offer the fix, don't just do it.
