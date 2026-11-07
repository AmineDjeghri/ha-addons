# Changelog

For full upstream release notes see the [official AIOStreams releases](https://github.com/Viren070/AIOStreams/releases).

## nightly-9cd6e24 — 2026-11-07

- [fix(android): only count controllers with a stick or d-pad as gamepads](https://github.com/Viren070/AIOStreams/commit/31ccc515ce0e337b15f2da3a257b8f274a9239fb)
- [perf(web): stop re-rendering the player page on unchanged state reports](https://github.com/Viren070/AIOStreams/commit/37ab20fc1618a8027e4deebe4394cc18b8ddc7ef)
- [fix(android): also count button-only pads as gamepads](https://github.com/Viren070/AIOStreams/commit/77727c2cc2a2a87be520ca15c30688777b9cf302)
- [fix(presets/meteor): skip "donate" placeholder stream](https://github.com/Viren070/AIOStreams/commit/859e30dc65fdd0be359fd56659471bc298669ff4)
- [feat(posters): add custom poster URL service (#1739)](https://github.com/Viren070/AIOStreams/commit/dd620f5cdbbc1d85cf4d7b5bfa734d1250c8570a)
- [fix(android): start passthrough audio before its buffer fills (#1742)](https://github.com/Viren070/AIOStreams/commit/14d9d63fad60bc8884f7b390aaff2f0320616799)
- [feat(presets): add cinemeta preset (#1740)](https://github.com/Viren070/AIOStreams/commit/4c806af2775ca85414e7bf73dbf4ed28d28afc17)
- [fix(torrent-galaxy): use torrentgalaxy.online as default domain (#1738)](https://github.com/Viren070/AIOStreams/commit/f651b791b8d19f7ea3295df503f396c660ccab83)
- [fix(core): only set indexer/addon mediaInfoQuality when languages were returned (#1538)](https://github.com/Viren070/AIOStreams/commit/ed74a3bcafb881738cfd63aac1d93204ed92f0df)
- [fix(android): start a download's video without waiting for its subtitles (#1720)](https://github.com/Viren070/AIOStreams/commit/0dd6e42f901a8c39d7200bcd09cf51ac43b6c563)
- [feat(presets/newznab): add SearchNZB indexer (#1701)](https://github.com/Viren070/AIOStreams/commit/07b9861ac6baff4a0e31ba07e7e86f8032b127b5)
- [fix(jellyfin): rebuild movie-kind watch rows as movies](https://github.com/Viren070/AIOStreams/commit/26a72b681b8a8c5741862d90c8968151e429be76)
- [fix(web): reopen live sources that end, fail or stall](https://github.com/Viren070/AIOStreams/commit/efb11f31c17eb4a8a3e486ea065afd30730d2e50)
- [feat(android): load live sources at their live edge](https://github.com/Viren070/AIOStreams/commit/6e56f20abc587103065257bd0cf984a9dd028819)
- [feat(web): tell the app's player when a source is live](https://github.com/Viren070/AIOStreams/commit/049cd02ecc66502bfc51738c2e4b6384ec51e463)
- [fix(jellyfin): tell live playback by its item when its version is unknown](https://github.com/Viren070/AIOStreams/commit/c0723d9ec866b407ba69956b91454737b91fcfef)
- [feat(web): add a start page setting](https://github.com/Viren070/AIOStreams/commit/008eae29a51009af72fbb5e9452eb2de9eaf6150)
- [feat(web): list every page in the bottom bar and its menu](https://github.com/Viren070/AIOStreams/commit/2c77b3e44e6f4968aa2f36ba1dcd4df104c5f503)
- [docs: add the bottom bar's page hooks](https://github.com/Viren070/AIOStreams/commit/ad19e87edbd7aa5ee3935013964518251c5f481d)
- [fix(web): drop a live playback's unsent stop](https://github.com/Viren070/AIOStreams/commit/b475694f0fad94efeb924c7d8bbaaec91797370c)

[Compare c4afd6e...9cd6e24](https://github.com/Viren070/AIOStreams/compare/c4afd6e...9cd6e24)

---

## nightly-c4afd6e — 2026-11-06

- [fix(knaben): dedupe hits, use upload date for age, include subcategories (#1656)](https://github.com/Viren070/AIOStreams/commit/10e0f56559fbd7180d3849f935fef39ca0c3f6c4)
- [fix(therarbg,torrent-galaxy): normalise imdb ids, keep keywords first in URLs, share code (#1650)](https://github.com/Viren070/AIOStreams/commit/190899451e496518775b8c104548f1ee259cf44e)
- [fix(presets/meteor): migrate to current config format and improve stream parsing (#1735)](https://github.com/Viren070/AIOStreams/commit/93c27f00a3dc96bf7819ccfd63b7f5cd82e5c310)
- [fix(presets/meteor): skip "no results" placeholder stream (#1736)](https://github.com/Viren070/AIOStreams/commit/3fc896824201053336c791c9e7853e654d72e723)
- [refactor(knaben): switch to v2 search api (#1737)](https://github.com/Viren070/AIOStreams/commit/c4afd6e48f39aab062a3fbc24fe0a936281b453c)

[Compare 46f8593...c4afd6e](https://github.com/Viren070/AIOStreams/compare/46f8593...c4afd6e)

---

## nightly-46f8593 — 2026-11-05

- [fix(android): keep the refresh rate when no mode matches the screen's size](https://github.com/Viren070/AIOStreams/commit/674bdc213c37b79464a0e611c625726dfe41d5b1)
- [chore(android): update the web app (#1716)](https://github.com/Viren070/AIOStreams/commit/090cf99cafd09359d77699f2b11ca0bda9472467)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/15db3668673f01a74912a9e1b5f6e30b20b5209e)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/73bc7599e35fa60aa32d15a5b522ee939cff7e14)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/c5ee3b0e992e294cfdca8f6fbcfe5f4e001588d8)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/9ef49fcfe80082aafad3092a268cfbdfbf0733fe)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/99ef922dbe123ff3ae3bf5f74e3811f4695a9cb4)
- [chore(l10n): update French translation](https://github.com/Viren070/AIOStreams/commit/bba83765bf6d3c5da17e55d453931683795569c2)
- [chore(l10n): update Malay translation](https://github.com/Viren070/AIOStreams/commit/7771f46d0a5f8f59bd9a4e5f11d54927acfa8c4d)
- [chore(l10n): update German translation](https://github.com/Viren070/AIOStreams/commit/0d70fb2f56c88cdd45903c21fcffd08b50ff39d8)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/55519ebf8d6dbb94a1548e56634019969c0b7fd2)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/f6896b3f2656d41ec9191a169a73658c578090de)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/1961fb4aec7ceb6eebc3817963fcba31b3cd42e4)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/a7440b01ffff1236d1b2b7a16bc91d695b11cd7e)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/4d34494bc0ddedb648525785f8d106eb0e49d096)
- [chore(l10n): update German translation](https://github.com/Viren070/AIOStreams/commit/170ada0991d4c894481e0e0699e5627eacc7cb7d)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/9670fa16ed951b37c8a8c2ee371b77b9c1ff041b)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/56cb5292bbac61b8aea9495e79b7584f1bc0f80e)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/2edae07c9ae6e208b5d3e4755b84ffc9f425652b)
- [chore(l10n): update Malay translation](https://github.com/Viren070/AIOStreams/commit/bd80d1682be8f86bdc37397b3dc2968ed30e7856)

[Compare 49cc6fa...46f8593](https://github.com/Viren070/AIOStreams/compare/49cc6fa...46f8593)

---

## nightly-49cc6fa — 2026-11-04

- [fix(android): pick the audio output again for a speed change only around passthrough](https://github.com/Viren070/AIOStreams/commit/dfaf8fa9306541327867eb82aeb36813943331fd)
- [fix(android): tell runs with the same pid apart in the doing note](https://github.com/Viren070/AIOStreams/commit/852805f9fb61124af919e30f370c1d8af70b3dfd)
- [feat(web): put the window buttons in the player's top bar](https://github.com/Viren070/AIOStreams/commit/790f107bee188eefcc7a394b19e0f70ecdf5d512)
- [docs: add the player's window buttons hooks](https://github.com/Viren070/AIOStreams/commit/27a3a4b5896e28681307332c78f71f59aceba3c7)
- [feat(web): add a mini player that plays on over the pages](https://github.com/Viren070/AIOStreams/commit/087fc4883f108ae12286daa1a7c90ad5aba9de56)
- [feat(android): show the video small through a hole in the page for the mini player](https://github.com/Viren070/AIOStreams/commit/56bb1ec03a6787b7f9ca69f020bc657a6d495042)
- [feat(desktop): lift the video over the page for the mini player](https://github.com/Viren070/AIOStreams/commit/e4faf227ea19674405a360011b9957eccaf44d78)
- [docs: add the mini player hooks](https://github.com/Viren070/AIOStreams/commit/49cc6fa39af54a5bdb244d897cdf6008a7ebb594)

[Compare 259e769...49cc6fa](https://github.com/Viren070/AIOStreams/compare/259e769...49cc6fa)

---

## nightly-259e769 — 2026-11-03

- [chore: update header presets (#1487)](https://github.com/Viren070/AIOStreams/commit/b921d2634bfe27271eaca3374fd784939ff3b935)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/e460fb18994173761a153da39c2c5736063abe52)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/3cdb5de3aa06731890dac9d96b873fb7ebb00ef3)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/38a753e4ef4fe5e676919835e11ae9ee14ca9aa9)
- [chore(l10n): update Malay translation](https://github.com/Viren070/AIOStreams/commit/56f25befff62dc749409c6c69c91c859e2bdfc91)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/1913f1e1cb69a2a16fdcc5b6ceea055d3b828cbe)
- [chore(l10n): update Turkish translation](https://github.com/Viren070/AIOStreams/commit/d02085b7aa38922785355b527d05e4dbc964c9d5)
- [chore(l10n): update Malay translation](https://github.com/Viren070/AIOStreams/commit/31e2c677dacb760a41d3deb971ed27cc0194d034)
- [chore(l10n): update translation files](https://github.com/Viren070/AIOStreams/commit/06e980234367b58bf31c06b8bf81eb9f19926932)
- [chore(l10n): update Polish translation](https://github.com/Viren070/AIOStreams/commit/52632c59fb9e8d7932d14aa514b7c670494fb98d)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/3acfdfd19a7f5d4eb06d25fe856bb6633adbaf4a)
- [chore(l10n): add Swedish translation](https://github.com/Viren070/AIOStreams/commit/5d930babb0a4aa7405b9861fa6f0af4c74e4fc45)
- [chore(l10n): add Swedish translation](https://github.com/Viren070/AIOStreams/commit/707a8166b354e59746009cb58e4b9613bec26558)
- [chore(l10n): update Italian translation](https://github.com/Viren070/AIOStreams/commit/f9891ea4922991f94ef18cbfa62c881363a6a241)
- [chore(l10n): update Spanish translation](https://github.com/Viren070/AIOStreams/commit/aa0183505e6f058238c5a2ab589ddf702d6022d2)
- [chore(l10n): update Portuguese (Brazil) translation](https://github.com/Viren070/AIOStreams/commit/d93bfcfa3d15fc20e1050762203ff511ac7edcb9)
- [chore(l10n): update Swedish translation](https://github.com/Viren070/AIOStreams/commit/ade6d691c747f6327cc005338f935823525e056c)
- [chore(l10n): update Swedish translation](https://github.com/Viren070/AIOStreams/commit/c0d4458fec64386518ecff9755eb038266908a57)
- [Merge pull request #1693 from Viren070/weblate-aiostreams-web-app](https://github.com/Viren070/AIOStreams/commit/387c4dcd4c548b12df5de33d373c45b89bbe31f4)
- [fix(android): leave the passthrough formats to ExoPlayer's own output check](https://github.com/Viren070/AIOStreams/commit/a4952505d6431d0311ccb951964360f3a1665c1a)

[Compare 0b56aa1...259e769](https://github.com/Viren070/AIOStreams/compare/0b56aa1...259e769)

---

## nightly-0b56aa1 — 2026-11-02

- [fix(web): send planned skips to the Android app only](https://github.com/Viren070/AIOStreams/commit/f8da8c88103606828ee2341b2d33f8550c4bbb2d)
- [fix(android): hide the video SurfaceView itself once the player closes](https://github.com/Viren070/AIOStreams/commit/2764a8aefb0bd58a4f51daf61ef7bcf0f91636f1)
- [fix(android): shape and mix down 5.1.4 and 7.1.4 sound](https://github.com/Viren070/AIOStreams/commit/42a7f1b96ad5aad4e8f6cc1b9c72db2916c38f53)
- [fix(web): start keys on a tab list's selected tab when nothing is focused](https://github.com/Viren070/AIOStreams/commit/dc2b5f4ee07111f469446ac891c5a4965c1fb410)
- [fix(ui): patch Radix Select's onPlaced to a stable callback](https://github.com/Viren070/AIOStreams/commit/233ba8f37ee30b11d7d427e094e795cf3116ba72)
- [fix(desktop): keep the macOS main loop running until the player closes](https://github.com/Viren070/AIOStreams/commit/3f4a5da2f603e1fb08d58a324a406f674bb70170)
- [feat(web): put a server subtitle's title on a line of its own](https://github.com/Viren070/AIOStreams/commit/e2d778bea9b2ba3335bf84de2e84b6f471d51dbe)
- [fix(web): keep the skip flash in place while skips add up](https://github.com/Viren070/AIOStreams/commit/6bc1f6ca7cdc4dc7ec2ead7616e9fc3cc97dba65)
- [feat(web): show the time in the player's top bar](https://github.com/Viren070/AIOStreams/commit/d98ca3676f19ac7bd49ed2507d663cda58284e82)
- [feat(web): play or pause with Select while the player's controls are hidden](https://github.com/Viren070/AIOStreams/commit/cfe54b81859389f6b74e90ac56c65a5df80ee5af)
- [docs: list the player clock and subtitle title hooks](https://github.com/Viren070/AIOStreams/commit/8ea281dc9faec6fd69ccb74ebd6d1ab1fcacc92f)
- [feat(web): add a setting for how long the hero stays on each title](https://github.com/Viren070/AIOStreams/commit/bbf8b5cc90d93502b4b300b670e276a86e5152df)
- [feat(server): mark and explain a title no addon has details for](https://github.com/Viren070/AIOStreams/commit/a34df0c06bff6e8fbafae23cafd581a435b6ed47)
- [feat(web): give shows Play and More info in the rotating hero](https://github.com/Viren070/AIOStreams/commit/bb5e92a6b5ea88c4fe272bcdbbcb1965494af705)
- [feat(web): ask for a metadata addon on a title without details](https://github.com/Viren070/AIOStreams/commit/d042e8a1151191024c0a977f07be6801904fdbba)
- [docs: describe titles without details](https://github.com/Viren070/AIOStreams/commit/d6312f2439615fcc09d762951e2a9425f5e9edfb)
- [feat(desktop): leave a target-peak set in mpv.conf alone on macOS](https://github.com/Viren070/AIOStreams/commit/f9b4fbf6378f7c26f9d29ba7534022d664f4d282)
- [feat(web): put a title's actions in a labelled row and a More sheet on touch screens](https://github.com/Viren070/AIOStreams/commit/d70929b8141c43552c92edca5532084efdd0e781)
- [docs: list the touch screen title actions and how to show more of them](https://github.com/Viren070/AIOStreams/commit/df2f92c233488438fbe77d4dac4875a8c47a28c3)
- [feat(web): bigger icons in the bottom bar without names](https://github.com/Viren070/AIOStreams/commit/95d151a322add2f4392795832ed309209a15ccad)

[Compare c358754...0b56aa1](https://github.com/Viren070/AIOStreams/compare/c358754...0b56aa1)

---

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

