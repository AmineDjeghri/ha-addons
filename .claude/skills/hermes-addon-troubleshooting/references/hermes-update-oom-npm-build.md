# Hermes update npm OOM (exit 137) — web build on memory-starved hosts

## Case (verified Aug 2026)
Two-container HA deployment (agent + webui addons sharing one `.hermes`). The agent addon runs `hermes update` (triggered via Telegram). Update pulls code + Python deps fine, then dies at the web workspace build.

Observed output:
```
⚠ npm workspace install failed
  ⚠ Node.js dependency refresh did not complete cleanly; the
    installation may be in a mixed state (updated code, stale Node deps).
→ Building web UI...
⚠ Web UI npm install failed (hermes web will not be available)
✓ Code updated!
⚠ Update partially complete — Node.js dependencies for ui-tui, web
  workspaces did not refresh. ... Leaving running dashboard process(es)
  untouched because the Node.js dependency refresh did not complete.
```
Console/log line: `npm error code 137 ... command sh -c tsc -b && vite build`

## Diagnosis (read-only, agent container shell)
1. `npm error code 137` = 128+9 = SIGKILL = OOM-kill. Not a code problem, not the HA patches.
2. Container limit: `cat /sys/fs/cgroup/memory.max`
   - `max` → NO container limit. **Raising the addon's `mem_limit` is useless** — do not edit the addon config on this evidence.
3. Host pressure: `free -m` — watch `available` and swap.
   - Verified case: 4 GB total, ~3.5 GB used, ~360 MB available, swap 1292/1292 FULL → host-level OOM. The build (~1.5–2 GB peak) cannot fit; the host OOM-killer kills node.
4. Retry sometimes passes (a prior run built in 11.5 s) — it's a lottery driven by momentary host headroom. Three failures in one afternoon were observed.

## Fixes
- **Durable**: add RAM to the host/VM so baseline + build peak fits. HAOS on KVM: raise the VM's RAM (see `haos-on-kvm-notes.md`). 6 GB on an 8 GB dedicated host was the chosen sizing.
- **Band-aid**: bound the V8 heap so node stays under available headroom:
  ```bash
  NODE_OPTIONS="--max-old-space-size=1024" hermes update
  ```
  `NODE_OPTIONS` is inherited by npm/tsc/vite subprocesses (standard Node env var). Drop to 768 if still killed; retry at a low-load moment; check `free -m` first.
- **Accept**: the agent's dashboard keeps serving the last good `web_dist` — stale but functional. The WebUI surface (webui container, PyPI wheel) is unaffected.

## Why one success ends the recurrence
`hermes_cli/update_cmd.py`:
- npm refresh = two steps: root install (`--workspaces=false`), then `--workspace ui-tui --workspace web` (desktop deliberately excluded — Electron postinstall downloads ~200 MB).
- The lockfile hash is recorded ONLY after a successful workspace install (`_record_npm_lockfile_hash`) → future updates skip npm install while the lockfile is unchanged.
- `_build_web_ui` skips when `web_dist` is fresh (staleness check, flock-serialized across processes).
→ After ONE fully-successful update, later updates are cheap (npm skipped, build skipped).

## Partial updates still exit 0
`hermes update` reports `Update finished (exit=0)` even when npm failed ("Update partially complete"). NEVER trust the exit code — verify:
```bash
stat -c '%y' hermes_cli/web_dist/index.html   # must be today's date after a fresh update
```

## Two dashboards (why the WebUI works while the agent's build fails)
- WebUI container: serves its PyPI wheel's pre-built `hermes_cli/web_dist` (built at release CI, never built locally) → works on any host, zero npm.
- Agent container: serves the checkout's `hermes_cli/web_dist` → needs the local `npm install` + `tsc -b && vite build` during update → OOMs on starved hosts; keeps serving the STALE build meanwhile.
- Tell which build a surface serves: compare the JS bundle name in `web_dist/index.html` (`index-<hash>.js`) against the PyPI copy's.
- Agent addon exposes 4 nginx surfaces at boot: `/hermes/`, `/dashboard/`, `/terminal/`, `/v1/` ("Hermes / Dashboard / Terminal / API" in the banner).

## Updates run via Telegram in this deployment
The gateway relays interactive update prompts to `agent:main:telegram:dm:<id>` and applies the reply. Log signatures in `gateway.log`:
```
Forwarded update prompt to agent:main:telegram:dm:...: Restore local changes now? [Y/n]
Telegram update prompt answered 'y' by user ...
Update finished (exit=0), notified agent:main:telegram:dm:...
```
The "Restore local changes now?" prompt is the normal autostash flow: `hermes update` stashes the uncommitted HA-addon patches (`hermes-update-autostash`), pulls, then offers to restore. The user answers **y**; the web patches re-apply cleanly. The stash entry may REMAIN after restore (apply-style restore) — it's STALE (pre-update base; its prefix.py hunk is obsolete) → `git stash drop`, never restore it later.

## Recurring timeline (one real afternoon)
- 15:35 update 1 → npm workspace install wrote web/ui-tui node_modules, build died (137) → restore 'y' → exit 0.
- 16:15 update 2 → "already up to date" + restore prompt → 'y' → exit 0.
- 16:17 addon restart (SIGTERM 16:17:12, gateway up 16:17:37, Telegram + HA connected).
- 16:18–16:20 update 3 → root npm install ran (root node_modules 16:18:53), workspace install died again → build skipped → restore 'y' → exit 0.

Evidence trail: `node_modules` mtimes (web/ui-tui frozen at 15:35), `web_dist` mtime (stale), `gateway.log` prompt lines, agent/errors logs.
