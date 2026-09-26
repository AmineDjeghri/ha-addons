# Genre tagging: lastgenre mechanics + whitelist behavior

Source-verified against `beetsplug/lastgenre/__init__.py` (beets 2.13.x).

## `genre_source` is a cascade, not an exclusive filter

The plugin's `sources` property expands the option into a fallback chain:

- `track` → `("track", "album", "artist")`
- `album` → `("album", "artist")`
- `artist` → `("artist",)`

The first stage that yields a non-empty resolution wins — stages don't merge. So `source: track`
still falls back to the album, then artist, lookup when no track-level last.fm page exists.

## Import writes genres in two passes per album

1. **Album pass** (once per album): resolves via the album's last.fm key ("artist - album"),
   writes the album's `genres` field.
2. **Track pass** (once per track): resolves via "artist - album - title", writes that track's own
   `genres` field.
3. With `track` in `sources`, album genres are **not** inherited down into tracks — each track gets
   its own independent resolution (cascading to album/artist only if its own track lookup is empty).

N songs in an album ⇒ 1 album lookup + N track lookups.

## Merge mechanics (`_get_genre`)

1. If existing genres are present and `force: no` → return them unchanged. Zero last.fm calls.
   Log label: `keep any, no-force`.
2. If `force: yes` + `keep_existing: yes` (combine mode) → merge existing + newly fetched, then run
   the **combined** list through alias normalization, canonical-tree expansion, and the whitelist
   filter, then cap at `count`.
3. Resolution stage order (when actually fetching): track (items only) → album → artist (album:
   "album artist", or a various-artists most-popular-track fallback) → the pre-existing genre (if
   it passes the whitelist) → configured static fallback → empty.

## ⚠ The whitelist filters *kept* existing genres too

Combine mode is not a pure union. `keep_existing` merges old + new, but the merged list still goes
through `_filter_valid`, which drops **any** genre — including a pre-existing one — not present in
the whitelist, then truncates to `count`. A genre already correctly on a file can disappear on the
next import simply because it isn't in the whitelist. **Raising `count` does not rescue a dropped
genre** — the whitelist filter runs before the truncation, not after.

`whitelist: false` is the only way to guarantee nothing already on a file gets dropped — the
trade-off is that unfiltered last.fm noise (artist names, years, moods, playlist titles) passes
through too.

## Reading the log

- `lastgenre: <obj>` (INFO) — `str(obj)`; an Album prints "artist - album", an Item prints
  "artist - album - title". Tells you which pass this line belongs to.
- `raw last.fm tags: [...]` / `existing genres taken into account: [...]` (DEBUG) — the two merge
  inputs; invisible at `-v`.
- `Resolved (<label>): [...]` (DEBUG) — invisible at `-v`, which is why genre lookups appear to
  produce no visible result in a `-v` log even though they worked. Label components:
  - `keep + ` prefix only when combine mode found existing genres to merge.
  - stage name (`track` / `album` / `artist` / `album artist` / VA fallback / `original fallback`
    / `cleanup`).
  - suffix `, whitelist` or `, any` — tells you live whether the whitelist filter is engaged for
    that resolution ("any" confirms `whitelist: false` took effect).
- `genres: +X / -Y` — the model-change diff on whichever object (album or track) actually changed.

## Undo reality

There is no beets "undo". Genre/tag writes are metadata-only (no file moves/deletes when
`copy`/`move` are off). Recovery from an unwanted rewrite means re-importing from a backup copy or
accepting the change — plan whitelist/mode changes as one-way unless you keep your own file backup.

## Whitelist-build recipe (`scripts/build-genre-whitelist.py`)

Produces a merged whitelist = beets' bundled `genres.txt` ∪ a curated supplement ∪ library-derived
real genres, deduplicated:

1. Fetch beets' bundled whitelist from its GitHub raw source.
2. Fetch a broader genre-name catalog (e.g. a maintained Spotify/EveryNoise-style list) — check the
   actual format before parsing (a plain numbered markdown list is common, not JSON).
3. Mine the library's own import log for raw last.fm tags actually seen, to catch regionally
   correct genres missing from both stock lists.
4. Tier the supplement: broad-catalog names not already covered, curated regional descriptors, and
   library-observed real genres — each pass filtered against a small junk blacklist (non-genre
   catalog entries like moods, activities, or moderation categories).
5. `sort -u` the final merge; deliberately exclude bare country/language names (they readmit the
   exact junk class the whitelist exists to filter).

The add-on merges the built supplement with beets' own list at container startup when
`genre_whitelist: true` (the default), writing the combined file to `/data/beets/` — beets accepts
only a single `whitelist:` file path, so the merge happens once per boot rather than at build time,
letting `genre_whitelist_extra` (an add-on option) append user-specific entries without a rebuild.

After changing whitelist settings, re-tag the existing library with `beet lastgenre -A` (per-track)
or `beet lastgenre` (per-album) — config changes only affect new imports otherwise.
