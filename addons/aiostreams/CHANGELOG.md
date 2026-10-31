# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

## nightly-c358754 — 2026-10-31

- [feat(watch-state): default the minimum resume percentage to 0](https://github.com/Viren070/AIOStreams/commit/c723b85d2f21fd3ebcb73c29f123dcf4feaa392c)
- [fix(watch-state): skip a buffered tick once the title was played after it arrived](https://github.com/Viren070/AIOStreams/commit/a11746de77e752219e4ab5e36a576bd7f1839c09)
- [fix(jellyfin): date progress reports on arrival and drop ones after their stop](https://github.com/Viren070/AIOStreams/commit/e6c58c36668268830879b76e38e02e3bf8ea1522)
- [fix(jellyfin): send UserDataChanged to sockets on every replica](https://github.com/Viren070/AIOStreams/commit/47e767b2669aa35a38e63880c9cd1803921a3f80)
- [docs: list the player's chapter sheet hooks](https://github.com/Viren070/AIOStreams/commit/65b4202cd8d3668b269de7a9b94b516d287b9e26)
- [fix(core): read and send archive parts as [url, bytes] pairs](https://github.com/Viren070/AIOStreams/commit/e2292d18ee318c9af0371b2eaaf903b2bfefed49)
- [feat(web): show the player's chapters in a sheet with pictures](https://github.com/Viren070/AIOStreams/commit/3a7d2f2ef017ddaf5b01dc116396d83588f8c312)
- [fix(core): send no playback events to a pull-only watch-state addon](https://github.com/Viren070/AIOStreams/commit/71c71b995a54f523dd0db343afb01be597d3fac2)
- [docs: add an addon development guide](https://github.com/Viren070/AIOStreams/commit/011fe521d5c689b825c21cbe2345415530806ec7)
- [chore(docs): update next version](https://github.com/Viren070/AIOStreams/commit/a925e61b8b29013e97dca37bc10bbb9fcf576a37)
- [chore(core): switch to @aiostreams/release-parser](https://github.com/Viren070/AIOStreams/commit/72e73e0b90c6e9496ab24a91fee3b8862a321802)
- [chore: point eslint-plugin-import references at its current lockfile entry](https://github.com/Viren070/AIOStreams/commit/ea63043ee42f6cc956286dc9483ab3d989140818)
- [chore(l10n): update German translation](https://github.com/Viren070/AIOStreams/commit/43437abfdefc0a38c6820143d80fe6ae893e5950)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/ef5e53a001b717098100f8e72f70b286a5316af0)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/1dccb259fffcb7f1be7d32d0d03e4127eed82e4b)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/7c5df0e99f164e88dcd56b4d4484fd0df6ffdebc)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/2bc2671f4c4a6cff5ae91668cfcc46d8155a87c3)
- [chore(l10n): update Malay translation](https://github.com/Viren070/AIOStreams/commit/2a8379b1e659c3f0051725a43f5ffac7afeb0100)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/5d336990cfac9efd71c01813bf5aa03557882d5c)
- [Merge pull request #1690 from Viren070/weblate-aiostreams-web-app](https://github.com/Viren070/AIOStreams/commit/c358754b0ae4758d034badf8618de6fdb7fa9333)

[Compare 3474c94...c358754](https://github.com/Viren070/AIOStreams/compare/3474c94...c358754)

---

## nightly-3474c94 — 2026-10-30

- [docs: rewrite the introduction and home page around the addon and the apps](https://github.com/Viren070/AIOStreams/commit/a8958c662aeec32104a5910a63fac0597501c815)
- [docs: replace the TorBox Search FAQ with where it went](https://github.com/Viren070/AIOStreams/commit/bb3218309360d7648ca10e58239468684b40e071)
- [chore(frontend): update the About page's default description](https://github.com/Viren070/AIOStreams/commit/dfa2ac3ea733bc39eb18a227068aed3555156f91)
- [docs: rewrite the README around the addon and the apps](https://github.com/Viren070/AIOStreams/commit/6cf6bdee5aa7c423a4a21216c61e3f7b75405928)
- [docs: describe the formatter's live preview](https://github.com/Viren070/AIOStreams/commit/acfbb14c7af8950cd8ba2662c0e3d9505045d932)
- [docs: update the setup guide for the new setup wizard and the app](https://github.com/Viren070/AIOStreams/commit/864cbf445dc91d4e527e270199fe22c764618d40)
- [docs: rewrite the FAQ and troubleshooting pages](https://github.com/Viren070/AIOStreams/commit/6b1fc245893b9004c18dc8c0a3ba858ea96c1bfa)
- [docs: add updating and keeping an instance private to the deployment guide](https://github.com/Viren070/AIOStreams/commit/b0c2edd0b75b107ff481a88cba35d9c2f1bdcecf)
- [chore: update the default addon description](https://github.com/Viren070/AIOStreams/commit/7d502368824e6722a888ad54e3530e20d28240ec)
- [build(android): update libs for subtitles that slide every frame](https://github.com/Viren070/AIOStreams/commit/0673be8deb6e2388530994236baf3a6041647ed2)
- [build(desktop): update libs for subtitles that slide every frame](https://github.com/Viren070/AIOStreams/commit/ee82aa43a9b17efef4b69f18f034705ae6c44498)
- [fix(android): read every object of a PGS display set](https://github.com/Viren070/AIOStreams/commit/a6151ed8e1add0d07b5d7d3abace2fc731c7fde6)
- [fix(android): reset libass's frame time for each file](https://github.com/Viren070/AIOStreams/commit/1a06f52e87907a7eefcb58df82597d89abda049c)
- [feat(android): draw ExoPlayer's text subtitles with libass](https://github.com/Viren070/AIOStreams/commit/544a3d70df0a33548dbf37fa5afe8123a9e05146)
- [feat(android): move ExoPlayer's subtitles without restyling them](https://github.com/Viren070/AIOStreams/commit/0ef3ac7e6e54f8528d579d6300b5297c3b0bbe95)
- [feat(android): set mpv's sub-pos unrounded](https://github.com/Viren070/AIOStreams/commit/6cee1b919f5462156a17b7f571720476420b8b92)
- [feat(android): prefer the fastest refresh rate while the page's controls show](https://github.com/Viren070/AIOStreams/commit/aac2d5fec19b47a086d128510223f9a6fb03cb36)
- [feat(desktop): set mpv's sub-pos unrounded](https://github.com/Viren070/AIOStreams/commit/95d0521d4b3d3bb54b463a7b1b45c4f3b6638145)
- [feat(web): ease the subtitle height every frame](https://github.com/Viren070/AIOStreams/commit/e7f665d0ed1e8680f6cb83b8266ea06849aae3ef)
- [feat(web): slide the subtitle the page draws above the controls](https://github.com/Viren070/AIOStreams/commit/086f39dc9a1b2cdb4e183c2f5c9545d11844a70f)

[Compare f959e42...3474c94](https://github.com/Viren070/AIOStreams/compare/f959e42...3474c94)

---

## nightly-f959e42 — 2026-10-29

- [fix(media-info): round probe durations to whole milliseconds](https://github.com/Viren070/AIOStreams/commit/738d09f3ec8768a7df7755e9c669637cd8e25be9)
- [fix(watch-state): round positions and durations before storing them](https://github.com/Viren070/AIOStreams/commit/a1c1ba63377c7cafd983d80214d311686d45db3e)
- [fix(jellyfin): read the socket token from auth headers too](https://github.com/Viren070/AIOStreams/commit/efaa2daab291e89d8bc9f22f1954a13523b3db05)
- [fix(media-info): upsert a batch in key order](https://github.com/Viren070/AIOStreams/commit/42913c6dbc1edad26cc1c18390505a9aa6654f4b)
- [fix(media-info): only relist a hidden row when its record changes](https://github.com/Viren070/AIOStreams/commit/611458d203ed569254d73f19f184c3004dc04caf)
- [fix(jellyfin): upsert id mappings in key order, skipping fresh ones](https://github.com/Viren070/AIOStreams/commit/e597638d04dee4e33dd6ab3fb169bae10290baca)
- [perf(web): size artwork for the pixels the page is drawn at](https://github.com/Viren070/AIOStreams/commit/f0e9c7fce4d4237106639deeb1b41cdf3a6238c9)
- [fix(web): let React listen for transition and animation ends](https://github.com/Viren070/AIOStreams/commit/8192eebd1260ac4de2c16587b0d4c249edefcab7)
- [feat(web): scrub with a TV remote through a row of pictures](https://github.com/Viren070/AIOStreams/commit/2862314d811632853612e9b6d8d50c911334643e)
- [feat(native): render thumbnails 480 pixels wide](https://github.com/Viren070/AIOStreams/commit/25ed24bb44a8119b44683e8569e01e5fbd6a6b26)
- [perf(core): index FULL_LANGUAGE_MAPPING by code and name](https://github.com/Viren070/AIOStreams/commit/0bb34e840f2f4e98757e8dc047d4b83f261bf1f4)
- [perf(core): skip parseLockResult's reviver without a flattened error](https://github.com/Viren070/AIOStreams/commit/aa3ee398fa6e1622357cfbd192ab7e8420f0eb23)
- [perf(core): skip re-parsing a SEL result that's just the input streams](https://github.com/Viren070/AIOStreams/commit/7d039dd80b61335d9356ae5059286a40c7369845)
- [fix(web): size TV artwork from the screen and layout widths](https://github.com/Viren070/AIOStreams/commit/0a92ccefe00fee1effc6cb20e62daa64b0681f4c)
- [feat(web): hide languages under half translated](https://github.com/Viren070/AIOStreams/commit/7e7d3adfc0dc67feaa8b1a66a9a851e9aad01107)
- [docs: say when the apps offer a language](https://github.com/Viren070/AIOStreams/commit/08682175b062f4c1a1de9480548f7a3cf8e5e15c)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/21a69a5395b4b799c352a775cf347db85eb9479c)
- [chore(l10n): add Dutch translation](https://github.com/Viren070/AIOStreams/commit/3c9d0b6ebfa811392dc9e1a0ec3bbc8eb17ef172)
- [chore(l10n): add Dutch translation](https://github.com/Viren070/AIOStreams/commit/a926c54ace39c15833a06965a8c133ce52ebeb1a)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/3343269fa76aafecfa2bb677c39f47fd39352862)

[Compare ed8b085...f959e42](https://github.com/Viren070/AIOStreams/compare/ed8b085...f959e42)

---

## nightly-ed8b085 — 2026-10-24

- [feat(core): add storage, ids and items for Jellyfin playlists](https://github.com/Viren070/AIOStreams/commit/948cfe74ed5b29c138d30b8ae36b19e162ad41e1)
- [feat(jellyfin): add the /Playlists routes and list playlists as items](https://github.com/Viren070/AIOStreams/commit/6b38420e6218eb665273f7493adf3a442f5b2526)
- [feat(web): add playlists](https://github.com/Viren070/AIOStreams/commit/a9bec92aa4148da2af8a8f13060e71c855e0917f)
- [docs: describe playlists](https://github.com/Viren070/AIOStreams/commit/c4896f687085e80c1e3e631c63c10f16367936ee)
- [docs: update changelog](https://github.com/Viren070/AIOStreams/commit/2e9a4bee5f7418a4c5d9a3a992d48e00b58b4763)
- [fix(jellyfin): air an undated episode no earlier than the ones before it](https://github.com/Viren070/AIOStreams/commit/48a77e7955f400a63d7bd51d84889ccdd966df23)
- [fix(jellyfin): leave subtitles marked no-store out of the cache](https://github.com/Viren070/AIOStreams/commit/762360a301ef18b22469b28ba009c42653920be6)
- [fix(web): reword the audio help for remembering picks per show](https://github.com/Viren070/AIOStreams/commit/3d4bcb67a5181aaf492102d1ae168895b63df1f6)
- [fix(web): give the About page's Credits title its own context](https://github.com/Viren070/AIOStreams/commit/a58e39d08b09e8901d65eb102c6cef8931a7d2d0)
- [fix(web): remember the subtitle type picked for a show](https://github.com/Viren070/AIOStreams/commit/657980e0f7f9d17ad6c5f80a25df732fd1368300)
- [fix(web): hold a skip's seek-bar picture for a second](https://github.com/Viren070/AIOStreams/commit/451a15598e4c388c37a1db5d53b027d6d8c1500b)
- [feat(web): show the seek-bar picture for arrow-key seeks only on TVs](https://github.com/Viren070/AIOStreams/commit/d4d00bf777d7b059cb583ddcf9a0da9b1495b8a6)
- [fix(web): close the open player menu when another opens](https://github.com/Viren070/AIOStreams/commit/22d5d3c9f10980acb7e322bb9aca3f0caf469e73)
- [feat(android): choose the storage downloads go to](https://github.com/Viren070/AIOStreams/commit/9ababea0f9c58fca25d4aab1c109605839d43b6d)
- [feat(web): offer the Android app's download folder choice](https://github.com/Viren070/AIOStreams/commit/e14f65cff35e377861876be34f99866a10b639a9)
- [fix(web): return nothing from the calendar agenda's scroll](https://github.com/Viren070/AIOStreams/commit/3b54f0fbef47cffd248d45b5a4e970ff045fcd2a)
- [fix(server): cap the length of party and SyncPlay queues](https://github.com/Viren070/AIOStreams/commit/d5b47a97a2205a9372bfd5421a2d22206b371a90)
- [fix(web): read buffered ranges from one snapshot](https://github.com/Viren070/AIOStreams/commit/10f9382bb64a3d2d7e06bbbb87ac7eda8d0ac79d)
- [feat(web): take a party's next titles from its queue](https://github.com/Viren070/AIOStreams/commit/b9af14508f4a95d14a3c7cfba0fd3541f8c44541)
- [feat(desktop): replace a loaded server subtitle when it is added again](https://github.com/Viren070/AIOStreams/commit/fbdcb1fc38c443274be2ed491135b19e67a1ab04)

[Compare 89312b5...ed8b085](https://github.com/Viren070/AIOStreams/compare/89312b5...ed8b085)

---

## nightly-89312b5 — 2026-10-23

- [feat(web): show cover immediately on auto play first](https://github.com/Viren070/AIOStreams/commit/6a93d189ece07cfb48f4c187677824a3891ce751)
- [fix(web): paint the page's scrollbar in the page colour](https://github.com/Viren070/AIOStreams/commit/930e8a0464625cd797f75a5761c84633372c8753)
- [fix(android): evict past the next landing when the stream cache is full](https://github.com/Viren070/AIOStreams/commit/7af178c473c2ba5b3f05315144ae494435966e26)
- [fix(web): send a segment already skipped as offered](https://github.com/Viren070/AIOStreams/commit/8263f0ac45b0e2efc6991712c582427d0867f7d4)
- [fix(android): pad ExoPlayer text subtitles by mpv's bottom margin](https://github.com/Viren070/AIOStreams/commit/d0bda7269f58f8e4f54c7ef60e3fb4a109f7bbef)
- [feat(web): allow a negative subtitle height](https://github.com/Viren070/AIOStreams/commit/3b2875f61dd2b477c9b552eae2c749b3dd4c3f62)
- [chore(desktop): update the web app (#1613)](https://github.com/Viren070/AIOStreams/commit/6943c04a6326d5a4fa5c64f8c2bae98043683f19)
- [chore(android): update the web app (#1611)](https://github.com/Viren070/AIOStreams/commit/136876dfdcd963f8780d8374a57f53a35401e97c)
- [chore(l10n): update German translation](https://github.com/Viren070/AIOStreams/commit/07dfc4c4c1d11610a63eb575a393fe26bdff8ab0)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/af7630507f5292a5bd13051cb323c8c51c9743b5)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/71b1e46954b8937f23bc99aedd21e8c3363313e9)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/3d2a1e512ae670a39f2f91cdf9790739867cc4fb)
- [chore(desktop): release 0.19.0](https://github.com/Viren070/AIOStreams/commit/5df944b5c856d90ac572e4977b8edb594e4f5a88)
- [chore(android): release 0.9.0](https://github.com/Viren070/AIOStreams/commit/89312b535f7e1eda9c81b1f0de3b62730bd7e22e)

[Compare 454e8b4...89312b5](https://github.com/Viren070/AIOStreams/compare/454e8b4...89312b5)

---

## nightly-454e8b4 — 2026-10-22

- [docs: add v2.37 changelog](https://github.com/Viren070/AIOStreams/commit/3bb0b7494c2af4a25278068a6e5470992b531285)
- [feat(desktop): report a file's own subtitle lines to the page](https://github.com/Viren070/AIOStreams/commit/348c3dfaf455f3831af4992dddac3cf459bc4673)
- [feat(android): report a file's own subtitle lines to the page](https://github.com/Viren070/AIOStreams/commit/6c1abd7cc727fde90287daa7f534fe860ab884cc)
- [feat(web): line added subtitles up with the file's own subtitles](https://github.com/Viren070/AIOStreams/commit/f016dd6cefc8015cade74def057940d9eb9c3e12)
- [docs(apps): describe automatic subtitle sync](https://github.com/Viren070/AIOStreams/commit/b441f45d362a1b5ca0cf5271618f02b60b10c3bd)
- [feat(native): add container indexes and seek thumbnails in Rust](https://github.com/Viren070/AIOStreams/commit/e2bca29b433934c3b5f02e5d6e9d511e43e9ce59)
- [feat(android): build packages/native into a natives module with cargo-ndk](https://github.com/Viren070/AIOStreams/commit/3494f9daba7b80f827733c96102455c9595cf55a)
- [ci(android): install Rust, its Android targets and cargo-ndk](https://github.com/Viren070/AIOStreams/commit/e9ad0b00188b6e3bb1fe107a06d4a2f85f91ff78)
- [perf(native): convert thumbnails straight to JPEG YCbCr](https://github.com/Viren070/AIOStreams/commit/2fe4fe1d7cfd04859dffa74c01c0b935639d779d)
- [perf(native): fetch the next thumbnail's keyframe while one renders](https://github.com/Viren070/AIOStreams/commit/41d2eccfcdef127526c39f2d141ac69eb244d5cc)
- [perf(native): size keyframe reads from recent keyframe sizes](https://github.com/Viren070/AIOStreams/commit/ea1c4cadbe40f30571c33a8dddaf81efd51a1ee3)
- [feat(native): read subtitle timelines from a Matroska file's index](https://github.com/Viren070/AIOStreams/commit/f7bc3b2b335827c8ed6eb8967d75f76bbc77a93a)
- [feat(desktop): send the reference subtitle's lines from the file's index](https://github.com/Viren070/AIOStreams/commit/cb248ee1145c684e5eceb88a7373ca30160e53a7)
- [ci(desktop): build on packages/native/container changes](https://github.com/Viren070/AIOStreams/commit/fb79ef65577c5e476385a0034479ad4928de46e2)
- [feat(android): send the reference subtitle's lines from the file's index](https://github.com/Viren070/AIOStreams/commit/8f911ea44a4411111cd4fde9b9ef2bd85c0fc5f0)
- [refactor(native): load libavcodec at runtime for thumbnails](https://github.com/Viren070/AIOStreams/commit/6214d89b67356fde1926423e7690e7f7c1d29d09)
- [perf(native): fetch several keyframes at once for thumbnails](https://github.com/Viren070/AIOStreams/commit/4a67d314ed9ef185752e5f570613e67e64f1d0ec)
- [feat(native): add thumbnails that open their file in the background](https://github.com/Viren070/AIOStreams/commit/87c1ecefeb5c4e483827192d4b9a4d1c6d5dc592)
- [feat(native): add thumbnail JNI exports for Android](https://github.com/Viren070/AIOStreams/commit/39eb4acca632329e5a03d8607102f612ee096add)
- [feat(desktop): make seek-bar thumbnails for player-thumbnail requests](https://github.com/Viren070/AIOStreams/commit/1f20a1989f66acf1f38af0efbc7dc6b66c2ad6b2)

[Compare 6ca32ed...454e8b4](https://github.com/Viren070/AIOStreams/compare/6ca32ed...454e8b4)

---

## nightly-6ca32ed — 2026-10-19

- [fix(jellyfin): keep separate users off the account's switch list](https://github.com/Viren070/AIOStreams/commit/68a0f69b30abcc206b3030c2134fe762989aa876)
- [refactor(web): drop the picker's dimming of separate users](https://github.com/Viren070/AIOStreams/commit/3051739bf1cbbdb3937f3ff9df9ef5e38c828e95)
- [docs: list a separate user only to itself](https://github.com/Viren070/AIOStreams/commit/2dc71a976e0bde5d8487fe8ec6cf2ba038a942e0)
- [fix(web): start on Home after switching users or signing out](https://github.com/Viren070/AIOStreams/commit/b5814996c628cb5b61846c6fb0a3da80ae8e6ec5)
- [feat(web): keep the app language per user](https://github.com/Viren070/AIOStreams/commit/7e32f7daf378845a472fa925a39f0874077eee6e)
- [fix(web): return focus to a card after a dialog its menu opened](https://github.com/Viren070/AIOStreams/commit/ae8e7e58a70aa3db70ef56e7e738bd38bb1bd588)
- [fix(web): draw card focus rings outside the picture](https://github.com/Viren070/AIOStreams/commit/e3646bc1b31bfc904779d074e86ad56ff1ae53c9)
- [feat(core): keep reports from the apps and pass them on to the developer](https://github.com/Viren070/AIOStreams/commit/2c760fdece71ec5d8c6e72419f60d1c2ecf549a4)
- [feat(server): take app reports and prune them](https://github.com/Viren070/AIOStreams/commit/2b047996a077d6a7991d6b1a7de26d1fe61bde54)
- [feat(android): record how the last run ended](https://github.com/Viren070/AIOStreams/commit/54ef5e0d44a8031aaeb6835a3e85ed59ce5ad70c)
- [feat(web): send a report from troubleshooting or after a crash](https://github.com/Viren070/AIOStreams/commit/661daef90ff0b939586cc6cc8579c1a157b3aa8b)
- [feat(frontend): read app reports in the dashboard](https://github.com/Viren070/AIOStreams/commit/8c3257de696dc6250244f195522ccde3d7100ae0)
- [docs: add app reports](https://github.com/Viren070/AIOStreams/commit/f243869ac37f4fe11765ae0123b8b14c998c83e5)
- [fix(desktop): default GSK_RENDERER to OpenGL on Linux](https://github.com/Viren070/AIOStreams/commit/d9f7856680769708dbef4dfa9c8d655ea6484424)
- [fix(jellyfin): return only the named version from PlaybackInfo](https://github.com/Viren070/AIOStreams/commit/f18557cf0842f9f80c8985e3cbe8e70d26905345)
- [fix: send hash of host for reports](https://github.com/Viren070/AIOStreams/commit/0705e0febf4ef49283898a6ae379fafd56d14108)
- [feat(android): cache the playing stream in native memory for ExoPlayer](https://github.com/Viren070/AIOStreams/commit/ae6fa0ef6b9f22abdcaeb0b425d30686488a12ce)
- [feat(android): skip unreferenced frames and early Opus and Vorbis audio on seeks](https://github.com/Viren070/AIOStreams/commit/8fc59bdaaad30b11c072d26a307f480894661b1d)
- [feat(web): cover the player until its first frame](https://github.com/Viren070/AIOStreams/commit/364c9746998c4ff3755127aa06d0dd6a4a76ce0a)
- [feat(web): add a cache size setting](https://github.com/Viren070/AIOStreams/commit/b3d6f92cdac443387f0a2cc6694d170c76bbc534)

[Compare 9609290...6ca32ed](https://github.com/Viren070/AIOStreams/compare/9609290...6ca32ed)

---

## nightly-9609290 — 2026-10-17

- [fix(android): parse ExoPlayer's file subtitles only as a shown track reaches them](https://github.com/Viren070/AIOStreams/commit/8ec4679efa1566319df8626072aecb44d717be00)
- [fix(android): decode the sound the device can't with libmpv's FFmpeg](https://github.com/Viren070/AIOStreams/commit/b6b78f4115b8799913176109206a46683184a959)
- [feat(frontend): rework addons menu](https://github.com/Viren070/AIOStreams/commit/644dda67bd96f406d08fcddcf619434402224298)
- [feat(android): report ExoPlayer's audio output and memory in its stats](https://github.com/Viren070/AIOStreams/commit/80656922b60f344ab4ab0a4c12fdab5d25626696)
- [feat(web): show the audio output and memory in ExoPlayer's stats](https://github.com/Viren070/AIOStreams/commit/27e7b2ef49648243fdea2b0a903b38247a8359ec)
- [fix(jellyfin): raise the per-configuration maxVersions limit to 500 (#1517)](https://github.com/Viren070/AIOStreams/commit/5cde591e45b665c9f85185920b5b503b5abf449a)
- [chore(android): update the web app (#1500)](https://github.com/Viren070/AIOStreams/commit/59ce8cad61f354c6b626871829184c54345c9d9c)
- [chore(desktop): update the web app (#1506)](https://github.com/Viren070/AIOStreams/commit/69023d45cb7b41c149214fdbde9e4be9c2d06765)
- [chore(desktop): release 0.15.0 (#1514)](https://github.com/Viren070/AIOStreams/commit/c6c1d2da6a88817a7169d2c54f6127c35c04789c)
- [chore(android): release 0.5.0 (#1513)](https://github.com/Viren070/AIOStreams/commit/aaf4e4ecbf035bde5ba90e02c2ee8a3ddbdfc9e4)
- [feat(android): report web fields to the keyboard as native fields on TV](https://github.com/Viren070/AIOStreams/commit/045c536a550295c668d3523b86f58df9d2102f75)
- [fix(android): decode DTS with FFmpeg rather than the device's decoders](https://github.com/Viren070/AIOStreams/commit/59a0a02a0ac299200a90b7133e5351bc0d0eb699)
- [chore: update dependencies and dockerfile image base](https://github.com/Viren070/AIOStreams/commit/c7ecd20c55ebad71c4d5e43c55133deaad2aa0df)
- [fix(config): decrypt string and URL credentials set by the environment (#1528)](https://github.com/Viren070/AIOStreams/commit/795208e502155df7ec503cf0a7da49a54729f47b)
- [chore: update to rsbuild2](https://github.com/Viren070/AIOStreams/commit/62b0b465919b180d32a47c2620fd6d5fe2f52555)
- [feat(jellyfin): list versions that need headers or YouTube when PlaybackInfo asks](https://github.com/Viren070/AIOStreams/commit/92d0190159f031528bd8048d0d171759e90bc37a)
- [feat(desktop): send a loadfile's headers as http-header-fields](https://github.com/Viren070/AIOStreams/commit/c1f365c07bd0c01eb479862f4e90a37afa566d72)
- [feat(android): send a loadfile's headers from both engines](https://github.com/Viren070/AIOStreams/commit/307e63f204a91ad67ec8e6e8e71d86e0aa0904f8)
- [feat(web): play versions that need headers or YouTube in the app's player](https://github.com/Viren070/AIOStreams/commit/17527e34c9156d7b6e303e93df29c1b30eeb97aa)
- [refactor(web): add ask and bridgeStore to the app bridge](https://github.com/Viren070/AIOStreams/commit/23dbac9caec5fc6bf945ced768029f09f15121d3)

[Compare 38c060d...9609290](https://github.com/Viren070/AIOStreams/compare/38c060d...9609290)

---

## nightly-38c060d — 2026-10-14

- [feat(jellyfin): pick the default audio track by the user's audio types](https://github.com/Viren070/AIOStreams/commit/e0eb9f2e6a2809394375f06ed3ce4edb33067eb4)
- [feat(web): re-pick the audio track by the user's audio types](https://github.com/Viren070/AIOStreams/commit/1fe555724b3c7b02a18982d8ae0b1ce62c2d9cc4)
- [feat(android): report ExoPlayer's audio description tracks](https://github.com/Viren070/AIOStreams/commit/7cc4044c166a13747a5ec387db0ae36a09e227c8)
- [feat(desktop): add audio filters for dialogue boost, night mode and AC-3 encoding](https://github.com/Viren070/AIOStreams/commit/31c16c95607aee1211dc92a98d974fba0a9cd935)
- [feat(android): add dialogue boost, night mode, audio delay and AC-3 encoding](https://github.com/Viren070/AIOStreams/commit/1f86c384b7f7f1a8a5da6e08a396f55bf8e90b8c)
- [feat(web): add sound and output settings for the apps](https://github.com/Viren070/AIOStreams/commit/976ba8bbc5b50c349b10cfece322b10baae0336a)
- [feat(android): mix ExoPlayer's sound down to the channel setting](https://github.com/Viren070/AIOStreams/commit/d2d403ae83aaa9fdadd205ba4d6ad85e092d69df)
- [feat(web): show the channel setting in the Android app](https://github.com/Viren070/AIOStreams/commit/4b0f6ac3022d8a15dc4c7a9f6b1cbd71caf9405c)
- [fix(ui): measure a slider's thumb as the whole slider for key navigation](https://github.com/Viren070/AIOStreams/commit/78d8f105eba7e193376c132ca050f103348af5c3)
- [feat(web): honour "play the version's default track first" when re-picking audio](https://github.com/Viren070/AIOStreams/commit/5d22997d466959454b37b22a157804b117810747)
- [fix(jellyfin): play the session a client was given when its stream request names none](https://github.com/Viren070/AIOStreams/commit/38c060dc081e1ab63ca036f384562a6cba77390d)

[Compare bd1de5b...38c060d](https://github.com/Viren070/AIOStreams/compare/bd1de5b...38c060d)

---

## nightly-bd1de5b — 2026-10-13

- [fix(web): stack keyed glides on layers again, easing held repeats in and out](https://github.com/Viren070/AIOStreams/commit/3bd164477a3c0dafa8cbc11a5f4749a72cb2cafa)
- [feat(android): pass surround audio through by what the output reports](https://github.com/Viren070/AIOStreams/commit/6cc6828e1afeb49773bf7244445d241e8340085a)
- [feat(web): add a Dolby Vision switch that plays the HDR10 picture instead](https://github.com/Viren070/AIOStreams/commit/e27353e9883eb8ff5ef62fa11e821bfbe30c489b)
- [feat(jellyfin): rank subtitle tracks by type](https://github.com/Viren070/AIOStreams/commit/d37af67e46ce9b8180250a19ce92bf4c61863e6f)
- [feat(jellyfin): read named trailers and video links](https://github.com/Viren070/AIOStreams/commit/52c949084f74f39ee3d98e8bec63d984f327bc31)
- [feat(web): add a trailer player and a sheet of named trailers](https://github.com/Viren070/AIOStreams/commit/b1c84c17ab15cdd371e0dc1a29dacc3a0fee4714)
- [fix(web): fill the player controls' focus with an inset shadow](https://github.com/Viren070/AIOStreams/commit/78e1d2771e34aea8f820b029d40fff6ff52de91f)
- [feat(jellyfin): answer search hints from LumiereDB or Cinemeta](https://github.com/Viren070/AIOStreams/commit/03ef41737acbbf2a8a9641ca352c6d291c38614c)
- [feat(web): suggest titles from search hints while typing](https://github.com/Viren070/AIOStreams/commit/9f36d38c4ceb92309834c647ec979ddab9748367)
- [docs: update changelog and app/protocol docs](https://github.com/Viren070/AIOStreams/commit/0b9bdad366f6b48f0d224569a667277ace630d1c)
- [feat(web): reuse the server's kept version list in the player](https://github.com/Viren070/AIOStreams/commit/edac5c2ef161ef88a03e8c6a994e7f6c30015e48)
- [feat(web): list only the user's subtitle languages in the subtitle menu](https://github.com/Viren070/AIOStreams/commit/0afe74400f59c535f4ec9a871579cb5d4172543f)
- [fix(desktop): read streams with FFmpeg's reader and reconnect options](https://github.com/Viren070/AIOStreams/commit/3c4fff3ddd770cbde3a95c67dc7220bc7962c4d8)
- [fix(web): show an early end of file as a failure with a resume button](https://github.com/Viren070/AIOStreams/commit/a4a9dd7d4b19a8e2e8aecdf85b849e6ca1c4852f)
- [feat(web): add data-ui hooks to the parts that had none](https://github.com/Viren070/AIOStreams/commit/755544587cc5c42dddb8559514fc75e4f9e37325)
- [docs: list every web app CSS hook](https://github.com/Viren070/AIOStreams/commit/2a42d39bc46fbd48ecc0a3af77adbdaabf8093ab)
- [fix(desktop): read streams with curl again](https://github.com/Viren070/AIOStreams/commit/d877bd10281ef95061fd3a633685d4b5beedbb2f)
- [chore(desktop): update the web app (#1492)](https://github.com/Viren070/AIOStreams/commit/61c0515aec20cb853dd9d056fc633022578c2ea4)
- [chore(android): update the web app (#1493)](https://github.com/Viren070/AIOStreams/commit/5143370f6b8b0c24be3603d538a0b2e89bbe921e)
- [chore(smart-tv): update the web app (#1479)](https://github.com/Viren070/AIOStreams/commit/3fd07deb1dba590e38e28172c91ee42ccb64110e)

[Compare a521900...bd1de5b](https://github.com/Viren070/AIOStreams/compare/a521900...bd1de5b)

---

