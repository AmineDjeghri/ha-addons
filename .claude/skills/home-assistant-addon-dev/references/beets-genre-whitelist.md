# Beets genre whitelist — knowledge bank (Aug 2026, PR #30)

## The problem
- `lastgenre.whitelist: false` = pure union — EVERY last.fm tag written, including:
  **artist names** (`Ryan Tedder`, `Iggy Azalea`), **years** (`2014`, `Best Of 2014`), **countries/languages** (`morocco`, `arabic`, `darija`, `french`), **moods** (`Sad`, `Love`, `Sexy`), **playlist junk** (`My Top Songs`, `Why On Earth Is This Just A Bonus Track`), **gibberish/offensive** tags.
- Stock beets whitelist (genres.txt, 1,568) is outdated: no `trap`, `drill`, `edm`, `dance`, `hyperpop`; and lacks regional genres the library needs (`north african`, `chaabi`, `moroccan pop`).
- **`rai`, `gnawa`, `french pop`, `arabic pop` ARE already in beets' base genres.txt** — verified by grep; don't re-add them to a supplement (dedup).

## last.fm raw-tag reality (this library: 993 unique tags, only ~199 real genres)
- Popular Western tracks: decent tags (consensus). Niche/world music: few tags, mostly country/language.
- **Arabic/North-African tracks tag as country/language ONLY** (`arab`, `arabic`, `morocco`, `maroc`, `marocain`, `maghrebi`, `moroccan`, `darija`) — no genre list can rescue them; with the whitelist on they correctly end up with **no genres** (honest caveat to give the user — last.fm has no genre data for them).
- The whitelist is the quality gate; `whitelist: false` shows exactly how raw the source is.

## The fix (implemented): merged whitelist file
`whitelist = beets genres.txt ∪ bundled genres-extra.txt ∪ genre_whitelist_extra` — one file, built at startup in run.sh when `genre_whitelist: true` (default):
```bash
cp "${WL_SRC}" /data/beets/genres-extra.txt      # WL_SRC = find ... beetsplug/lastgenre/genres.txt
cat /genres-extra.txt >> /data/beets/genres-extra.txt   # bundled supplement (Dockerfile COPY)
for extra in ${GENRE_WHITELIST_EXTRA}; do echo "${extra}" | tr '[:upper:]' '[:lower:]' >> ...; done
sort -u -o /data/beets/genres-extra.txt /data/beets/genres-extra.txt
GENRE_WHITELIST=/data/beets/genres-extra.txt
```
- beets natively accepts `whitelist: <path>` or `whitelist: false`; the addon's glue = merging default+extra into ONE file (beets takes one file only).
- After install: `beet lastgenre -A` cleans existing junk (combine mode re-resolves → non-whitelisted existing genres dropped from files).

## Build recipe (re-runnable: `scripts/build-genre-whitelist.py`)
1. Fetch beets genres.txt: `https://raw.githubusercontent.com/beetbox/beets/master/beetsplug/lastgenre/genres.txt`
2. Fetch Spotify/EveryNoise catalog gist: `https://gist.githubusercontent.com/andytlr/4104c667a62d8145aa3a/raw` — **it is a MARKDOWN list (`1. A Cappella`), NOT JSON** (the JSON version exists only in a gist comment); parse with `re.match(r"^\d+\.\s+(.+?)\s*$")`.
3. Mine the library's raw tags (complete data lives in `/data/beets/import.log`, NOT the supervisor buffer):
   ```bash
   docker exec app_<hash>_beets sh -c "awk -F\"'\" '/raw last.fm tags:/{for(i=2;i<=NF;i+=2) print tolower(\$i)}' /data/beets/import.log /data/beets/import.log.1 2>/dev/null | sort -u"
   ```
4. Tier the supplement: (a) Spotify names − beets − junk blacklist; (b) curated regional descriptors; (c) real genres from the user's log missing from both. Dedup everything against beets.
5. Small junk blacklist for Spotify entries (non-genres like `comic`, `drama`, `motivation`, `wrestling`, `reading`, `sleep`, `tribute`, `hollywood`…).
6. Offensive-grep false positive: `cumbia*` contains "cum" — check matches before purging.

## Regional descriptor list (tier 2 — meaningful for a French/Arabic library)
`north african, maghreb, maghrebi, maghreb pop, moroccan pop, algerian pop, arabic music, arabica, chaabi, african pop, afropop, amapiano, dembow, french rap, french rnb, pop latino, spanish rap, trap latino` (+ anything in Spotify already: `arabesk`, `maghreb`, `arab folk`, `persian pop`…).
Deliberately NOT included: bare country/language names (`morocco`, `arab`, `french`, `darija`) — they'd re-admit the junk.

## min_weight (offered, not yet an addon option)
`lastgenre.min_weight` (default 10) = minimum tag popularity; raise to 15–20 for stricter (junk tags are usually low-weight, filtered before the whitelist even runs).

## MusicBrainz 503 rate-limit lesson
- Full `incremental: no` re-scan = THOUSANDS of MB requests (search + chroma release lookups) via the threaded importer → bursts past MB's ~1 req/s per IP → `ResponseError('too many 503 error responses')` → affected albums fall to as-is (`Evaluating 0 candidates`).
- Incremental imports (a few albums) never hit this. **Never run full scans repeatedly**; re-match 503-affected albums with a TARGETED interactive run on just those folders (`docker exec -it … import /path/to/folder`).
- `threaded: no` would serialize requests (MB-safe, slower) — offered as an option, user hasn't taken it.
