# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

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

## nightly-a521900 — 2026-10-12

- [feat(web): hear back from external players in the Android app](https://github.com/Viren070/AIOStreams/commit/73138d6a605428370dc36b7cbded8f3a803538d4)
- [feat(android): hand Back to the page](https://github.com/Viren070/AIOStreams/commit/36ae5a0fe62464c7845e072c716acdcbf5fa922d)
- [feat(web): take the Android app's Back](https://github.com/Viren070/AIOStreams/commit/fb93b47ee602c1b1b0a0fb1d8186f9e3f5f77564)
- [feat(android): add an ExoPlayer engine](https://github.com/Viren070/AIOStreams/commit/764da86a4b82d5ace8caa42490a57122700f90bc)
- [feat(web): choose the Android app's player engine](https://github.com/Viren070/AIOStreams/commit/0bef3a4f4686e78445c275b18063af8ec5906dc6)
- [feat(web): say which picture fit the button picked](https://github.com/Viren070/AIOStreams/commit/3902c74a9f6a4d051a4cb5c2fc6936ce337904f7)
- [refactor(android): rename the player modules to mpv and exoplayer](https://github.com/Viren070/AIOStreams/commit/42b0cd5adeb3a77d28873ce496663eaedaf2684f)
- [fix(android): apply sub-ass-override to ASS in ExoPlayer](https://github.com/Viren070/AIOStreams/commit/2e4da694ac9bfd6c65c710a178bf56a9017aff34)
- [fix(android): time embedded text subtitles by the video's frames](https://github.com/Viren070/AIOStreams/commit/3c4db7b4f8b622bbceae1ea3213bbdc241cefd11)
- [feat(android): fall back to mpv when ExoPlayer can't decode a file](https://github.com/Viren070/AIOStreams/commit/e54d2b6093c3679d5e6cbfa17ba0f515d13e90bd)
- [feat(web): add an Automatic player engine and make it the default](https://github.com/Viren070/AIOStreams/commit/2549a50f2a3433c295ad7cb0bc14c549afadb931)
- [fix(android): replace the launcher PNG with an adaptive icon](https://github.com/Viren070/AIOStreams/commit/79ad343a79c7771065f59d252830a8733b614743)
- [feat(android): read back to the subtitle lines a seek lands in](https://github.com/Viren070/AIOStreams/commit/7592d222a6dff1770e669ff32957d4cd5bb92381)
- [fix(android): strip native libraries with the pinned NDK](https://github.com/Viren070/AIOStreams/commit/cf9634418baa68410d449a52d7c76233c7ea7457)
- [feat(android): fetch libmpv from a pinned, hash-checked release](https://github.com/Viren070/AIOStreams/commit/983666a10d4268fe329670974cc387dff1669457)
- [perf(web): ask the Android app's mpv for direct MediaCodec decoding](https://github.com/Viren070/AIOStreams/commit/2173c6232fc6f35c8483a81ea3976cdd119c63f8)
- [chore(android): ignore the bin folders VS Code's Java tooling writes](https://github.com/Viren070/AIOStreams/commit/645c49443ad2148e87b9bbcee1d4842011c5d394)
- [fix(android): write mpv's CA bundle from Android's certificate store](https://github.com/Viren070/AIOStreams/commit/1a3f43d0f0d30524d3619f1c3e9cbe5255c9d267)
- [feat(android): add an Android TV launcher entry and banner](https://github.com/Viren070/AIOStreams/commit/9c945d104f1424fee1dcc51d60da2b2972c618c6)
- [feat(android): tell the page it runs on a TV](https://github.com/Viren070/AIOStreams/commit/da3281cf7db564d238693223943738599797cd13)

[Compare b17de1e...a521900](https://github.com/Viren070/AIOStreams/compare/b17de1e...a521900)

---

## nightly-b17de1e — 2026-10-07

- [feat(media-info): add a tags list to audio tracks](https://github.com/Viren070/AIOStreams/commit/6ff91b8737c26da71ccbfbedaf615e223323e0aa)
- [chore(config): raise jellyfin.maxVersions limit to 500](https://github.com/Viren070/AIOStreams/commit/03706968430fbcd1b2694da65831e42644bda6fc)
- [feat(jellyfin-web): add Android players to the player choice](https://github.com/Viren070/AIOStreams/commit/26a30502ffd6287383286725882a5b998ee5af0e)
- [feat(jellyfin-web): hand the Android app's player the episodes that follow](https://github.com/Viren070/AIOStreams/commit/25e6f6f0b7719a0500ff569de4a19da2f4d57de6)
- [feat(jellyfin-web): refresh watch state on the server socket's pushes](https://github.com/Viren070/AIOStreams/commit/db189732477b3435cea49554ebc5ad91fc1565e4)
- [feat(jellyfin-web): redesign server picker](https://github.com/Viren070/AIOStreams/commit/8c248623c0bd99e754865f97c2926167d4f998b1)
- [fix(core): only type a stream as external when it has no url](https://github.com/Viren070/AIOStreams/commit/0f8a13de0c2cefff5954b81cd42c3aa84b520a16)
- [fix(frontend): add no-referrer to the marketplace and reorder modal logos](https://github.com/Viren070/AIOStreams/commit/37ff00fe251fc50b87a36dfad7912caf229fbf6b)
- [chore(presets): disable argentina tv and aio subtitle](https://github.com/Viren070/AIOStreams/commit/22c6c6f398afa61687768722bda07b6c905008af)
- [fix(presets): replace the fkstream and nzbhydra logos](https://github.com/Viren070/AIOStreams/commit/063a46f760e029f998e3793c306a9b7316b07db4)
- [feat(parser): read stream duration from behaviorHints.duration](https://github.com/Viren070/AIOStreams/commit/0b9b655353fce57333f81bfbcf239b1e05dcfe00)
- [feat(parser): read more stream details from behaviorHints](https://github.com/Viren070/AIOStreams/commit/d56784ed024a8bb618a2c94f280f25a5616fc0b8)
- [feat(remuxdb): enable contributing by default](https://github.com/Viren070/AIOStreams/commit/99b6dc3f907490ffa9e24eeb6c1f008609f1867c)
- [docs(guides): add private trackers guide (#1438)](https://github.com/Viren070/AIOStreams/commit/d61b9e3735b133eeb683b18c3ef6c07c3e4b82da)
- [chore(tv): update the web app (#1440)](https://github.com/Viren070/AIOStreams/commit/cebbc2343f8a71e3e90114d3efc56753c99bdf97)
- [chore(desktop): update the web app (#1427)](https://github.com/Viren070/AIOStreams/commit/29be572e18bcd96886c7016030840789e182f536)
- [chore(tv): release 0.2.0 (#1441)](https://github.com/Viren070/AIOStreams/commit/295490e99ab4b7da82566e21b9b64f2a6e33c8a1)
- [chore(desktop): release 0.11.0 (#1431)](https://github.com/Viren070/AIOStreams/commit/e58b3e1574914d53040f1aab8f6f3b375b521e45)
- [fix(presets): note TsukiHime's per-file audio/subtitle extraction (#1436)](https://github.com/Viren070/AIOStreams/commit/b17de1eabd7d98e6f4a65aa01229d215081ff38f)

[Compare 147773c...b17de1e](https://github.com/Viren070/AIOStreams/compare/147773c...b17de1e)

---

## nightly-147773c — 2026-10-06

- [fix(watch-state): add the session start time to playback event ids](https://github.com/Viren070/AIOStreams/commit/ea9ddbd2e11adaab4d0400988a6df8452a912a87)
- [fix(jellyfin-web): replace the player controls with the error screen](https://github.com/Viren070/AIOStreams/commit/c34b7b1fe27f31300c12539faac5731720214eea)
- [feat(desktop): add mpv's first http error to mpv-ended](https://github.com/Viren070/AIOStreams/commit/701eed82974c70802a2462b7f229fbd0a54a2bf5)
- [feat(jellyfin-web): describe desktop playback failures from mpv's http error](https://github.com/Viren070/AIOStreams/commit/21f24bfd4fb0b2a0edfc79474c9219afc02b3cf6)
- [fix(remuxdb): put the season and episode in the versions id](https://github.com/Viren070/AIOStreams/commit/bc78e3657ce06684adacd71a1db34559eebba5da)
- [fix(cache): drop a buffered sql write on delete](https://github.com/Viren070/AIOStreams/commit/c2e6bdd3e0803979f5daf30ca6e9efc12b2aad51)
- [fix(usenet): hash proxied NZB URLs by the URL behind our proxy](https://github.com/Viren070/AIOStreams/commit/9ac363f4ac9d7d56f3ee4017a084bff3f71c5fcc)
- [fix(dedupe): copy probed tracks from a duplicate that lists them](https://github.com/Viren070/AIOStreams/commit/aeb4f2fb91f72ff1620a34118552ac58edb1dc43)
- [feat(db): add the media info tables](https://github.com/Viren070/AIOStreams/commit/ac93a93822ad0523de32b4883d43ebe7a804806a)
- [feat(media-info): probe played files with ffprobe](https://github.com/Viren070/AIOStreams/commit/d0f43a3a1b3b7bf1e7bf011f57798b4ef7640ed9)
- [feat(presets): parse the torrent file and title where addons name them](https://github.com/Viren070/AIOStreams/commit/4a27d2b5bdaaaafc90ffc4f5c09c9236d27e78dd)
- [feat(proxy): name a trusted stream's release in its proxy token](https://github.com/Viren070/AIOStreams/commit/c3cedcfe5b0f6b6227a15e92808b32f39952c586)
- [feat(media-info): fill stream details from stored probes](https://github.com/Viren070/AIOStreams/commit/5c8b38dbc11fa7cbf349932d254bdda75dc022a2)
- [feat(media-info): store what StremThru and RemuxDB report](https://github.com/Viren070/AIOStreams/commit/64aaffd98efe3aaa1c2ae5e229a99404d29ed28b)
- [feat(media-info): serve stored media info to other instances](https://github.com/Viren070/AIOStreams/commit/57d0156030ed25642b4233ab513ed5899fabbefa)
- [feat(remuxdb): contribute stored probes](https://github.com/Viren070/AIOStreams/commit/253cea295619f1460adb5c29407ae64da0e9c856)
- [feat(jellyfin): fill a version's tracks from stored probes on play](https://github.com/Viren070/AIOStreams/commit/ba7835290f747bb9f3a39a2d395af0b3b2fb8720)
- [feat(dashboard): add a media info page](https://github.com/Viren070/AIOStreams/commit/b94647c26d9207823ff11b03de2832ad812608f6)
- [feat(docker): ship a minimal ffprobe](https://github.com/Viren070/AIOStreams/commit/472def37da5a9ee55f66f27b2cabe9badf0d9cad)
- [fix(core): drop "Usenet" from the built-in usenet service's known names](https://github.com/Viren070/AIOStreams/commit/28fa990d0f33eaa5c18ebb1e648d6fb2ca121812)

[Compare 9db03c5...147773c](https://github.com/Viren070/AIOStreams/compare/9db03c5...147773c)

---

## nightly-9db03c5 — 2026-10-05

- [fix(watch-state): keep the played mark under a resume point](https://github.com/Viren070/AIOStreams/commit/a4cdbc078e38c4c200aad3f8ff8d52546e7d7b96)
- [fix(jellyfin-web): clear only the position on remove from continue watching](https://github.com/Viren070/AIOStreams/commit/c66e99fef2d4c3d94907120a6d49355d2c6d5a54)
- [feat(jellyfin): add watchlisted shows and films to the calendar](https://github.com/Viren070/AIOStreams/commit/f5abba05d5b503250989b321d4f12f0b5f933e3e)
- [feat(jellyfin-web): list films on the calendar](https://github.com/Viren070/AIOStreams/commit/05863cbb4a5889a8054ef8e8b0a8f46c3524a807)
- [feat(desktop): start the user's own mpv and drive it over its IPC](https://github.com/Viren070/AIOStreams/commit/2aa49ee6efc2b98dec94cc7737af1b25b50dcb5e)
- [feat(jellyfin-web): replace the external player link with a player choice](https://github.com/Viren070/AIOStreams/commit/3578bd32e8c14cbc4b908e28b2a51ced4e2e05a6)
- [feat(desktop): load subtitle files the page sends](https://github.com/Viren070/AIOStreams/commit/eb4fc05792fffff7dc65359e41844d5ec754b0ef)
- [feat(jellyfin-web): add subtitle files by dropping or picking them](https://github.com/Viren070/AIOStreams/commit/76d711697a9687dab0fbf0be1daa575bd4063664)
- [refactor(jellyfin-web): group playback and subtitle modules into folders](https://github.com/Viren070/AIOStreams/commit/4ccd8156b5a5c1ab4e3b7feb52683eb57e2e609a)
- [fix(watch-state): treat a favourite under any spelling as the title's](https://github.com/Viren070/AIOStreams/commit/14336d0488c52b1a9c564e96df9b09c17cca111f)
- [feat(jellyfin-web): add {scheme} to the player link](https://github.com/Viren070/AIOStreams/commit/9db03c542df26f7d04fde93965a04c2ace468835)

[Compare 1dcfa76...9db03c5](https://github.com/Viren070/AIOStreams/compare/1dcfa76...9db03c5)

---

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

