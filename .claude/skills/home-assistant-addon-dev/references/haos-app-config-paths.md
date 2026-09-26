# HAOS: where an app's config dir lives, and what it is called

## One directory, two names

- On the host the Supervisor keeps one config folder per app: `/app_configs/<repo>_<slug>/`
  (older HA releases: `/addon_configs/<repo>_<slug>/`). The add-ons→apps rename also shows up in
  container names (`app_<slug>`) and in the API surface (`ha_get_app`, "App (add-on)").
- Inside an app's own container that same directory is mounted at that app's own path. For an app
  whose HOME is its config dir, that path is `/config` — the host-side names do **not** exist in
  there. A path copied from host-side docs therefore resolves to nothing and fails SILENTLY
  (no error, just an entry that loads/applies nothing).
- Apps that map the shared tree (`all_addon_configs:rw`) see every app's folder under the host
  name, so the same string can be correct in one app and dead in another. Check which container a
  path is read in before "fixing" it.

## Rules

- In anything a *container* reads (agent config, app options), use the container-native path
  (`/config/...`), never the host form. Intent is spelled out in the user's own add-on: its run.sh
  symlinks `/config` to the agent app's directory precisely so `/config`-based paths resolve
  identically in both containers.
- Discovery code must probe BOTH names, oldest last, and log which one matched:
  `for root in /app_configs /addon_configs; do [ -d "$root" ] || continue; … ; if [ -n "$found" ]; then break; fi; done`
  A silent fallback to a fresh empty directory is the worst outcome — it looks like data loss.
- READMEs/docs that quote host paths should name both spellings; which one is live depends on the
  HA release, and the observing container cannot settle it from the inside.
- `map:` keys are NOT renamed in lockstep with the directory: an existing `all_addon_configs`
  still works where the tree is already `/app_configs`. Do not rename the key blind — the app
  starting is the evidence, not the naming.
- `map:` and `run.sh` changes do NOT apply on a plain restart: `map:` is re-read on
  reinstall/update, and run.sh ships inside the image (needs a rebuild). Say which one is required
  instead of telling the user to "restart".

## Reading live state from inside an app container (what you cannot do)

- The Supervisor API refuses an app's own default role (`ha_role: default` → 403 on `/addons*`),
  and HA Core's hassio proxy rejects long-lived tokens (401) — you cannot read another app's live
  mounts from inside a container. The registry info (`ha_get_app`) also does not expose `map:`.
- What works: `ha_get_app` for version/state/options, `ha_get_logs(source='supervisor', slug=<app>)`
  for the app's own log (startup banner + errors), and app-side evidence in the app's own log or
  files. For mounts, hand the user one `docker inspect … --format '{{range .Mounts}}…'` line.
- An app can be dead for days without anyone noticing: state `error`, log tail showing a SIGKILL
  (`Killed`) rather than a traceback. Check state + log tail together, and note that watchdog
  `false` means a crash is NOT auto-restarted.
