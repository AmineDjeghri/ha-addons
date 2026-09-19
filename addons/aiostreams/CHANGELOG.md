# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

## nightly-79d64bb — 2026-09-19

- [fix(filters): stop forcing the digital-release info stream for single stale results (#1328)](https://github.com/Viren070/AIOStreams/commit/0c9f895c3844abe8fc4acca3aceb7eced97c8fd2)
- [feat(release-blocklist): add a master enable/disable toggle (#1330)](https://github.com/Viren070/AIOStreams/commit/3d7c536157829ba949658679c2e22fcc29f6b6ec)
- [feat(jellyfin): list playing sessions in /Sessions](https://github.com/Viren070/AIOStreams/commit/eb3a18284909ad552bc81fbb0e03d62371e614b7)
- [fix(jellyfin): take the playback runtime from the played source](https://github.com/Viren070/AIOStreams/commit/6a7ed9cc2091ac35085088039e04b5a8a309aa62)
- [feat(jellyfin): choose trackers per user](https://github.com/Viren070/AIOStreams/commit/b960e8d0eb1b1edfa6fd00504fb3ea5d995e9c3d)
- [fix(languages): resolve Bokmål and Nynorsk codes to Norwegian](https://github.com/Viren070/AIOStreams/commit/c8c81f987e925b48df05e7760a8316260e261d7d)
- [feat(linked-accounts): make the per-user link limit configurable](https://github.com/Viren070/AIOStreams/commit/cf80bb0c156aacd63509cadfa056765a7260cdf6)
- [feat(presets/bitmagnet): expose search mode option](https://github.com/Viren070/AIOStreams/commit/b1c145a5ce2e02e1601c54dafbec78fc980bee78)
- [fix(usenet): verify file contents at import](https://github.com/Viren070/AIOStreams/commit/e4d14281ee61d6e7dae754bf5bab9f15694700a6)
- [fix(debrid/torbox): align timeoutMs with stremthru (#1281)](https://github.com/Viren070/AIOStreams/commit/0ddf328bb63d21805832cc2f4deec3b347838925)
- [perf(builtins): skip .torrent download for pre-validated bad matches (#1259)](https://github.com/Viren070/AIOStreams/commit/479f809dbfdea79e28d8576c7d75e622ff3b879e)
- [fix(seanime-extensions/plugin): use ctx.fetch to prevent VM panics](https://github.com/Viren070/AIOStreams/commit/208e84067a54bb9204f247d6468d7653b75016c0)
- [fix(seanime-extensions/plugin): show results when not logged in to AniList](https://github.com/Viren070/AIOStreams/commit/743aa813fabf8b6c1e873d0e1be68996717519dc)
- [fix(seanime-extensions/plugin): load on Android and iOS servers](https://github.com/Viren070/AIOStreams/commit/99a5f479395238ddf52a8f99ed571660de944fee)
- [chore(seanime-extensions): release 0.10.2 (#1331)](https://github.com/Viren070/AIOStreams/commit/4fe9e2a8eb13092183a6cf9139ddc679b6a272e2)
- [fix(core/sync): make the vouched URL list the refresh set](https://github.com/Viren070/AIOStreams/commit/a6554f22eaace70e32dd304d4c3241e418642337)
- [feat(variants): add an insert instruction for list positions](https://github.com/Viren070/AIOStreams/commit/022b0e1488799a3758c2b10b6b630837b257cd21)
- [feat(variants): let [*] walk an object's values](https://github.com/Viren070/AIOStreams/commit/5afa43cd58fadca8cdfb0397ee01ab25dee7b43e)
- [fix(presets/gdrive): fix logo](https://github.com/Viren070/AIOStreams/commit/376d7163abcbeb24719a5a1a9188ae1d74f59a3c)
- [feat(presets): add penguplay preset](https://github.com/Viren070/AIOStreams/commit/ff01f94a0730443848938f967409700833e2ec2d)

[Compare 2001105...79d64bb](https://github.com/Viren070/AIOStreams/compare/2001105...79d64bb)

---

## nightly-2001105 — 2026-09-17

- [chore(build): scope the root and server tsconfig to their sources](https://github.com/Viren070/AIOStreams/commit/5d0b5d66dd2c6507845d2bc526ae433081bfeb71)
- [fix(stremio): stop logging the user's config on meta requests](https://github.com/Viren070/AIOStreams/commit/3bb0235a1d408954f67459046dcb890aa3fd1aa6)
- [chore(library): drop the fetched NZB list debug log](https://github.com/Viren070/AIOStreams/commit/7af885a90ff3465e1a092c80a40a29682cf3c516)
- [feat(debrid): carry StremThru's video hash through to streams](https://github.com/Viren070/AIOStreams/commit/c2800f10c4fa1611418fa0b9ad6ed9667aba52ac)
- [feat(media-info): keep each probed audio and subtitle track](https://github.com/Viren070/AIOStreams/commit/14ac79cdc1839f063b99bd7fc309d8ed20070f7e)
- [fix(dedup): take languages and tracks from a probed source instead of merging them](https://github.com/Viren070/AIOStreams/commit/e5b51820805fe03263abf2e5b1c1753e20d391be)
- [feat(formatter): add audioTitles and subtitleTitles fields](https://github.com/Viren070/AIOStreams/commit/09152cdaf276eadb8757f37d589aee05ea6a0775)
- [feat(sel): add audioTitle() and subtitleTitle() filters](https://github.com/Viren070/AIOStreams/commit/ec2ec032e71fb67c02c25f8f8f9cf13913cc302e)
- [perf(wrapper): skip re-validating a cached meta](https://github.com/Viren070/AIOStreams/commit/2dcf85c387af6f89c562dcc25c190ecd63acbc47)
- [fix(cache): make a forced write wait for a flush already in progress](https://github.com/Viren070/AIOStreams/commit/3feb11774971cf14e262a98fc4aee438eae22f64)
- [perf(distributed-lock): publish a lock's result only when a waiter is subscribed](https://github.com/Viren070/AIOStreams/commit/7afe5122e105a17a7519b878b460718702b58223)
- [perf(http): skip the recursion counter for requests that ignore it](https://github.com/Viren070/AIOStreams/commit/7dde970e58302cb251ba099c6478f20f050f2c28)
- [feat(db): make the PostgreSQL pool size configurable](https://github.com/Viren070/AIOStreams/commit/b8ecce70de58624e8eee5681822fd5cd7c34f48e)
- [feat(db): refuse a database migrated by a different build](https://github.com/Viren070/AIOStreams/commit/f28c6accc6017dc3591fab1844e55fe871216a17)
- [feat(settings): add an orderable multi-select field](https://github.com/Viren070/AIOStreams/commit/2f2e1f09711164d8c73b9f562380c597fd87c89c)
- [fix(ui): stop checkbox group rows resizing when toggled](https://github.com/Viren070/AIOStreams/commit/e39731060fe20bcf10991ad065a1103867edf2fd)
- [feat(ui): allow the tab indicator animation to be turned off](https://github.com/Viren070/AIOStreams/commit/1780c4874dbac4148015e6a5423c8159009d3f06)
- [fix(formatter): stop the formatter browser's tab indicator replaying](https://github.com/Viren070/AIOStreams/commit/4ebb7ce945506648e3ca198a62f996f0cdc45333)
- [feat(anime-database): answer many season and episode lookups from one read](https://github.com/Viren070/AIOStreams/commit/6c89dc063e6b50ddcfc6485ac96b44309360391b)
- [feat(watch-state): add the watch_state addon resource](https://github.com/Viren070/AIOStreams/commit/02d1d4e673ea0bd204ceb173281b7f8ebbcbb03a)

[Compare db8afbe...2001105](https://github.com/Viren070/AIOStreams/compare/db8afbe...2001105)

---

## nightly-db8afbe — 2026-09-16

- [chore: release 2.34.1 (#1288)](https://github.com/Viren070/AIOStreams/commit/c1d044c23b48acff9e5f0ce672c786797177e767)
- [fix(builtins): preserve zero seeder counts (#1320)](https://github.com/Viren070/AIOStreams/commit/23c774990216f3345d3caa8fa280851a4cdacdda)
- [feat(failover): add only-same-release failover toggle (#1319)](https://github.com/Viren070/AIOStreams/commit/3483fdadb2b2c110d6b1e69161a3672fd463f5ab)
- [chore: update header presets (#1318)](https://github.com/Viren070/AIOStreams/commit/b0b8aa314d10d870af8ffc5bc6c9d0d52017d516)
- [fix(frontend): clarify digital release filter description scope (#1310)](https://github.com/Viren070/AIOStreams/commit/346e8e0dbb7b271c50b19d29d5519b5b2586b277)
- [fix(builtins): compute torrent age from pubDate for torznab/prowlarr (#1306)](https://github.com/Viren070/AIOStreams/commit/f1daac30440f5ae37a9b82f5f458419e539e10ba)
- [fix(builtins/easynews-search): preserve season and episode separators (#1284)](https://github.com/Viren070/AIOStreams/commit/3686c3d2a07936f09e8cc704b8eae40192e73320)
- [feat(filters): add opt-in check to block results predating release/air date (#1312)](https://github.com/Viren070/AIOStreams/commit/50ad7ea1ba31a7eca9adcca3fd4e86e50ba172f4)
- [fix(server): expose Content-Range and Accept-Ranges to browser players (#1277)](https://github.com/Viren070/AIOStreams/commit/db8afbe66ddefcf7cca8731497d4f7c605e785e2)

[Compare 248d1c4...db8afbe](https://github.com/Viren070/AIOStreams/compare/248d1c4...db8afbe)

---

## nightly-248d1c4 — 2026-09-09

Initial add-on release, tracking the upstream `nightly` channel (upstream commit: "fix: coalesce concurrent addon resource requests via distributed lock (#1217)").

---
