# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

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

