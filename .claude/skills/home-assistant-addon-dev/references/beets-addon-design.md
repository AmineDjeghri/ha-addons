# Beets Addon (ha-addons) — design & implementation notes, Aug 2026

Status: **IMPLEMENTED** on branch `feat/add-beets-addon` (commit `d62abc1`, 7 files — amended after README/fetchart rework and the Python 3.14 switch) — committed locally, NOT pushed, PR pending the user's explicit go. This file started as the research/proposal; the Implementation section below records what was actually built.

## Goal
Run beets (music library manager / auto-tagger, https://github.com/beetbox/beets) against the Navidrome + Octo-Fiesta music library so newly downloaded tracks get MusicBrainz metadata written into the files. Library lives on the HAOS disk at `/media/music` (octo-fiesta: `map: media:rw`, `library_download_path: /media/music`); host reaches it at `~/haos_media/music` (transport = Samba per docs, unverified — user audits this claim).

## Placement decision (why a dedicated addon)
- **NOT octo-fiesta**: upstream-image-tracked (`build.json` pins `ghcr.io/v1ck3s/octo-fiesta:dev`, nightly `upstream-bump.yml` tracks dev SHA). Foreign fast-moving base + container recreation on every bump → kills multi-minute imports; custom pip layers fragile.
- **personal-app viable as a "hub" but real work**: config.yaml had NO `map:` (mounts nothing) at the time; would need `media:rw` + background worker + flock + NiceGUI status page + beets in a separate tool venv. Every beets tweak triggers a semantic-release. Only worth it if personal-app becomes the general personal-automation hub.
- **Dedicated `addons/beets/`** = chosen: small, stable, octo-fiesta skeleton (`init: false`, ENTRYPOINT run.sh), personal-app build pattern (HA base images).
- Hermes/n8n: no — agent container has no `/media` mount; n8n container has no beets deps. Hermes cron = observability layer (daily digest / failure watchdog reading the addon's log).

## Version research (verified via GitHub releases page + docs/changelog.rst, Aug 2026)
- **2.13.1 (Jul 29, 2026) = latest** — sdist man-pages fix only.
- **2.13.0 (Jul 27, 2026)** — big release: `quiet_fallback: asis`, `fetch_for_asis`, albumfields/itemfields, convert `--refresh`, keep_synced/`--no-keep-synced`, `rest_directory` + `-r/--write-rest`, `+=`/`-=` modify operators, metaflac support, `spotify:album:<id>` / `spotify:track:<id>` direct lookups, `cover_art_url`, `create_backup_before_migrations`.
- **Master (Unreleased)**: `duplicate_action: upgrade` (replace dup only if higher bitrate), `editor` config option, autotag distance no longer treats words containing "ft" ("draft","left","gift") as featuring-artist, date-range query endpoints swapped, dedupe counter fix.
- 2.12.0: lyrics SYLT (synced LRC) + USLT (plain) for ID3; ListenBrainz export import; Tidal flexible attrs + `beet tidalsync`; `--nomove`/`-M` override.
- 2.11.0: smartplaylist `splupdate` track counts; Tidal metadata plugin; TIT3 subtitle.
- 2.9.0: **Python 3.14 support**; `beet list has_cover_art:true`; remixer/lyricist/composer/arranger MBIDs.
- 2.8.0: multi-genre `genres` list (multiple genre tags; auto-migrated); lastgenre `cleanup_existing`; lyrics flexible attrs.

## Features the user likely missed (their music_server.md predates 2.13)
1. **`quiet_fallback: asis` + `fetch_for_asis` (2.13.0)** — their config had `quiet_fallback: skip` → non-matching Octo-Fiesta downloads got SKIPPED. `asis` imports them with filename-derived tags. Biggest win (streaming-sourced tracks rarely match MB). Chosen as the addon default.
2. **`create_backup_before_migrations` (2.13.0)** — auto-backup library.db before beets upgrades migrate schema. Essential for an auto-bumping addon.
3. **`duplicate_action: upgrade` (unreleased)** — strictly better than `remove`; NOT available in 2.13.1, so the addon exposes add|remove|skip and defaults to **skip** (non-destructive; the separate 12h `beet duplicates --delete` job handles real dupes deliberately — re-importing an already-imported album with `remove` can delete the files themselves).
4. **`genres` list (2.8.0)** — multiple genre tags; Navidrome reads multiple genres.
5. **`beet list has_cover_art:true` (2.9.0)** — find albums missing art.
6. **Lyrics SYLT/USLT (2.12.0)** — SKIP: octo-fiesta already writes .lrc via lrclib; double-handling.

## Alpine packaging facts
- `apk add chromaprint` provides the fpcalc binary (replaces the manual wget in their docs).
- `apk add ffmpeg` covers audio decoding for chroma/audioread; **no gstreamer** (only replaygain needs it).
- beets is pure Python; Pillow/pyacoustid have musllinux wheels — build verified at image build time.
- Install: `uv tool install --python 3.14 "beets[fetchart,lastgenre,embedart,titlecase,chroma]==${BEETS_VERSION}"` + `ln -s /root/.local/bin/beet /usr/local/bin/beet` — **Python 3.14 is the user's explicit choice** (over 3.12; beets supports it since 2.9.0; uv downloads a managed musl CPython at build time).

## IMPLEMENTED — addons/beets/ (commit d62abc1)
- **config.yaml**: `version: "2.13.1"` (= upstream version so HA shows updates), `init: false`, `map: media:rw` only, no HA API permissions. 15 options, resolved defaults: `library_path` `/media/music`, `watch_enabled` true, `watch_debounce_seconds` 300, `daily_incremental` true @03:00, `autotag`/`write`/`quiet` true, `quiet_fallback` **asis**, `duplicate_action` **skip**, `duplicates_enabled` true @12h, `navidrome_url/user/password` empty (disabled), `acoustid_apikey` empty. Arch: amd64+aarch64+armv7 (personal-app model; Alpine chromaprint covers armv7).
- **Dockerfile**: `ENV BEETS_VERSION=2.13.1` is the single source of truth the bump job sed-replaces; apk `bash curl jq ca-certificates chromaprint ffmpeg inotify-tools`; uv from astral install.sh; `uv tool install`; COPY run.sh + chmod + ENTRYPOINT.
- **run.sh** (the design that matters):
  - Options → writes `/data/beets/config.yaml` (`write: yes`, `copy: no`, `move: no`, `incremental: yes`, **`resume: skip`** — `resume: ask` would hang a TTY-less addon, `timid: no`).
  - **Startup full incremental sweep** (`beet import $LIBRARY --incremental`) catches files that arrived while stopped.
  - **Watch**: `inotifywait -q -r -e close_write,moved_to --format '%w%f' -t $DEBOUNCE` batches events for the debounce window then exits (natural batching + drain); filter to audio extensions (grep -iE), map to parent dirs, dedupe `sort -u | head -20`, pass as **bash array** (octo-fiesta paths contain spaces — never unquoted expansion).
  - **Daily incremental** at HH:MM (sleep 61 after firing to avoid same-minute re-trigger).
  - **Duplicates**: every N hours `beet duplicates -k title -k albumartist --delete`.
  - **Navidrome rescan**: optional, Subsonic API `startScan` with token auth (`salt` from /dev/urandom, `token=md5(pass+salt)`, `c=beets-addon`, `f=json`), base URL gets `http://` prefix if missing; warn-only on failure.
  - All jobs serialized by `flock -n 9` on `/data/beets/import.lock`; logs via `bashio::log.info` + append to `/data/beets/import.log`.
- **Persistence**: library.db + config + lock + logs in `/data` — survives restarts, included in HA full backups.
- **upstream-bump.yml job `bump-beets`**: latest from `https://pypi.org/pypi/beets/json` → `info.version`; compare vs config.yaml pin; sed `^version: "OLD"` + `ENV BEETS_VERSION=`; CHANGELOG.md regenerated from the GitHub release body (tags `v<ver>`, `awk` keeps max 9 old sections); commit `chore: bump beets X → Y` (conventional + non-releasing; main-release.yml is paths-gated so no spurious personal-app release).
- **Implementation gotchas hit** (full detail in SKILL.md Pitfalls): detect-secrets flagged the `navidrome_password`/`acoustid_apikey` schema NAMES → inline `# pragma: allowlist secret`; whole-tree mode-noise (644→755) → `core.fileMode false`; stale /tmp worktrees blocked `git branch -D` → `git worktree prune`; repo-local git identity was the phantom email → fixed repo-local; run.sh committed 100644 is the convention (Dockerfile chmod); pre-commit installed via `uv tool install pre-commit` + `pre-commit install --hook-type pre-commit --hook-type commit-msg` (binary at `/config/.local/bin`, not on PATH).

## Verified facts (from beets source/docs, final review turn)
- **`create_backup_before_migrations` is a BUILT-IN beets feature (2.13.0, DEFAULT yes)** — not a user script (the user initially assumed I'd written one; the addon never sets it). `beets/dbcore/db.py` `_before_migration_backup()` copies the DB to `<db path>-before-<table>-<migration>.bak` before each one-time migration (each migration runs once ever, tracked in the DB). One .bak per migration EVER run, never rotated; each = a full copy of library.db (the index — few MB, not the music) → negligible space, exactly right for an auto-bumping addon. Do NOT set the option — default already yes.
- **`fetchart.fetch_for_asis` (2.13.0, default no):** for asis imports (`quiet_fallback: asis` / `--noautotag`) fetchart only checks LOCAL art unless set yes. Existing art always wins — default `sources` starts with `filesystem`; `force`/`-f` needed to replace. The addon sets `fetchart: fetch_for_asis: yes` in the generated config (added in the README/amendment pass).
- **HA backups DO include addon /data:** the supervisor runs a per-addon "Building backup for add-on \<slug\>" stage (verified in supervisor logs) plus `/addon_configs`; `media`/`share` are in full backups but commonly excluded to keep archives small. So `/data/beets/*` (db, config, lock, growing import.log) is inside full backups — log growth bloats archives; truncate or rotate.
- **Navidrome startScan token-auth recipe** (used by run.sh): `salt=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')`; `token=$(printf '%s' "$PASS$SALT" | md5sum | awk '{print $1}')`; `curl -sf "$base/rest/startScan?u=$U&t=$T&s=$SALT&v=1.16.1&c=beets-addon&f=json"` (prepend `http://` if the URL option lacks it).
- **Research route for the beets changelog:** rendered changelog at `https://beets.readthedocs.io/en/stable/changelog.html` — web_extract with a SMALL char_limit saves the full text to `/config/.hermes/cache/web/*.md` with real newlines → `search_files` for `^## <version>` headers works. (The raw .rst via web_extract comes back JSON-escaped on one giant line — ungreppable.)

## Upcoming: user's misnamed-songs problem (old beets version)
User flagged songs mis-named by an old beets version — discuss after the PR. Investigation toolbox: `beet list -f '$albumartist - $album - $title' <query>`, `beet modify` (with `+=`/`-=` operators in 2.13), `beet rewrite`, `beet duplicates -k title -k albumartist`, `beet ls` + `has_cover_art`/`genres` queries; library.db lives at `/data/beets/library.db` (addon) vs host `~/.config/beets` (old). Interactive beets stays on the host (`personal-os-setup` docs); the addon is the automation layer.

## User workflow constraints (this session)
- Analyze/suggest FIRST; code only after explicit approval; PR only on explicit "open the PR". Branch cleanup: "Only main is the true branch" — user wants stale merged branches deleted (keep gh-pages + bot branches, explain why).
- Evidence discipline: user audits claims ("how did you know...?"). Cite file + tool; separate verified vs inferred.
- Approval gate: terminal + execute_code are gated — even read-only curl to public APIs can time out → research with web_extract/search_files/read_file; GitHub raw URLs sometimes fail on web_extract → HTML blob pages work; api.github.com contents = base64 (undecodable without code exec → use blob pages).
