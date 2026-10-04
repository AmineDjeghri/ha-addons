# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

## nightly-1dcfa76 — 2026-10-04

- [fix(desktop): load a bundled vulkan-1.dll when Windows has none](https://github.com/Viren070/AIOStreams/commit/30ddeb0d8506179319bda82486ad8c2f9a672de9)
- [fix(watch-state): fold an item's spellings in the history list and counts](https://github.com/Viren070/AIOStreams/commit/4f823797deb3f490482e551d793029567a272071)
- [feat(watch-state): read a kind on pulled watchlist and rating entries](https://github.com/Viren070/AIOStreams/commit/95c77e52d90d71f6c6005b5245c0fde84aefe7a5)
- [feat(watch-state): read airsAt on pulled next episodes](https://github.com/Viren070/AIOStreams/commit/9aee8832accce0cd26576b5cccf3736e8dfb06d4)
- [fix(jellyfin-web): avoid GamepadList array methods and AbortSignal.timeout](https://github.com/Viren070/AIOStreams/commit/76ca25076df04330f7a2974a4dc0559f5cd94df6)
- [fix(jellyfin-web): keep the artwork crop inside the image](https://github.com/Viren070/AIOStreams/commit/f8fae6ca9494622549a04643f33c493572c2a397)
- [fix(jellyfin): page Next Up through up to 200 recent shows](https://github.com/Viren070/AIOStreams/commit/4f51dc11b085fa096fd8c962fe2be587e91b2fed)
- [fix(jellyfin): decode HTML entities in overviews](https://github.com/Viren070/AIOStreams/commit/99028950d9a9b9dbad4c9c04d4def8369fae1ef4)
- [chore(desktop): update the web app (#1422)](https://github.com/Viren070/AIOStreams/commit/4033c6482289f89c09d199a61931f748696738fd)
- [chore(desktop): release 0.10.1 (#1424)](https://github.com/Viren070/AIOStreams/commit/5f446411d7ea383f6141e9f9074a3bce722b2fab)
- [feat(jellyfin): add watchlisted shows and films to Upcoming](https://github.com/Viren070/AIOStreams/commit/7814d091bffccdf9230967d4074d114428f51f36)
- [fix(jellyfin): size the pointer cache by max versions](https://github.com/Viren070/AIOStreams/commit/c086df84b56e6c111936c8e7bdbc0b3d8c96b6f3)
- [feat(jellyfin): raise the max versions default to 25](https://github.com/Viren070/AIOStreams/commit/9f8ed87f92548a9516f1d4f60cc372088337fb53)
- [chore: release 2.35.9 (#1423)](https://github.com/Viren070/AIOStreams/commit/1dcfa7665e7fa759b5604e39bf0f491e9aefaea5)

[Compare 70ffb17...1dcfa76](https://github.com/Viren070/AIOStreams/compare/70ffb17...1dcfa76)

---

## nightly-70ffb17 — 2026-10-03

- [fix(desktop): inhibit display sleep while a file plays on macOS and Linux](https://github.com/Viren070/AIOStreams/commit/d19594a6892f11110b1ea011176a469726a391f6)
- [feat(watch-state): keep ratings and likes, and push and pull ratings](https://github.com/Viren070/AIOStreams/commit/f85758dee209d443471f3bfb54da754c39c3ae5f)
- [feat(jellyfin-web): rate movies, shows and seasons from their page](https://github.com/Viren070/AIOStreams/commit/e222942403cd8aa82fc4ee92e2b5ea1d7853b76f)
- [feat(frontend): add a None option to a user's trackers](https://github.com/Viren070/AIOStreams/commit/16aa99710f7237662245068bbe4283c8d58a7e4b)
- [feat(desktop): drive the system's media controls from a shared now-playing state](https://github.com/Viren070/AIOStreams/commit/89f4671a7e376d2b688b3fa41dfbd31313b72902)
- [feat(jellyfin-web): send now-playing to the desktop app and set the browser's media session](https://github.com/Viren070/AIOStreams/commit/f5c790f47b42b89b572ea62de19a7cb47c7e780d)
- [fix(core/sync): remove the DNS pre-check on user sync URLs](https://github.com/Viren070/AIOStreams/commit/13fc300efa3cf348798283f9020e664827c5ea08)
- [feat(frontend): ask for the configuration password in the profile card](https://github.com/Viren070/AIOStreams/commit/86c3ffb4cbdbdff76a347c1373f5d32908a94bc4)
- [fix(jellyfin-web): size and place browser subtitle cues](https://github.com/Viren070/AIOStreams/commit/3021081760d01018a8d349f16aed2f299b685953)
- [feat(jellyfin-web): add a subtitle height setting](https://github.com/Viren070/AIOStreams/commit/fad3c78cd2c658fa77f21bd1a4874acf101c134e)
- [docs: add a custom CSS example that hides a catalog row's kind](https://github.com/Viren070/AIOStreams/commit/3ab898bfe1987ceb1547456e8892b1b0c484517b)
- [feat(jellyfin-web): link the custom CSS guide from the theme settings](https://github.com/Viren070/AIOStreams/commit/db4b778731216c12dd144bba8325295f67111f71)
- [feat(jellyfin-web): take the player's top volume from mpv's volume-max](https://github.com/Viren070/AIOStreams/commit/e99ce707dd77d4810904ab2b687e89ddf283a036)
- [feat(jellyfin-web): link the source code and documentation from About](https://github.com/Viren070/AIOStreams/commit/f0bae05dc219d2922229c2163db28b64d948e4be)
- [feat(jellyfin-web): replace the player's volume range with a bar that marks the boost](https://github.com/Viren070/AIOStreams/commit/6922932d41093a0b200f4f44dcabc4125ca87d18)
- [chore(desktop): update the web app (#1398)](https://github.com/Viren070/AIOStreams/commit/85c2df2fc6c02fcf84460a9263ed2cc6c6a0a3f0)
- [chore(desktop): release 0.9.0 (#1402)](https://github.com/Viren070/AIOStreams/commit/cd13e5f8abf4c2ea708a290787573dd97d9d1243)
- [chore: release 2.35.5 (#1396)](https://github.com/Viren070/AIOStreams/commit/8377562395c9c02e2336296cd68f9069f275d42c)
- [feat(jellyfin): link the configuration's own page when the address names it](https://github.com/Viren070/AIOStreams/commit/86731647ab1cd861813b5712865cb3c4cb943c18)
- [feat(jellyfin-web): show a message for no libraries](https://github.com/Viren070/AIOStreams/commit/563126e324678d9a5c632252d52a49812ce315e5)

[Compare d029954...70ffb17](https://github.com/Viren070/AIOStreams/compare/d029954...70ffb17)

---

## nightly-d029954 — 2026-09-30

- [fix(ui): pan carousel rows with a trackpad or mouse wheel (#1394)](https://github.com/Viren070/AIOStreams/commit/736d6c4dae8ec3d6f429ee33c1b078ca349ca81f)
- [fix(desktop): don't scale disc subtitles, keep styled ones in the crop](https://github.com/Viren070/AIOStreams/commit/907867d81bbd53b16b8bb9ebbf85905de2a124e7)
- [feat(desktop): add an aiostreams:// link scheme](https://github.com/Viren070/AIOStreams/commit/8f243fc6bc1a3afd71d7f0e97ff0c9ae29105751)
- [feat(jellyfin-web): open aiostreams:// links](https://github.com/Viren070/AIOStreams/commit/33caebd9126ce2d13ef3b0e10a91d8b5fb5efdfd)
- [chore(desktop): update the web app (#1395)](https://github.com/Viren070/AIOStreams/commit/72c70fe37208b002e2de0b8d9df2efc2fedf877f)
- [chore(desktop): release 0.8.0 (#1397)](https://github.com/Viren070/AIOStreams/commit/12f30f2b291c665e48971f5ca3a1f5c0573c46b0)
- [chore: add dockerfile for jellyfin-web](https://github.com/Viren070/AIOStreams/commit/35656af2f339df90897fe2e9f170c21693d20b3b)
- [fix(jellyfin-web): send None for featured catalogs that need a genre](https://github.com/Viren070/AIOStreams/commit/0470d74a519d9e99bd8c28ffef63b2c64a53ed3f)
- [feat: flag libraries that need a genre](https://github.com/Viren070/AIOStreams/commit/a07907931dc0039729a5245f63381ca84fa55c2f)
- [docs: update readme and 2.35 changelog](https://github.com/Viren070/AIOStreams/commit/6640e0fc592071569938a279a7238798f07785ce)
- [feat(frontend): show the release a nightly is built on in What's new](https://github.com/Viren070/AIOStreams/commit/3dcc6030c520ab0be4b157b6c0e90e543ec61ba3)
- [feat(frontend): announce new releases to nightly users by their base version](https://github.com/Viren070/AIOStreams/commit/0ab165c414fbe3c427a4439aa890e7f6a6deef32)
- [feat(jellyfin): add a setting to stop marking unaired episodes](https://github.com/Viren070/AIOStreams/commit/1bfc82b90b2c1041ae656fb34de08b17427023f9)
- [fix(watch-state): keep history for as long as a configuration is in use](https://github.com/Viren070/AIOStreams/commit/1a7f39fc3da2876b155718da6a8f495cb6aaac47)
- [feat(core): replace per-feature private URL settings with ALLOW_PRIVATE_URLS](https://github.com/Viren070/AIOStreams/commit/c3853ca30a977dc062252dbc198232fd43b35273)
- [feat(watch-state): make the resume and played thresholds configurable](https://github.com/Viren070/AIOStreams/commit/597e4630c4005588ea98fa8d821e05e71d6a6f76)
- [fix(watch-state): match drops against every id a show is stored under](https://github.com/Viren070/AIOStreams/commit/d029954da44802fbb152ca5583aa2b468c45cdb0)

[Compare 0eccbc7...d029954](https://github.com/Viren070/AIOStreams/compare/0eccbc7...d029954)

---

## nightly-0eccbc7 — 2026-09-29

- [feat(jellyfin-web): add a per-segment skip setting](https://github.com/Viren070/AIOStreams/commit/b66d07a016881a8a4a4fd208098195c7b4a3a5bc)
- [feat: add a show on home modifier for catalogs that require a genre](https://github.com/Viren070/AIOStreams/commit/a78080578d3ea3b2df5989856aa7c528e6deb6c0)
- [fix(jellyfin): apply variants before syncing and validating the config](https://github.com/Viren070/AIOStreams/commit/1764e37f17682e303123808a1e4c7e89e11e261e)
- [feat(core): add per-addon catalog defaults](https://github.com/Viren070/AIOStreams/commit/063b018947f646cb8774c28a85fca64f813e3e4e)
- [feat(frontend): rework the catalog editor](https://github.com/Viren070/AIOStreams/commit/1c6f2c0c466136d440d4dda007d6747e4e276947)
- [fix(desktop): create the window hidden on Windows and show it after the web view](https://github.com/Viren070/AIOStreams/commit/2955154fa97209032bf945a6d7dc73ca905c1814)
- [feat(jellyfin): send persona ids to trackers that declare watchState.viewers](https://github.com/Viren070/AIOStreams/commit/ffd98bd0897df74e2e7f392bab438c9e2732ac7a)
- [fix(ui): declare the dark color scheme before the app loads](https://github.com/Viren070/AIOStreams/commit/ec93f125245d9d9da535f006413aa6a2f2d1f8de)
- [chore: update header presets (#1383)](https://github.com/Viren070/AIOStreams/commit/a1f783c966f4e00bbf7a735dc8b13df92c13a6a1)
- [chore(desktop): update the web app (#1385)](https://github.com/Viren070/AIOStreams/commit/22fc51fe02e21401a808a3e89517e21148bc32e7)
- [chore(desktop): release 0.6.0 (#1387)](https://github.com/Viren070/AIOStreams/commit/669af42644b52bef2ef2c76bd38c2e7424428088)
- [chore: release 2.35.3 (#1386)](https://github.com/Viren070/AIOStreams/commit/11979c12293b617a34009685312a75521086eba3)
- [feat: adjust jellyfin wording/install options, update docs, readme](https://github.com/Viren070/AIOStreams/commit/d461cd76ef43c34f270d8a93a6f721f42071b528)
- [feat(desktop): add Discord events for browsing and a connection status](https://github.com/Viren070/AIOStreams/commit/eb193b47ff45fe30604c3ed66b0829509ccc7cf5)
- [docs(readme): update](https://github.com/Viren070/AIOStreams/commit/2213bff4462b8043e1feb3fc5d506a56cd4377f5)
- [feat(builtins/nab): warn on missing infohash, fix hash-fallback bug (#1261)](https://github.com/Viren070/AIOStreams/commit/8b5aa22e397d9378216ecc1e0ccfd353fcd88e9e)
- [fix(desktop): send the Discord logo by address](https://github.com/Viren070/AIOStreams/commit/39d447f390ce2db0f1d97cf56450477862a8351a)
- [docs(env): add 'createConfig' permission to AIOSTREAMS_AUTH (#1392)](https://github.com/Viren070/AIOStreams/commit/f400920e88e8a78cbbc75bf2304c67d4139b058f)
- [chore(desktop): release 0.7.0 (#1389)](https://github.com/Viren070/AIOStreams/commit/3c23fd472055b62da7d6137333eaad079c842146)
- [chore: release 2.35.4 (#1390)](https://github.com/Viren070/AIOStreams/commit/0eccbc78c068ad074940b5f0b52af5eed046bbb3)

[Compare 632d1d4...0eccbc7](https://github.com/Viren070/AIOStreams/compare/632d1d4...0eccbc7)

---

## nightly-632d1d4 — 2026-09-28

- [fix(jellyfin-web): show any server's placeholder sources as notices](https://github.com/Viren070/AIOStreams/commit/ff32b06d173c83b581827e322a5160054c584602)
- [fix(jellyfin): take a show's episodes from SeasonId before the path id](https://github.com/Viren070/AIOStreams/commit/6e331296ffb2694c34996a0e374c8cc0e2704597)
- [refactor(ui): move the donation modal into the shared kit](https://github.com/Viren070/AIOStreams/commit/5690d73c397e85d7d5fabe1f22b9f24e4c50778c)
- [refactor(jellyfin-web): regroup settings by what they change](https://github.com/Viren070/AIOStreams/commit/845b5ad1416d047b3842838bda58fe8306706841)
- [feat(jellyfin-web): add a donate button under the settings tabs](https://github.com/Viren070/AIOStreams/commit/81b4188e5ef69fcb98c1745aeef5376a8ca6dc12)
- [feat(jellyfin-web): open the player full screen in landscape on phones](https://github.com/Viren070/AIOStreams/commit/a3d4b2820b4eb703e3606cf9d1eba1c9bee59409)
- [feat(jellyfin-web): add back and forward buttons to the sidebar in apps](https://github.com/Viren070/AIOStreams/commit/43599da68639bd22b867d5124e48d2713f94a506)
- [feat(jellyfin-web): keep the window buttons in full screen, with one to leave it](https://github.com/Viren070/AIOStreams/commit/7fa240f1096ebef0a9a7bab1e15bfb61624a1ec7)
- [fix(jellyfin): round every tick value to a whole number](https://github.com/Viren070/AIOStreams/commit/bb64fb1f03366af59c37991807626e7edf19d5a0)
- [feat(jellyfin-web): add a favourites page](https://github.com/Viren070/AIOStreams/commit/3c2dc76ce4aaa8fbe652e516a404d03c51c8c742)
- [refactor(jellyfin-web): drop the watched and favourite filters from catalogs](https://github.com/Viren070/AIOStreams/commit/e454a974b49c5499a6e1230aa89d423932f25590)
- [feat(desktop): show what plays as Discord rich presence](https://github.com/Viren070/AIOStreams/commit/36f5602591a16f14206c51634783b0e8b192ffed)
- [feat(jellyfin-web): add a setting to share what plays on Discord](https://github.com/Viren070/AIOStreams/commit/8fdd332b945144a92ade5c670127fa50af3343c5)
- [feat(jellyfin-web): add {position} and {returnUrl} to the external player link](https://github.com/Viren070/AIOStreams/commit/dfcdac9ae19042461c1037e4d7cffc4136375cad)
- [feat(jellyfin-web): add {filename} and {subtitles} to the external player link](https://github.com/Viren070/AIOStreams/commit/1ca68bc18fcd2895e6967179dbbe24d935a67f8a)
- [fix(jellyfin-web): slide pages in by top instead of a transform](https://github.com/Viren070/AIOStreams/commit/11b5ccc9c4baf8e268d318b960853bc76204c9c8)
- [feat(jellyfin-web): add a setting to skip the version list, with hold to do the other](https://github.com/Viren070/AIOStreams/commit/225a12c42ea732c7f4333900f652f08c89d53a26)
- [fix(jellyfin-web): count an Intro chapter as the intro only when none is named the opening](https://github.com/Viren070/AIOStreams/commit/95f0ee57b87bb2eb5ab811219096cd33287ad31e)
- [feat(jellyfin): answer /Items episode queries with a premiere date range](https://github.com/Viren070/AIOStreams/commit/0d900265c913ba44396bdcf88bbc1c37a0264005)
- [feat(jellyfin-web): add a calendar page](https://github.com/Viren070/AIOStreams/commit/1fc85947164c73ccc9bb51d39a266b086797e515)

[Compare 6fb4535...632d1d4](https://github.com/Viren070/AIOStreams/compare/6fb4535...632d1d4)

---

## nightly-6fb4535 — 2026-09-27

- [fix(desktop): start mpv on Linux under any locale](https://github.com/Viren070/AIOStreams/commit/94d506389c95f616ef67daeffb6ae3ebb1f74e81)
- [fix(desktop): follow the mouse's back and forward buttons on Linux](https://github.com/Viren070/AIOStreams/commit/38afea547dc4582aeb8d367a7cba1027227124cb)
- [fix(desktop): log the OpenGL context the Linux video draws with](https://github.com/Viren070/AIOStreams/commit/2fe90a2c90fc7521202450a0957fe6bf1f294437)
- [perf(jellyfin-web): decode artwork off the main thread](https://github.com/Viren070/AIOStreams/commit/4889472996cbf941d8b2662ca30fa40fb3d2d9d7)
- [fix(desktop): give the Linux window the app's own id](https://github.com/Viren070/AIOStreams/commit/c3d495cf7d24d0b5fa3f122ab9682d74a15e5f23)
- [fix(desktop): redraw the Linux video area when playback stops](https://github.com/Viren070/AIOStreams/commit/89d8d69553495307a57df8240c2767efd574b41c)
- [fix(jellyfin-web): scroll a new page before its first paint](https://github.com/Viren070/AIOStreams/commit/98548323de487bdafbdb1bee8329691fe3077d05)
- [perf(desktop): make the page's mpv calls on a thread of their own](https://github.com/Viren070/AIOStreams/commit/2e5db88fa1e82aef436e4e991f55fa7b1ba0fcbf)
- [perf(desktop): draw Linux video frames when due instead of in mpv's wait](https://github.com/Viren070/AIOStreams/commit/bb8539a93d5e771bb0428bdf7b9ae211f45da358)
- [feat(desktop): turn on the render API's advanced control on Linux](https://github.com/Viren070/AIOStreams/commit/e4405d31422cb9d0f08967039e4d453b20dd808e)
- [feat: show the server's build in About and diagnostics](https://github.com/Viren070/AIOStreams/commit/c08e49601204640b5c870cec8c18b6e250d79c71)
- [feat(jellyfin-web): cap how wide hero and title backdrops get](https://github.com/Viren070/AIOStreams/commit/485b52bc75afa379a197d4355e81954ee11e036e)
- [feat(desktop): put the app icon on a near-black tile](https://github.com/Viren070/AIOStreams/commit/ac900ae994d10e7a8c38a74b588d60295747adbe)
- [feat(desktop): package the Linux app as a Flatpak](https://github.com/Viren070/AIOStreams/commit/0a1c8cd76fde502da604f63701b6660ed6180836)
- [feat(desktop): fill the Flatpak's releases from the changelog](https://github.com/Viren070/AIOStreams/commit/7a2061517812652d4a049934274d13aefe31e29c)
- [ci(desktop): build the Linux Flatpak for x64 and arm64](https://github.com/Viren070/AIOStreams/commit/66af518584a99dcd67f5f2f44ded4fde6dfb4b1e)
- [fix(desktop): skip mpv's frames on macOS while the window can't show them](https://github.com/Viren070/AIOStreams/commit/cf497d6e77dd525f10cfc0c15ce0111d3c5d16eb)
- [perf(desktop): stop macOS video draws waiting on the main thread](https://github.com/Viren070/AIOStreams/commit/d3b9f0a56859dbfdf1912dee8168e078619d698f)
- [feat(desktop): turn on the render API's advanced control on macOS](https://github.com/Viren070/AIOStreams/commit/dc8730e3451d248a73d308eda5b89c78838e4c62)
- [docs: list Linux as a desktop app platform](https://github.com/Viren070/AIOStreams/commit/f2b94c802f3c1b72405380262b87faa1236e8b8c)

[Compare 00fb93a...6fb4535](https://github.com/Viren070/AIOStreams/compare/00fb93a...6fb4535)

---

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

