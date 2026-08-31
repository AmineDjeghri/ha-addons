# Changelog

For full upstream release notes see the [official Octo-Fiesta releases](https://github.com/V1ck3s/octo-fiesta/releases).

## dev-798eaee — 2026-08-31

- [feat(tidal): add native Tidal provider](https://github.com/V1ck3s/octo-fiesta/commit/798eaeeb88fa399587a6faaa2fe9fcf43fa1d401)

[Compare 410e862...798eaee](https://github.com/V1ck3s/octo-fiesta/compare/410e862...798eaee)

---

## dev-410e862 — 2026-08-29

- [refactor(squidwtf): remove Amazon Music and Deemix backends](https://github.com/V1ck3s/octo-fiesta/commit/0e7d5416000be1e49638bab361cd5d283328be61)
- [feat: default to Deezer and deprecate SquidWTF provider](https://github.com/V1ck3s/octo-fiesta/commit/c5a90ab781e83a9dfe78a4e806744c5f9cbde96a)
- [fix(squidwtf): reject Tidal preview clips instead of saving them as full tracks](https://github.com/V1ck3s/octo-fiesta/commit/410e8628222121f3c17f4f4a591bec2e452489b2)

[Compare ac35be3...410e862](https://github.com/V1ck3s/octo-fiesta/compare/ac35be3...410e862)

---

## dev-ac35be3 — 2026-08-18

- [feat(squidwtf): Amazon Music backend via amz.squid.wtf](https://github.com/V1ck3s/octo-fiesta/commit/6afc3c7c6297d7943be9fb18a48d3a1f6c014d02)
- [fix(squidwtf): demux Amazon Music FLAC from MP4 container to raw FLAC](https://github.com/V1ck3s/octo-fiesta/commit/3fa843a3a6d95b87417a3e0ebb932d21d347e6c6)
- [fix(dedup): normalize dashes and diacritics for title matching](https://github.com/V1ck3s/octo-fiesta/commit/c1fb4486778eca5127fe1fe9d7920ec635805ca3)
- [fix(squidwtf): replace ffmpeg CENC decryption with pure C# implementation](https://github.com/V1ck3s/octo-fiesta/commit/f3b35f720bb526bcaebff12b11cbde8781840b39)
- [feat(squidwtf): Amazon Music backend via amz.squid.wtf](https://github.com/V1ck3s/octo-fiesta/commit/3884863cf7877211c81d30b5b42ba285de94fabb)
- [fix(squidwtf): demux FLAC from MP4 container after pure C# CENC decryption](https://github.com/V1ck3s/octo-fiesta/commit/f9d169ec6fe0b8591a671d484156f6c782db2835)
- [fix(squidwtf): demux FLAC from MP4 container after pure C# CENC decryption](https://github.com/V1ck3s/octo-fiesta/commit/a664a2bddbb34b39f7ccf98f3a5dcdd220bfe382)
- [fix(squidwtf): avoid stray empty .flac when demux finds no STREAMINFO](https://github.com/V1ck3s/octo-fiesta/commit/831ec8efdbd944a88ebfba4fb8824e33f0694677)
- [fix(squidwtf): fix Amazon Music API authentication flow](https://github.com/V1ck3s/octo-fiesta/commit/227ea88507ac0dd36df9d16654ed9e13886cf536)
- [fix(squidwtf): fix Amazon Music API authentication flow](https://github.com/V1ck3s/octo-fiesta/commit/058e57268e9a18c83abbd4f113c548fc164dc01c)
- [fix: permanentize cached tracks on full album download](https://github.com/V1ck3s/octo-fiesta/commit/6cac1a5dc3e95f167596b2ccba30f01106001f17)
- [fix: permanentize cached tracks on full album download](https://github.com/V1ck3s/octo-fiesta/commit/fe963a4e356e434d5f66e5de290b866da167a3e8)
- [Add Wavio to the list of compatible clients](https://github.com/V1ck3s/octo-fiesta/commit/a158da9455d0c7d958222a72a2410eeaaa04caf7)
- [docs: add wavio to compatible clients](https://github.com/V1ck3s/octo-fiesta/commit/966a07fb2e9420925dfe5c68aeb6cf4f527f9b2b)
- [feat(subsonic): add DisableLibraryScan option](https://github.com/V1ck3s/octo-fiesta/commit/93745b06996cab03f0aad6f8bfacc37a1e62d29b)
- [fix(deezer): decrypt fallback tracks with the alternative track id](https://github.com/V1ck3s/octo-fiesta/commit/121106447b8ed660f03ca92acb2fd9f287b97921)
- [fix(subsonic): stream owned songs locally instead of re-downloading](https://github.com/V1ck3s/octo-fiesta/commit/dd2fa49041cf30825314f38acab2f26e445577d2)
- [fix(deezer): decrypt fallback/alternative tracks with the correct track id](https://github.com/V1ck3s/octo-fiesta/commit/afccf89953799c070bc89b79f239b3d7318cb4c6)
- [fix(subsonic): skip re-downloading tracks already in the library](https://github.com/V1ck3s/octo-fiesta/commit/10f20d6e043009f9a1c7c16d53e6dcfe335e5fee)
- [fix(deezer): retry metadata calls on transient throttling](https://github.com/V1ck3s/octo-fiesta/commit/d96335bc98de289182605d8ea2c1a9723d59a8cc)
- [fix(subsonic): stream already-owned songs from the library instead of re-downloading](https://github.com/V1ck3s/octo-fiesta/commit/3ee9c9330804de35eabec6447cc489fe1afe3ec0)
- [fix(subsonic): keep quality upgrade on play for owned songs](https://github.com/V1ck3s/octo-fiesta/commit/a1ec833fc9805db6a5170a1a777a39534dae0eef)
- [fix(deezer): retry metadata calls on transient throttling](https://github.com/V1ck3s/octo-fiesta/commit/47054f707e141e2d252cfb8f6fe3804a71c7d72a)
- [refactor(subsonic): share the library search, keep the fallback off the hot path](https://github.com/V1ck3s/octo-fiesta/commit/68f5c8f94195e4fc5fba6bc4670449cd71fa881d)
- [fix(subsonic): skip re-downloading tracks already in the library](https://github.com/V1ck3s/octo-fiesta/commit/28c90a66080d80e053434940f068d27c8a904895)
- [fix(subsonic): require artist match when resolving owned library songs](https://github.com/V1ck3s/octo-fiesta/commit/bd1b664d902e43efb1f83d0181a68e3ae4a5e81d)
- [refactor(subsonic): tidy owned-song path resolver](https://github.com/V1ck3s/octo-fiesta/commit/19508f3da650e3fd6db0c31d6b736acc0b7fa20a)
- [feat: add Deemix SquidWTF provider](https://github.com/V1ck3s/octo-fiesta/commit/0f37bac51b3fadeb9e0ddf5236c6a1e80dc64508)
- [feat: add Deemix SquidWTF provider](https://github.com/V1ck3s/octo-fiesta/commit/4c213bf322e811476bc9f359f0ef56cd9f69212d)
- [fix(squidwtf): correct deemix artist ids, discography key and int parsing](https://github.com/V1ck3s/octo-fiesta/commit/8159321a7b95757b9a96afca82c45837942f4757)
- [fix(subsonic): resolve downloaded external songs to their real navidrome id](https://github.com/V1ck3s/octo-fiesta/commit/c9c272b2c68c0cf83fad99077c5ac7c8df876727)
- [fix(subsonic): disambiguate homonym artists when merging external albums](https://github.com/V1ck3s/octo-fiesta/commit/1c071790b690445a16d2cbe20d84aadbfa9f5d86)
- [fix(subsonic): report external songs on disc 1 instead of disc 0](https://github.com/V1ck3s/octo-fiesta/commit/ac35be3f400bc984bfe79c2f4b17ee2874b4c601)

[Compare v0.10...ac35be3](https://github.com/V1ck3s/octo-fiesta/compare/v0.10...ac35be3)

---
