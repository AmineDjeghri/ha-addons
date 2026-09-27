---
name: beets-addon-dev
description: Develop and tune addons/beets — the beets auto-tagger add-on for the Navidrome music library, including its genre-tagging behavior and options.
metadata:
  hermes:
    origin: repo:ha-addons
---

# Beets Add-on

`addons/beets/` is a from-scratch, PyPI-tracked add-on wrapping the [beets](https://beets.io) music
auto-tagger for a Navidrome-served library. It watches a media library, imports new files, tags
them via MusicBrainz/AcoustID, fetches genres via last.fm, and optionally triggers a Navidrome
rescan. General add-on packaging conventions (versioning, mounts, CI) live in the
`home-assistant-addon-dev` skill — this skill covers what's specific to beets.

## Trigger Conditions
- Working on `addons/beets/` (`config.yaml`, `run.sh`, `Dockerfile`).
- Debugging genre-tagging behavior (why a track got/lost a genre, whitelist filtering).
- Tuning matching/import options (`quiet_fallback`, distance weights, duplicate handling).

## Architecture

- `build.json` → HA base images (Alpine, all arches), `init: false`.
- Dockerfile: installs `chromaprint` (provides `fpcalc` for the chroma plugin), `ffmpeg`, then
  `uv tool install` beets with extras (`fetchart,lastgenre,embedart,titlecase,chroma`) — see
  `versioning-patterns.md` in `home-assistant-addon-dev` for why the PyPI index flags are
  mandatory on HA's builder.
- `run.sh`: renders `/data/beets/config.yaml` from options once at startup (no live reload — a
  saved option only applies after a restart), runs a full incremental import, then loops: a daily
  full sweep plus an `inotifywait`-debounced watch (default 300s) that imports the parent
  directories of newly-closed audio files. Every beets invocation runs under a `flock` so imports
  never overlap.
- Persistence: `/data/beets` (library.db, generated config, import log, lock) — included in HA
  full backups.
- Manual re-scan = restart the add-on (a file-trigger mechanism was considered and rejected —
  restart is the supported path).
- Duplicate handling is report-only (`beet duplicates`) — never `--delete`.

## Headless-mode constraints

- `quiet: yes` is mandatory (no TTY) — `resume` is fixed to `skip` and `timid` is meaningless
  under `quiet: yes` (both would hang on stdin otherwise).
- `quiet_fallback` decides what happens to a weak/no match: `skip` or `asis` (asis writes
  filename-derived tags instead of skipping — the useful default when the source library has poor
  metadata coverage).
- `incremental: false` means a **full re-scan on every sweep** — safe for a one-off re-tag pass,
  but leave it `true` normally or you'll re-hammer MusicBrainz's ~1 req/s rate limit on every
  restart (see "MusicBrainz 503s" below).

## Matching semantics

- Quiet mode auto-applies only *strong* matches (`distance < strong_rec_thresh`); anything weaker
  falls to `quiet_fallback`. `strong_rec_thresh` is a **distance**, not a similarity score — lower
  is stricter (0.05 ≈ 95% similar).
- An AcoustID fingerprint resolving to an exact release ("ID match") counts as strong regardless of
  computed distance — that's why fingerprint-resolvable albums fully tag while search-fallback
  albums (poor metadata, partial-album folders) fall to `asis`.
- "0 of N items replaced" after a full match is success, not failure — the files were already
  tagged identically.
- Distance-weight defaults penalize things that a rip from a streaming source commonly trips
  (`missing_tracks`, `data_source`, `country`, `media`) — re-check any custom weight override
  against beets' *current* `config_default.yaml` before assuming it still matches upstream
  defaults; they change across versions.
- **MusicBrainz 503s under a full re-scan:** a full (`incremental: no`) re-scan of a large library
  makes thousands of MB requests via the threaded importer and can burst past the ~1 req/s per-IP
  limit, dropping affected albums to `asis`. Incremental imports are small enough to never hit
  this. Recovery is a *targeted* interactive re-import of just the affected folders — never another
  full scan. `import.threaded: no` serializes lookups and avoids the burst entirely, at the cost of
  slower full imports.

## Genre tagging

Full mechanics (source-cascade behavior, per-track vs per-album application, log-line semantics,
the whitelist-filters-existing-genres gotcha) are in `references/genre-tagging.md` — read it before
changing any `genre_*` option or debugging a "genre didn't apply" report. Key facts:

- `genre_source` (`album`/`artist`/`track`) is a **cascade with fallback**, not an exclusive
  choice — `track` still falls back to album, then artist, if no track-level last.fm page exists.
- `genre_mode` maps to two lastgenre knobs: `keep` = `force: no` (existing genres untouched, zero
  lookups), `overwrite` = `force: yes`, `combine` = `force: yes` + `keep_existing: yes` (merges
  existing + fetched).
- **The whitelist filters `keep_existing` genres too** — combine mode is not a pure union. A
  genre already on the file that isn't in the whitelist gets silently dropped on the next import.
  Raising `genre_count` does not rescue it (truncation happens after the whitelist filter).
- `genre_whitelist: false` is the pure-union escape hatch — nothing gets filtered, but junk tags
  (artist names, years, moods, playlist names) pass straight through from last.fm.
- The shipped `genres-extra.txt` supplement (built by `scripts/build-genre-whitelist.py`, merged
  with beets' bundled whitelist + a per-track library-derived tier) exists specifically to keep
  real/regional genre names that beets' stock whitelist lacks, without opening the floodgates to
  last.fm noise. Re-run the script rather than hand-editing the merged file.

## Known pitfalls

- **`fetchart.sources` must be a YAML *list*, not a scalar.** A scalar (`sources: coverart itunes
  filesystem`) fails beets' `sanitize_pairs` and kills the **entire fetchart plugin** — silently:
  the error prints once per invocation, imports continue, but no cover art is ever fetched. This
  class of bug (a valid-looking scalar where the schema wants a list) is common in beets plugin
  configs — check the plugin's own config reference when a plugin silently no-ops.
- **A regenerated `/data/beets/config.yaml` overwrites hand-edits on every startup.** Route config
  changes through add-on options, not by editing the file directly.
- **A plugin command needs its plugin in the generated `plugins:` list.** `beet duplicates` from a
  cron-style job fails with "unknown command" if `duplicates` isn't enabled.
- **First import on a fresh `/data` is a full import, not incremental** — `incremental` only skips
  albums already in the DB, and an empty DB means everything is new. A large library can take
  hours under MusicBrainz's rate limit; don't diagnose "stuck" from a quiet log window alone.
- **Import log verbosity:** `-v` gives readable per-album lines (lookup, match, genre, art); `-vv`
  adds root-logger `Sending event:` hook-trace noise that isn't useful and should be filtered from
  the log, not surfaced as "more detail".

## Linked Files
- `references/genre-tagging.md` — lastgenre cascade/merge mechanics, whitelist-filtering gotcha,
  log-line reference, and the whitelist-build recipe.
- `scripts/build-genre-whitelist.py` — re-runnable builder for the merged genre whitelist
  (beets' bundled list + a curated regional/real-genre supplement + library-derived tags).
