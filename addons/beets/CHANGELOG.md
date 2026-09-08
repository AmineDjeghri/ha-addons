# Changelog

For full upstream release notes see the [official Beets releases](https://github.com/beetbox/beets/releases).

## 2.14.0 — 2026-09-08

# New features

- [duplicate_action](https://beets.readthedocs.io/en/stable/reference/config.html#duplicate-action): Add an `upgrade` option that replaces individual duplicate tracks only if the new copy has a higher bitrate, adds any genuinely new tracks, and keeps the album together rather than splitting it. The option is available both through configuration and from the interactive duplicate prompt. :bug: (#4471)
- [list command](https://beets.readthedocs.io/en/stable/reference/cli.html#list-cmd) Add `-l / --limit LIMIT` flag to the [list command](https://beets.readthedocs.io/en/stable/reference/cli.html#list-cmd) command to limit query results. :bug: (#5076)
- [PlexUpdate Plugin](https://beets.readthedocs.io/en/stable/plugins/plexupdate.html): Add `beet plexupdate --auth`, an interactive plex.tv login following Plex' traditional PIN authentication flow: the access token for the local server is stored in a token file. The manual `token` configuration option is now deprecated.
- The interactive import prompt now offers a "Rescan directory" choice for album tasks. It re-reads the album's directory from disk and re-runs the match, so files can be cleaned up (duplicates, junk) while the import is paused at the prompt, without restarting the whole [import command](https://beets.readthedocs.io/en/stable/reference/cli.html#import-cmd) run.

# Bug fixes

- [AURA Plugin](https://beets.readthedocs.io/en/stable/plugins/aura.html): Prevent multi-valued field filters from crashing with an `sqlite3.InterfaceError`.
- [AURA Plugin](https://beets.readthedocs.io/en/stable/plugins/aura.html): When sorting by `field`, do not exclude resources that have no value for `field`.
- [BPD Plugin](https://beets.readthedocs.io/en/stable/plugins/bpd.html): Fix `search` command when `any` field is used.
- [Convert Plugin](https://beets.readthedocs.io/en/stable/plugins/convert.html): Fixed convert plugin not taking into account the new format when determining the target path. :bug: (#1360)
- [Deezer Plugin](https://beets.readthedocs.io/en/stable/plugins/deezer.html): Detect compilations that Deezer credits to a single "main" artist instead of "Various Artists", so they are tagged as such rather than getting every track artist in the album artist field. :bug: (#4057)
- [Deezer Plugin](https://beets.readthedocs.io/en/stable/plugins/deezer.html): Singleton searches now use plain free text rather than `<title> artist:"<artist>"`. Deezer discards unquoted free text as soon as a query contains any `field:"value"` filter, so the old query was evaluated as `artist:"<artist>"` alone -- every track by the artist, in Deezer's own relevance order and truncated to `search_limit`. For artists with more releases than that window, the track being imported was never among the candidates offered.
- [Deezer Plugin](https://beets.readthedocs.io/en/stable/plugins/deezer.html): Track conversion no longer assumes the API sends both `contributors` and `artist`. The fallback to `artist` was evaluated even when `contributors` was present, so a track payload without `artist` raised `KeyError`. Albums were already guarded; this fixes the remaining call site. :bug: (#4339)
- [Discogs Plugin](https://beets.readthedocs.io/en/stable/plugins/discogs.html): Retry a search once when Discogs returns an invalid JSON response instead of immediately discarding all Discogs candidates.
- [Edit Plugin](https://beets.readthedocs.io/en/stable/plugins/edit.html): Item-only fields rejected from the album header remain available in per-track documents during interactive import when they are also configured in `itemfields`. :bug: (#6953)
- [import command](https://beets.readthedocs.io/en/stable/reference/cli.html#import-cmd): Restore the ability to import from tar and 7z archives. Both failed with an `'... object has no attribute 'infolist'` error because `tarfile.TarFile` lost its `ZipFileCompat` interface in Python 3 and `py7zr.SevenZipFile` exposes `list()` rather than `infolist()`. :bug: (#5664)
- [IPFS Plugin](https://beets.readthedocs.io/en/stable/plugins/ipfs.html): Fix `beet ipfs --play` option to invoke the Play plugin through its command interface.
- [Limit Query Plugin](https://beets.readthedocs.io/en/stable/plugins/limit.html) Deprecate the [Limit Query Plugin](https://beets.readthedocs.io/en/stable/plugins/limit.html) plugin in favor of the new `-l` / `--limit` flag for the [list command](https://beets.readthedocs.io/en/stable/reference/cli.html#list-cmd) command.
- [ListenBrainz Plugin](https://beets.readthedocs.io/en/stable/plugins/listenbrainz.html) and [LastImport Plugin](https://beets.readthedocs.io/en/stable/plugins/lastimport.html): Play counts are now matched more accurately. An exact MusicBrainz recording ID match is preferred when one exists, and titles are matched exactly (confirmed by the artist or album) before falling back to the previous substring-based matching. Previously all queries were combined, so a listen for "Song" also updated "Song (inst.)" or any other item whose title only contained the listened title.
- [Lyrics Plugin](https://beets.readthedocs.io/en/stable/plugins/lyrics.html): `beet lyrics` no longer crashes with an `AttributeError` on tracks that have no stored lyrics when `force` is enabled; a missing lyrics body is now treated as empty text. :bug: (#6860)
- [Lyrics Plugin](https://beets.readthedocs.io/en/stable/plugins/lyrics.html): LRCLib entries that carry no lyrics text at all, with both `plainLyrics` and `syncedLyrics` null while `instrumental` is `False`, are no longer considered matches. Previously such an entry was accepted and its null text propagated, raising `AttributeError: 'NoneType' object has no attribute 'splitlines'`. During an import this aborted the whole run rather than a single track. A null `plainLyrics` now also falls back to the synced lyrics instead of discarding them.
- [modify command](https://beets.readthedocs.io/en/stable/reference/cli.html#modify-cmd): Fix applying changes when choosing objects in interactive select mode. :bug: (#4880)
- [move command](https://beets.readthedocs.io/en/stable/reference/cli.html#move-cmd): Fix moving albums in interactive select/timid mode. :bug: (#2802)
- [Scrub Plugin](https://beets.readthedocs.io/en/stable/plugins/scrub.html): The scrub plugin now respects the `--nowrite` (`-W`) flag during import. Previously, `beet import -W` with the scrub plugin enabled would still remove tags from imported files; the plugin now skips scrubbing when `should_write()` returns `False`. :bug: (#6958)
- [Tidal Plugin](https://beets.readthedocs.io/en/stable/plugins/tidal.html): Pass the converted track duration as `length` so it contributes to the autotagging track-length distance instead of being silently stored as a `duration` flexible attribute.
- [Tidal Plugin](https://beets.readthedocs.io/en/stable/plugins/tidal.html): Restore catalog searches after TIDAL moved search queries from the request path to the required `filter[query]` parameter. :bug: (#6989)
- [Tidal Plugin](https://beets.readthedocs.io/en/stable/plugins/tidal.html): The `label` field no longer stores Tidal's raw copyright/rights-statement text verbatim. It's now normalized to a concise label name, stripping copyright markers, years, and corporate, licensing, and territorial boilerplate. Affects both album and track metadata. :bug: (#6796)
- [update command](https://beets.readthedocs.io/en/stable/reference/cli.html#update-cmd) no longer crashes when a plugin-added media field is stored as a flexible attribute. :bug: (#5580)
- A date range query written back to front (for example `added:2024..2020`) no longer crashes with an uncaught `ValueError`. The endpoints are now swapped, so such a range means the same as `added:2020..2024`.
- Add `editor` config option to allow users to permanently set their preferred editor, overriding `$VISUAL` and `$EDITOR` environment variables. :bug: (#6641)
- Autotagging distance calculations no longer treat ordinary words containing "ft" (such as "draft", "left", "gift", "craft") as a "featuring artist" suffix, which was silently making genuinely different titles/artists score as near-identical matches.
- Deduplicating a file whose name already ends in a counter of two or more digits no longer restarts the numbering: `track.10.mp3` now yields `track.11.mp3` instead of `track.1.mp3`. The counter was matched with `\.(\d)+$`, which captures only the final digit.
- Flexible attributes whose names contain uppercase characters (for example `beet import --set Tag_With_Uppercase=true`) can now be found by queries. Field names are lowercased when a query is parsed, so such attributes could never be matched; flexible attribute lookups now fall back to a case-insensitive key match. :bug: (#4565)
- Plugins built on `SearchApiMetadataSourcePlugin` ([MusicBrainz Plugin](https://beets.readthedocs.io/en/stable/plugins/musicbrainz.html), [Spotify Plugin](https://beets.readthedocs.io/en/stable/plugins/spotify.html), [Deezer Plugin](https://beets.readthedocs.io/en/stable/plugins/deezer.html) and [Discogs Plugin](https://beets.readthedocs.io/en/stable/plugins/discogs.html)) no longer send a search request when both the query text and the filters are empty. :bug: (#6862)

# Other changes

- [BPD Plugin](https://beets.readthedocs.io/en/stable/plugins/bpd.html): Replace the bundled Bluelet scheduler with Python's standard `asyncio` event loop.
- Docs: fix broken link to `test/dbcore/test_query.py` in `CONTRIBUTING.rst`; add crawler-blocking and unreachable sites to `linkcheck_ignore` in `docs/conf.py`.

---

## 2.13.1 — 2026-07-29

Initial release of the addon, pinned to Beets 2.13.1.

- Watch-based auto-tagging: new music in the library is imported within the debounce window
- Daily incremental full sweep as a safety net
- Optional duplicates check on an interval (report only, nothing deleted)
- Optional Navidrome rescan via the Subsonic API after imports
