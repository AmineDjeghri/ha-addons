# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

## nightly-00fb93a — 2026-09-26

- [fix(core): make trailer source and type optional](https://github.com/Viren070/AIOStreams/commit/19d7c1294fc2fec70755a4e5864485eb67793ab5)
- [refactor(ui): move the component kit into packages/ui](https://github.com/Viren070/AIOStreams/commit/74d1f313f0c0f0b4c033f1b9aed76b7a28a3080c)
- [refactor(jellyfin-web): move the web app into its own package](https://github.com/Viren070/AIOStreams/commit/e95334705b8c98b9772ddca7a131df49a3ea1600)
- [fix(jellyfin-web): define NEXT_PUBLIC_PLATFORM for the ui kit](https://github.com/Viren070/AIOStreams/commit/95a39f079391d804ab71654d6f9365513ff6834e)
- [fix(jellyfin-web): drop the scroll lock's scrollbar margin](https://github.com/Viren070/AIOStreams/commit/f6465ae79500df1a22dee16057dccf1d0d07b4bb)
- [feat(jellyfin-web): add the desktop app as a playback host](https://github.com/Viren070/AIOStreams/commit/5561530cf612657967daef7d1c5a2fe094ebb696)
- [feat(desktop): add a Windows shell with mpv under WebView2](https://github.com/Viren070/AIOStreams/commit/d084d8984416a4c16b270b1b4e5799382006c637)
- [feat(desktop): add the app icon](https://github.com/Viren070/AIOStreams/commit/5794e4429d55686928e0e2ab167be267b4dc61aa)
- [feat(jellyfin-web): add a standalone build that picks its server](https://github.com/Viren070/AIOStreams/commit/c0ab405fab73f41417ec87494d0ad6c8b57b5711)
- [feat(desktop): serve the standalone web app](https://github.com/Viren070/AIOStreams/commit/bde9066a2cf2a4ed8fa31956cdbc458eccd33a51)
- [feat(jellyfin): store users' playback preferences](https://github.com/Viren070/AIOStreams/commit/24db694d7ae4cb6f25abaaef1a17dd45bf83d126)
- [feat(ui): add a colour input](https://github.com/Viren070/AIOStreams/commit/4cffffe8d4f4f006627c82e3ee6591edc29d95d4)
- [feat(jellyfin-web): add a settings page](https://github.com/Viren070/AIOStreams/commit/feb8517d45ba5c8de841e7c5a03d9297cd8c174a)
- [feat(desktop): let the page set playback options and read versions](https://github.com/Viren070/AIOStreams/commit/991e738aa2f4e0c843fb1d42ef1fd619e85f7ee4)
- [feat(jellyfin): send each version's binge group](https://github.com/Viren070/AIOStreams/commit/59d9a90bf1647999e088610bb17e9ad33bf23eba)
- [feat(jellyfin-web): offer the next episode near the end](https://github.com/Viren070/AIOStreams/commit/75342eb5b749fff7ef44c5183368c51608e5c029)
- [feat(jellyfin): give the web app each version's own id in PlaybackInfo](https://github.com/Viren070/AIOStreams/commit/42b67228e53a62f8746467de270394a4d659440a)
- [feat(jellyfin-web): sync subtitles and switch versions in the player](https://github.com/Viren070/AIOStreams/commit/2c75b60a6d809e96fb012d275f8858ce4cde5c1a)
- [feat(core): add a cached autoplay attribute](https://github.com/Viren070/AIOStreams/commit/ae02dcdf231d99581b5d0da3cb468345a653ea3c)
- [refactor(jellyfin-web): pick the next version by binge group alone](https://github.com/Viren070/AIOStreams/commit/20864c117a197eacd85262a37b0043fa038a283b)

[Compare ff64174...00fb93a](https://github.com/Viren070/AIOStreams/compare/ff64174...00fb93a)

---

## nightly-ff64174 — 2026-09-25

- [feat(jellyfin): send undropped when a play picks a dropped show back up](https://github.com/Viren070/AIOStreams/commit/8ecd5773919a25937a6e57585574371b92ca2328)
- [feat(jellyfin): sign in with a PIN alone on the picker address](https://github.com/Viren070/AIOStreams/commit/53df9160eb7ce60cfce33e081107b87cfbd520cc)
- [docs(changelog): update post for v2.35](https://github.com/Viren070/AIOStreams/commit/a14cb02e9ee6f7a5e293f74510eef8475f84d484)
- [chore(presets/newznab): add more known newznab indexer presets (#1358)](https://github.com/Viren070/AIOStreams/commit/32a92bfa91ae79fe671c9232688afd98417e58c6)
- [fix(remuxdb): log lookup failures loudly instead of silently at debug (#1356)](https://github.com/Viren070/AIOStreams/commit/ff641743970304c4aacfb4b444fdbf9f0cd54c64)

[Compare 1442fc5...ff64174](https://github.com/Viren070/AIOStreams/compare/1442fc5...ff64174)

---

## nightly-1442fc5 — 2026-09-24

- [fix(usenet): look up by-id hashes outside the tree projection](https://github.com/Viren070/AIOStreams/commit/2235d536dd6edb8d53c5b883bbb8f7ce2b5002e8)
- [fix(frontend): size the version picker art by width](https://github.com/Viren070/AIOStreams/commit/04166b8abce48124d7d5b6b9245b0a65909d34af)
- [fix(frontend): render the season pill check as a right icon](https://github.com/Viren070/AIOStreams/commit/55ae08e9dd28c0ba8152a520242c70ea789adccf)
- [feat(jellyfin): pass external notice links to clients](https://github.com/Viren070/AIOStreams/commit/f3fc09c2ff56bd90e967a938bb8c8febe451e893)
- [feat(frontend): show notice titles, kinds and links in the version picker](https://github.com/Viren070/AIOStreams/commit/98772f647a63368b800e11d80eed8d249076a72d)
- [fix(jellyfin): fall back to the cast photo on person items](https://github.com/Viren070/AIOStreams/commit/ed9000218137dd9462dacf39b0d89881690d9792)
- [feat(jellyfin): require the password on picker addresses and aliases](https://github.com/Viren070/AIOStreams/commit/8c990f0ae0f55203956208d6f2c50f8019d06088)
- [fix(api): refuse encrypted passwords on the jellyfin routes](https://github.com/Viren070/AIOStreams/commit/f1b78df3246cd1c64e9f7ac5c783e0214f568cdc)
- [refactor(jellyfin): remove the variant path mounts](https://github.com/Viren070/AIOStreams/commit/c0e45ed0102f7f9db00278350bd4afa2e35f3422)
- [feat(frontend): sign in with the password on jellyfin picker addresses](https://github.com/Viren070/AIOStreams/commit/95e656d339b99013e585eb870769b09ebe7672eb)
- [refactor(jellyfin): remove the web landing page](https://github.com/Viren070/AIOStreams/commit/e99461e225f92584d689c4de5ed0e02ec477a0da)
- [feat(docs): add a gallery component](https://github.com/Viren070/AIOStreams/commit/917f7527026c02346ff987308493160beeac18cf)
- [docs(changelog): add web app screenshots to v2.35](https://github.com/Viren070/AIOStreams/commit/f42ebe3ea50e978388f377283c4fbf78896b794f)
- [docs(jellyfin): document the web app and password-only sign-in](https://github.com/Viren070/AIOStreams/commit/ea0b6c367e3bf8326d2223599b74a2b076c3c847)
- [fix(frontend): anchor popped sign-in views to the screen](https://github.com/Viren070/AIOStreams/commit/22575a170f5b62425de2e8ca26c1e555b6597ff0)
- [feat: remember config sign-ins by default](https://github.com/Viren070/AIOStreams/commit/1e405f4f8170c2e04b7a1c13c286136e85c15803)
- [feat(jellyfin): serve the web app with its own PWA manifest](https://github.com/Viren070/AIOStreams/commit/b508b2eb411a8558d7545bea5bae31f02b141d65)
- [feat(jellyfin): draw the web app edge to edge](https://github.com/Viren070/AIOStreams/commit/7a1853b4eed1955a13db5498042353ce469c35e5)
- [fix(frontend): blur the focused field on bottom nav taps](https://github.com/Viren070/AIOStreams/commit/28b0242624a92192cb604c5a2323aee883c2f6c3)
- [fix(frontend): mark the web app search box as a search input](https://github.com/Viren070/AIOStreams/commit/510a2b094c5c7daefcc8990824a26bbacecc1013)

[Compare 37be686...1442fc5](https://github.com/Viren070/AIOStreams/compare/37be686...1442fc5)

---

## nightly-37be686 — 2026-09-23

- [feat(formatter): add ::unique list modifier](https://github.com/Viren070/AIOStreams/commit/051a342a00b44d056aac72a755b6ef4bab42f5a7)
- [feat(formatter): apply ::replace to lists](https://github.com/Viren070/AIOStreams/commit/57dbc556424c21a7146cbee525924a69366293d0)
- [fix(core): revive DOMException from the lock cache](https://github.com/Viren070/AIOStreams/commit/105d9de813f528df841529851dbbbec8d72f45e9)
- [fix(jellyfin): play and sign in from the Android app](https://github.com/Viren070/AIOStreams/commit/e1aff12779a79c6f2c466eb0cf4a01ca2e14dc79)
- [fix(jellyfin): anchor next up on the last episode watched](https://github.com/Viren070/AIOStreams/commit/12a1735464eb8ec88289f0c312ed117793974a3c)
- [fix(jellyfin): keep episode ratings their own](https://github.com/Viren070/AIOStreams/commit/f11ab35fa218f878e9709d4fddfa994e4cf64167)
- [fix(jellyfin): read seasonPosters keyed by season](https://github.com/Viren070/AIOStreams/commit/99b62d5a8b5fb7ad3c660aba0df26b4e2db915fa)
- [feat(jellyfin): person details and filmography from TMDB](https://github.com/Viren070/AIOStreams/commit/85af525c57012d42142d964c64046a4f9fcb98e1)
- [feat(jellyfin): recommend similar titles from TMDB](https://github.com/Viren070/AIOStreams/commit/798cdbe630542d251529128b1347f30fd146282c)
- [feat(core): list and clear watch history](https://github.com/Viren070/AIOStreams/commit/d16ec82ba9b83fb32ba7e9944b5856719e0ad733)
- [feat(jellyfin): PINs for users](https://github.com/Viren070/AIOStreams/commit/90f1a24c87754c6e7a5765189d26a90a60370cf9)
- [fix(frontend): stop clipboard copies hanging in embedded browsers](https://github.com/Viren070/AIOStreams/commit/df0a3fe5e7c923a0169e742b0cf1def76ad7c50e)
- [feat(jellyfin): add a web app at /web](https://github.com/Viren070/AIOStreams/commit/5c116c49ffc3e697fa596f89c0d2cffd14e68f90)
- [docs(jellyfin): document PINs](https://github.com/Viren070/AIOStreams/commit/ff5bc4b2b18b27296bb0a2065caa27d9a2e2ee7e)
- [fix(frontend): keep loaded configs' values when status arrives late](https://github.com/Viren070/AIOStreams/commit/9fd6c671ad150df8c09275e9e9de9dfb7418915f)
- [docs(changelog): update post for v2.35](https://github.com/Viren070/AIOStreams/commit/3a956130b9a1d4e3c9e47d70aa08b209ade26176)
- [fix(metadata): update default user agent for skyhook](https://github.com/Viren070/AIOStreams/commit/a82a8c0c48ca3e90b84bd307d522f2a5eaeb178b)
- [fix(anime): match releases numbered in tvdb's season](https://github.com/Viren070/AIOStreams/commit/5d319f5b588124b28c969e5c2058c34f9092951f)
- [fix(remuxdb): update lookup endpoint to match RemuxDB's current API (#1353)](https://github.com/Viren070/AIOStreams/commit/a8a124e174ebeb44167b1d01de3ffb2c4d3355bb)
- [fix(watch-state): pick one row per series before limiting recent series](https://github.com/Viren070/AIOStreams/commit/b17c8293cb12c084edfa70c4c5a144e417fd69be)

[Compare 66f4330...37be686](https://github.com/Viren070/AIOStreams/compare/66f4330...37be686)

---

## nightly-66f4330 — 2026-09-22

- [feat(formatter): add user lists and field references](https://github.com/Viren070/AIOStreams/commit/b9bc591752803abc46a7c257e0903e7ac2bd16de)
- [feat(formatter): raise template limit and budget the cache](https://github.com/Viren070/AIOStreams/commit/3c3363b67bc66d7c4ef69f3863a2445e17885b42)
- [docs(env): regenerate webstreamr default url](https://github.com/Viren070/AIOStreams/commit/5742e1cf6a04c1aa7d47402847c5af8de25945fe)
- [fix(variants): bound the instructions one request can run](https://github.com/Viren070/AIOStreams/commit/9f477fa91a2331cb81e890c07071d6901392953e)
- [feat(jellyfin): show addon notices, errors and statistics as versions](https://github.com/Viren070/AIOStreams/commit/c998327e8889290f2a9fd9e8957f49d3909b0ede)
- [docs(guides/seanime): add tenji note and Default episode source step for plugin](https://github.com/Viren070/AIOStreams/commit/69f4054ac63e3d7b5740d3550d4192ff0893434a)
- [feat(schemas): add native epg fields](https://github.com/Viren070/AIOStreams/commit/e6daf4a8c99360bb0249b86cf9d484b973c3e827)
- [feat(jellyfin): play entries that have nothing to open](https://github.com/Viren070/AIOStreams/commit/4aba386bcc775e8c28a6e6ebaa1800d13bc9e10a)
- [fix(parser): detect hls urls with a query string](https://github.com/Viren070/AIOStreams/commit/b74283ff549ce39af73cf4a2be3d960f28f93309)
- [feat(jellyfin): mark channel sources live](https://github.com/Viren070/AIOStreams/commit/58a7929774fa1273095ff442b3b604a16609fbf0)
- [fix(jellyfin): keep live playback out of watch state](https://github.com/Viren070/AIOStreams/commit/1d429667ed27e02c8889af3be9d30885d9567494)
- [feat(core): tell whether a meta can be fetched](https://github.com/Viren070/AIOStreams/commit/057b3b1eb1e7dfc75fa9fc7fb316bfa1633c0de6)
- [feat(jellyfin): decide playable entries before a sweep lands](https://github.com/Viren070/AIOStreams/commit/1ad2f1f0f158e2a109721bc47d08f03a245e6a4f)
- [perf(db): raise the config key cache ttl to 24h](https://github.com/Viren070/AIOStreams/commit/743da3d06a8976747d1c48e4ddbeaedee29152f2)
- [perf(parser): cache title lists by identity and prune title matches](https://github.com/Viren070/AIOStreams/commit/3f88925ccbdf6d41a794fa23e43ff790dad26904)
- [perf(config): skip save-time variant validation on read paths](https://github.com/Viren070/AIOStreams/commit/fc55a2c79fecaf061aae4d3cc98ed72f13e5ed7b)
- [perf(builtins/library): time-slice the library scan](https://github.com/Viren070/AIOStreams/commit/9713fd0825e8fc6652bffcd956ad0f6ae8c5bd32)
- [fix(streams): stop suppressing statistics across an await](https://github.com/Viren070/AIOStreams/commit/3e2eac03d220c89d5804f972b00173fc9725c523)
- [perf(streams): time-slice the filterer passes](https://github.com/Viren070/AIOStreams/commit/797eae0299143af480a412385aafdda859ee792e)
- [perf(parser): cache the title regex and pattern entries](https://github.com/Viren070/AIOStreams/commit/1c281843068dc2b20274ec4070869c926879bf41)

[Compare ce27dc1...66f4330](https://github.com/Viren070/AIOStreams/compare/ce27dc1...66f4330)

---

## nightly-ce27dc1 — 2026-09-20

- [fix(anime-database): preserve IMDb identity for episode mappings (#1301)](https://github.com/Viren070/AIOStreams/commit/e2224d9aa1bcf22bb9e839e1b096017db2a6d656)
- [feat(frontend): show max versions in primer](https://github.com/Viren070/AIOStreams/commit/a470d94163341e19d0ca39291bafa31db173c918)
- [feat(jellyfin/segments): support movie end credits from IntroDB](https://github.com/Viren070/AIOStreams/commit/5ef9d5160017aa4ccbf8d84aa774616593d3667c)
- [feat(jellyfin/segments): resolve IMDb ids for TMDB-keyed movies](https://github.com/Viren070/AIOStreams/commit/b107a108d78dc4f813d942541559f35b86fee312)
- [fix(templates): detect placeholders in any field and type inputs by field](https://github.com/Viren070/AIOStreams/commit/f62d7eebda245dcff2dd9d4a91ab9181cdca8239)
- [fix(anime): scope imdb hints and fix episode mapping](https://github.com/Viren070/AIOStreams/commit/cdaee68dbf5f6bb3bc384dfceff1134d6747411f)
- [feat(jellyfin): add api keys](https://github.com/Viren070/AIOStreams/commit/5a95a5fbfd4669f3d220b6d4c9a12f87363b26df)
- [feat(jellyfin): enrich external subtitle tracks](https://github.com/Viren070/AIOStreams/commit/0f5ad0d580933b511aca73f8ad30a5c20681ac76)
- [fix: loosen trailer type schema](https://github.com/Viren070/AIOStreams/commit/443649612d91e58efcfb2d96acd602f9725e6664)
- [fix(jellyfin): don't paginate on search](https://github.com/Viren070/AIOStreams/commit/ce27dc1745f59654148f2f197685b812d761ed78)

[Compare 79d64bb...ce27dc1](https://github.com/Viren070/AIOStreams/compare/79d64bb...ce27dc1)

---

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
