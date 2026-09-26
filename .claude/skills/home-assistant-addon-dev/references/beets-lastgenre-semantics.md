# beets lastgenre: album vs track semantics (source-verified, beets 2.13.1)

Answers "do genres get applied to the album or the song?" — **BOTH**, in a cascade.
Verified against `beetsplug/lastgenre/__init__.py` (beets master, 2.x) + live addon
options (slug <hash>_beets, Aug 2026) + the user's import log.

## Config surface (addon options → /data/beets/config.yaml lastgenre block)
- `genre_source` → `lastgenre.source` (default `track`)
- `genre_mode` → `lastgenre.force` + `keep_existing` (keep = no/no, overwrite = yes/no, combine = yes/yes)
- `genre_whitelist` → `lastgenre.whitelist`; `genre_count` → `lastgenre.count` (12)

## `source` is a CASCADE, not a filter
The plugin's `sources` property expands the option:
- `track`  → `("track", "album", "artist")`
- `album`  → `("album", "artist")`
- `artist` → `("artist",)`

First stage that yields a non-empty resolution WINS (no cross-stage merging).
So `source: track` STILL performs album and artist lookups as fallbacks — only the
track lookup is tried first. A track with no last.fm page falls back to the album
page, then the artist page.

## Import processing = TWO passes per album
`_process_album` (album imports):
1. **ALBUM pass (once):** `_fetch_and_log_genre(Album)` → last.fm key "artist - album"
   → merged into the ALBUM's `genres` field (beets 2.x field name; 1.x: `albumgenre`).
   INFO log line: `lastgenre: Addison Rae - Fame Is A Gun`.
2. **TRACK pass (per item):** each song processed individually → key "artist - album - title"
   → merged into THAT track's `genres` field. INFO log line:
   `lastgenre: Addison Rae - Fame Is A Gun - Fame Is A Gun`.
3. `obj.try_sync(write=…, inherit="track" not in self.sources)` — with track in sources,
   album genres are NOT inherited down into the tracks.

N songs ⇒ 1 album lookup + N track lookups (each cascading to album/artist if empty).

## Reading the log lines
- `lastgenre: <obj>` = INFO `str(obj)` — Album str = "artist - album"; Item str = "artist - album - title".
- `raw last.fm tags: [...]` / `existing genres taken into account: [...]` = DEBUG, the two merge inputs.
- `Resolved (<label>): [...]` = DEBUG. Label construction:
  - `keep + ` prefix ONLY when force AND keep_existing (combine) AND existing genres exist.
  - stage name: `track` / `album` / `artist` / `album artist` / `multi-valued album artist` /
    `most popular track` (VA albums) / `original fallback` / `cleanup`.
  - suffix `, whitelist` (whitelist on) or `, any` (off).
  - `keep any, no-force` = force:no with existing genres → existing returned AS-IS, zero last.fm calls.
- `genres: +X / -Y` = `ui.show_model_changes` diff of the `genres` field on the object being
  processed — tells you whether the ALBUM or a TRACK changed.

## Merge mechanics (`_get_genre`)
1. Existing genres AND NOT force → return existing unchanged ("keep any, no-force"); no last.fm request.
2. force+keep_existing → keep_genres = existing (lowercased); combine old+new → alias normalization
   → canonical-tree parents (whitelist-gated) → `_filter_valid` whitelist check → title case → cap at `count`.
3. Stage order: track (Items only) → album → artist (Item: `artist`; Album: `album artist`,
   multi-valued `albumartists`, or VA → most-popular track genre via `_fetch_va_genres`) →
   original fallback (keep_existing keeps original if it passes the whitelist) → configured
   fallback → empty list.

## Worked example (Addison Rae - "Fame Is A Gun", user's log Aug 2026)
- Album pass: raw album tags electropop/house/synth-pop/dance-pop/deep house/chill house
  (+ noise: addison/2025), 4 existing album genres → `Resolved (keep + album, whitelist)`:
  8 genres → album genres `+Chill House +Dance-Pop +Deep House +House`. Album ONLY.
- Track pass ("Fame Is A Gun"): raw track tags = the same 4 existing → `Resolved (keep + track, whitelist)`: 4 → no visible change on the track.
- The "+4 new genres" from that log landed on the ALBUM, not the songs.

## Navidrome consequence
Track `genres` field → per-song genres in the UI; album `genres` field → album genre on the
album view. YouTube/Live downloads carry no embedded genres, so every track gets a real lookup,
falling back to album/artist for live bootlegs without a last.fm track page.
