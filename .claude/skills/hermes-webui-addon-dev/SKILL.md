---
name: hermes-webui-addon-dev
description: Develop and maintain addons/hermes-webui — the two-container Hermes Agent + WebUI add-on pairing, its shared-data/separate-venv architecture, and update mechanics.
---

# Hermes WebUI Add-on

`addons/hermes-webui/` packages the third-party [nesquena/hermes-webui](https://github.com/nesquena/hermes-webui)
dashboard as a pinned-release add-on that pairs with a separately-installed Hermes Agent add-on.
This skill covers the packaging/architecture concerns specific to that pairing. Debugging the
Hermes Agent software itself — gateway restart deadlocks, CPython-version bugs, dashboard liveness
false negatives, update-time OOM — is out of scope here: those are deployment-agnostic Hermes
Agent failure modes, not add-on packaging.

## Two containers, one shared directory

The Agent add-on's private `addon_config` mount and the WebUI add-on's mount both resolve to the
**same host directory** (`/addon_configs/<repo>_<slug>_hermes_agent/`), each under a different
in-container path:

- Agent container: mounted at `/config` (its `$HOME`) → `HERMES_HOME = /config/.hermes`.
- WebUI container: mounted at `/addon_configs/<slug>_hermes_agent/` via `all_addon_configs:rw`.
  Its `run.sh` additionally symlinks `/config` → that same directory at boot (guarded, shared-mode
  only) so that any `/config`-relative path (skill dirs, tool shims) resolves identically in both
  containers. Before this symlink existed, any stored `/config/...` path baked into shared config
  or shim scripts would dangle in the WebUI container specifically — a good diagnostic tell if a
  tool shim fails with "file not found" only in one of the two containers.

There are no bind mounts between the two containers directly — everything shared goes through this
one host directory plus the boot-time symlinks.

## Share data, never venvs — the rule this pairing exists to demonstrate

- Agent container: Python from a managed runtime inside the shared checkout, **editable** install
  (the agent modifies its own code).
- WebUI container: its own container-local, disposable venv, recreated on image re-init.
- **Never create a venv or run `pip`/`uv install` inside the shared checkout from the WebUI side.**
  The agent's source tree is shared; an editable install or stray build artifact left there
  survives into the agent's own install and can break it. A working CLI needed from the WebUI
  container should get its own venv *outside* the shared checkout.
- hermes-agent refuses non-editable wheel/sdist builds by design (a deliberate `RuntimeError` at
  build time telling you to use an editable install or a packaged release) — so any install script
  targeting the shared checkout's source must use `-e`, never a plain `pip install <path>`.
- Update from the Agent add-on only. The WebUI's CLI is typically a separate packaged install (e.g.
  from PyPI) with no git checkout of its own — running an update command there is a no-op for code
  even if it still touches shared state (backups, config-migration prompts). Running `update` from
  both sides is not "extra safety", it's redundant work against shared files.

## Boot-time staging (why, not just what)

If the WebUI container needs to build from the agent's shared source at all (rather than a plain
package install), it must **stage** the source to a writable scratch location first — the shared
checkout is typically mounted read-only from that side (defense in depth), and a build step that
writes build metadata into the source tree (egg-info, `.pth` files) fails outright on a read-only
mount. Symlinks (not bind mounts) are the right tool for exposing a runtime-computed shared path at
a fixed location the upstream image expects — HA bind mounts are static and declared at container
creation, but a symlink target can be computed at boot (auto-discovered slug, shared vs. isolated
mode) and updated idempotently on every restart.

## When changes take effect

- `map:` → read by the Supervisor at container **creation**; a restart reuses the existing mounts.
- `run.sh` → baked into the image at build time; a restart of the current image does not pick up a
  repo change — only a rebuild does, and then it applies at every subsequent boot.
- An add-on **update** does both (rebuild + re-create) in one step — don't tell a user a `run.sh`
  change works on "the next restart" without the rebuild.

## Diagnostics quirk worth knowing

The Supervisor API returns 403 from the WebUI container even with a valid token, because its
`config.yaml` doesn't grant `supervisor_api: true` — that's a real permission gap, not just an
approval-gate artifact. Per-add-on resource stats need `docker stats` from the host or `ps` inside
the add-on's own terminal instead.

## Reducing `map: config:rw` to read-only or removing it

Prefer read-only HA access over a writable mount of HA's own config tree:

- Add-on/container logs: the Supervisor API (`SUPERVISOR_TOKEN` is auto-injected in every
  container) — `GET /addons/{slug}/logs`, `/core/logs`, `/host/logs`.
- Automation state/config: HA Core's REST/WebSocket API (`config/automation/list`,
  `config/automation/config/<id>`) — no filesystem access needed.
- `map: config:rw` is a real liability (rw access to `secrets.yaml`, `.storage/auth`) — downgrade
  to `config:ro` or drop it entirely once the API paths above cover what you needed it for.
