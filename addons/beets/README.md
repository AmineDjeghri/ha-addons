# Beets

[Beets](https://beets.readthedocs.io/) is a music library manager and auto-tagger. This addon keeps your music library tagged automatically — it watches the library folder, imports and tags new music with metadata from MusicBrainz (plus cover art, genres and audio fingerprints), cleans duplicates, and can trigger a Navidrome rescan when done.

It is designed to complement **Octo-Fiesta**: tracks downloaded into `/media/music` are tagged within minutes, without cronjobs on the host.

## Installation

1. Add this repository to your Home Assistant add-on store: `https://github.com/aminedjeghri/ha-addons`
2. Install **Beets** and make sure your music folder is reachable via the `media` mount. The default `library_path` is `/media/music` — the same folder Octo-Fiesta downloads into.

## Add-on options

| Option | Default | Description |
|---|---|---|
| `library_path` | `/media/music` | Music library folder to watch and tag |
| `watch_enabled` | `true` | Watch the library and import new audio automatically |
| `watch_debounce_seconds` | `300` | Event batching window before importing (longer = more complete albums) |
| `daily_incremental` | `true` | Daily full incremental sweep as a safety net |
| `daily_incremental_time` | `03:00` | Time of the daily sweep (`HH:MM`) |
| `autotag` | `true` | Look up metadata on MusicBrainz during import |
| `write` | `true` | Write metadata into the files themselves |
| `quiet` | `true` | Non-interactive import — never prompts |
| `quiet_fallback` | `asis` | On no good MusicBrainz match: `skip` = leave files alone, `asis` = import with filename-derived tags (recommended for streaming-sourced tracks) |
| `timid` | `false` | Confirm matches before applying — only effective with `quiet` off (not recommended headless) |
| `incremental` | `true` | Skip albums already in the library |
| `duplicate_action` | `skip` | Duplicates during import: `add`, `remove` or `skip` |
| `duplicates_enabled` | `true` | Periodically check for duplicate tracks and report them (nothing is deleted) |
| `duplicates_interval_hours` | `12` | Interval for the duplicates check |
| `navidrome_url` | *(empty)* | e.g. `homeassistant.local:4533` — empty disables the rescan trigger |
| `navidrome_user` | *(empty)* | Navidrome user for the Subsonic API |
| `navidrome_password` | *(empty)* | Navidrome password (token auth) |
| `acoustid_apikey` | *(empty)* | AcoustID API key — enables the chroma fingerprint plugin (free at acoustid.org) |

## Beets configuration

On startup the addon generates `/data/beets/config.yaml` from the options above plus these fixed settings:

| Setting | Value | Why |
|---|---|---|
| `directory` | `library_path` option | Library root |
| `library` | `/data/beets/library.db` | Database persisted in addon data — survives restarts, included in HA backups |
| `import.write` | `write` option | Tags are written into the files |
| `import.copy` / `import.move` | `no` | Files are never copied or moved — only metadata changes |
| `import.autotag` | `autotag` option | MusicBrainz (and plugin) metadata lookup |
| `import.quiet` | `quiet` option | Non-interactive mode |
| `import.quiet_fallback` | `quiet_fallback` option | Behavior when no metadata source matches well enough |
| `import.timid` | `timid` option | Accept close matches automatically (no confirmation) |
| `import.incremental` | `incremental` option | Skip albums already in the library |
| `import.duplicate_action` | `duplicate_action` option | Duplicate handling during import |
| `import.resume` | `skip` | Never prompt to resume an interrupted import (no TTY in the addon) |
| `plugins` | `fetchart lastgenre embedart titlecase chroma` | Cover art, genres, embedded art, title casing, AcoustID fingerprints |
| `fetchart.fetch_for_asis` | `yes` | Fetch cover art from online sources even for `asis` imports |
| `acoustid.apikey` | `acoustid_apikey` option | Required for chroma fingerprint lookups |

## Updating options — restart required

- **Every option is read only when the addon starts**: the config file is regenerated and the schedules are set at boot. There is no live reload.
- To apply a change: open the addon → **Configuration** → edit → **Save** → **Restart**.
- After the restart, the log shows `Beets addon started — beets <version>, library: <path>` as confirmation.

## Updating Beets

- The `bump-beets` GitHub workflow (daily 06:00 UTC) checks PyPI for a new Beets release. When one is found, it bumps this addon's version and pins the new Beets version in the Dockerfile.
- You then see an **Update** button on the addon page. Clicking it rebuilds the container with the new Beets version.
- Before any database schema migration, Beets automatically backs up `library.db` (`create_backup_before_migrations`, default on) — updates are safe.
- Release history: [CHANGELOG.md](CHANGELOG.md).

## How it works

1. **Startup** — a full incremental import catches anything that arrived while the addon was stopped.
2. **Watch** — `inotifywait` batches filesystem events for the debounce window, then imports the parent directories of new audio files. `import.incremental: yes` keeps already-imported albums out of the loop.
3. **Daily** — a full incremental sweep at `daily_incremental_time` catches anything the watch missed.
4. **Duplicates** — `beet duplicates -k title -k albumartist` on the configured interval; results are logged, nothing is deleted.
5. **Navidrome** — after a successful import, the Subsonic `startScan` endpoint is called so new metadata appears immediately.

All runs are serialized with `flock` on `/data/beets/import.lock` — imports never overlap.

## Manual scan

Restart the addon: the startup step runs a full incremental import of the library, catching anything new.

## Notes

- Logs: addon **Log** tab + `/data/beets/import.log` (grows indefinitely — truncate it occasionally).
- `import.incremental: yes` and `duplicate_action: skip` are deliberately safe defaults for a headless environment.
