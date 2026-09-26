# Removing a mapped mount / capability from an add-on

`map:` entries are capability grants — `config:rw` is read/write on Home Assistant's own config dir
(`secrets.yaml`, `.storage/auth` refresh tokens), `all_addon_configs:rw` is every add-on's options.
When the user asks "verify we can drop it", answer with source evidence first, then a runtime check.

## 1. Enumerate every path the app writes — both sides, before touching anything
- **Add-on side:** read `run.sh` / `bootstrap.js` / `config.yaml`. If no env var points at that mount,
  the only possible consumer is an app default. Grep the launcher for the path and for every option
  that maps to one (`grep -nE 'config|/data|/media' run.sh`).
- **Upstream side:** shallow-clone upstream and list every filesystem WRITE plus every path the app
  builds:
  - `grep -rnE 'File\.(WriteAllText|WriteAllBytes|AppendAllText|Create|OpenWrite|Move|Copy|Delete)|Directory\.CreateDirectory|StreamWriter\(' --include=*.cs <app>/`
  - `grep -rnE 'Path\.Combine|Directory\.GetCurrentDirectory|AppContext\.BaseDirectory|SpecialFolder' --include=*.cs <app>/`
- **Then grep upstream for the mount literal:** `grep -rniE '/config' --include='*.cs' --include='*.json' --include='*.yml' .`
  A hit ONLY in `docker-compose.yml`, as `${VAR:-<mount>/...}`, means the mount is a compose-only
  default — a HA add-on never uses docker-compose, so the option is unset and the app falls back to
  its own default. Read the Dockerfile's `WORKDIR`: CWD-relative defaults land there (ephemeral), not
  in the mapped dir.
- **Report the result as resolved targets:** each write → the persistent mount (`/media`, `/data`), the
  temp cache (`Path.GetTempPath()` → `/tmp`, wiped on restart), or a CWD-relative file. "Nothing reads
  it" is only a conclusion once every write has a home.

## 2. Ship the removal with its reason
- Delete the entry from `config.yaml` and record the intent in the add-on README ("holds only
  `media:rw`; do not re-add `config:rw` — nothing reads it") so it is not silently restored later.
- Versioning rules still bind: never hand-edit `build.json` or `version:` on an image-pinned add-on.

## 3. Verify at runtime — a `map:` change needs a reinstall, not a restart
- The Supervisor re-reads `config.yaml` on install/update/reinstall; a plain Restart keeps the old
  mounts. If `version:` did not change, HA offers **no** Update entry — the instruction is ⋮ →
  Reinstall, and say that explicitly instead of "restart it".
- Host-side proof (the agent container has no docker socket):
  `docker inspect $(docker ps -q -f name=<container>) --format '{{range .Mounts}}{{.Source}} → {{.Destination}}{{"\n"}}{{end}}'`
  → the removed path absent, the kept ones present.
- Functional proof: exercise the feature that used the mount (a download, a playlist star) and check
  the artifact's mtime where it belongs, plus a clean add-on log via the HA MCP
  (`ha_get_logs(source='supervisor', slug='<repo>_<slug>')`).
- **The live mount list is not readable from inside the add-on** — the Supervisor API answers 403 for
  a `default`-role add-on, HA's hassio proxy 401, and `ha_get_app` does not expose `map`. Do not claim
  a live check you did not run; hand over the `docker inspect` line as the user's own verification.
