# PyPI-tracked addon pattern (beets case study, Aug 2026)

For addons that wrap a **Python CLI/package with no upstream Docker image** (unlike octo-fiesta's image tracking): track the upstream **PyPI/GitHub release** instead. Reference implementation: `addons/beets/` in ha-addons.

## Version mirroring (updates flow into HA)

- `config.yaml` `version: "2.13.1"` mirrors the beets release → HA shows an update when the bump job runs.
- Dockerfile: `ENV BEETS_VERSION=2.13.1` is the **single source of truth**; install with
  `uv tool install --python 3.14 "beets[fetchart,lastgenre,embedart,titlecase,chroma]==${BEETS_VERSION}"`.
- `bump-beets` job in `.github/workflows/upstream-bump.yml` (same file as octo-fiesta/hermes-webui jobs):
  1. `curl -sL https://pypi.org/pypi/beets/json | jq -r '.info.version'`
  2. compare to `grep -oP '^version: "\K[^"]+' addons/beets/config.yaml`
  3. `sed -i` both the config.yaml version and the `ENV BEETS_VERSION=` line
  4. regenerate CHANGELOG.md section from the GitHub release body (`releases/tags/v${VERSION}`), keep max 9 old sections (octo-fiesta job structure)
  5. commit `chore: bump beets OLD → NEW` (chore: never triggers personal-app semantic release; main-release.yml is paths-gated anyway)
- User preference: build + commit locally, **NO push/PR until the user reviews and explicitly says "create the PR"**.

## From-scratch Dockerfile (Alpine, no upstream image)

- `build.json`: `ghcr.io/home-assistant/{aarch64,amd64,armv7}-base:latest` (personal-app pattern).
- `apk add bash curl jq ca-certificates chromaprint ffmpeg inotify-tools` — Alpine's `chromaprint` package **is** the `fpcalc` binary (no manual GitHub download); `ffmpeg` for audioread decoding; skip GStreamer unless replaygain is used.
- `uv tool install --python 3.14` — uv downloads a managed musl CPython 3.14 at build time (beets supports 3.14 since 2.9.0; user explicitly wants 3.14, not 3.12).
- **The HA builder's injected wheel index breaks uv resolution** (verified Aug 2026, addon build failure): `wheels.home-assistant.io/musllinux-index/` is injected as the ONLY pip index (`PIP_INDEX_URL`) and only carries OLD versions — beets 2.13.1 needs `mediafile>=0.17.0`, index has `mediafile<=0.13.0` → uv `No solution found`. A PyPI EXTRA index does NOT help (first-index-wins dependency-confusion guard). Fix: install from PyPI explicitly, temp build-base as compile fallback:
  ```dockerfile
  RUN apk add --no-cache --virtual .beets-build build-base \
      && uv tool install --python 3.14 \
             --default-index https://pypi.org/simple \
             --index-strategy unsafe-best-match \
             "beets[fetchart,lastgenre,embedart,titlecase,chroma]==${BEETS_VERSION}" \
      && apk del .beets-build \
      && ln -s /root/.local/bin/beet /usr/local/bin/beet
  ```
  ⚠️ **The index override MUST be uv CLI flags** (highest precedence). Env-var overrides (`env -u PIP_INDEX_URL -u UV_INDEX_URL UV_DEFAULT_INDEX=…`) FAIL: the HA base image ships `/etc/pip.conf` pointing at the HA index, and uv honors pip.conf over env vars (PR #18 built, then failed identically on the user's HA; PR #19 CLI flags worked). `InvalidDefaultArgInFrom` warnings in build logs are benign (standard for HA addon Dockerfiles).
- `run.sh` committed as `100644` is the repo convention — the Dockerfile `RUN chmod a+x /run.sh` provides exec at runtime (`git config core.fileMode false` means git won't record the chmod on disk anyway).

## Watcher-style run.sh (`init: false`, `ENTRYPOINT ["/run.sh"]`)

- `bashio::config` is read **once at startup** → options only apply on **restart** (no live reload) → the README must state "Save → Restart" and log a confirmation line.
- Regenerate the app config from options + fixed defaults into `/data/<addon>/config.yaml` at startup.
- Main loop (never exits):
  - Watch: `inotifywait -q -r -e close_write -e moved_to --format '%w%f' -t <debounce>` batches events; filter audio extensions; import **parent dirs** (bash arrays, space-safe, `sort -u`, `head -20`); `-t` makes it exit after the debounce window = natural batching.
  - All runs under `flock -n 9` (fd 9 > lock file) — imports never overlap; skip if lock held.
  - Startup: one full incremental sweep; daily sweep via `date +%H:%M` compare; optional periodic duplicates job.
  - Optional Navidrome rescan: Subsonic API `startScan` with token auth (`salt` = urandom hex, `token` = md5(pass+salt), params `u/t/s/v/c`).
- `import.resume: skip` is mandatory (no TTY — `ask` would hang); `incremental: yes` is the safe default.

## detect-secrets pitfall

Addon `config.yaml` schema lines like `navidrome_password: password?` / `acoustid_apikey: str?` trip detect-secrets ("Secret Keyword") → append `# pragma: allowlist secret` to **those exact lines** (octo-fiesta pattern). Empty-value option defaults (`" "`) are not flagged.

## beets facts worth knowing (2.13.x)

- `quiet_fallback: asis` (2.13.0): weak-match albums import **as-is** (filename-derived tags) instead of being skipped — the key option for streaming-sourced tracks (Octo-Fiesta). Pair with `fetchart.fetch_for_asis: yes` (2.13.0): normally asis imports only use **local** art; this also queries online sources. Existing art is never replaced (only `force` overrides).
- `create_backup_before_migrations` (2.13.0): **built-in, default yes** — beets copies `library.db` to `<db>-before-<table>-<migration>.bak` next to the DB before each one-time schema migration; small (index DB), no rotation. No addon code needed; document it.
- Multi-genre `genres` list since 2.7.0 (Navidrome reads multiple GENRE tags); `beet list has_cover_art:false` and `beet chromasearch` since 2.9.0; `modify` `+=`/`-=` since 2.13.0; `duplicate_action: upgrade` unreleased (Aug 2026).
- User's HA backups **exclude /media** (unchecked — music re-downloadable via Octo-Fiesta); the beets DB in `/data/beets` IS inside HA backups (full backups include each addon's `/data`).
- Music stack: Octo-Fiesta addon downloads to `/media/music` (`map: media:rw`, folder_template `{artist}/{album}/{track} - {title}`); Navidrome at `homeassistant.local:4533`; host reaches the same library via `~/haos_media/music` (transport unverified — Samba likely, or virtiofs/bind).
