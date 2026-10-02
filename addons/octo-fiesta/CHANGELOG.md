# Changelog

For full upstream release notes see the [official Octo-Fiesta releases](https://github.com/V1ck3s/octo-fiesta/releases).

## dev-6841a2e — 2026-10-02

- [fix(subsonic): keep external downloads alive when the client disconnects](https://github.com/V1ck3s/octo-fiesta/commit/6841a2ea9c227b212157d81acc4aafa5965419b2)

[Compare a8386e8...6841a2e](https://github.com/V1ck3s/octo-fiesta/compare/a8386e8...6841a2e)

---

## dev-a8386e8 — 2026-10-01

- [fix(subsonic): never drop a library scan request](https://github.com/V1ck3s/octo-fiesta/commit/a8386e82aee0e03bd80d7ecabae1efdc561d0832)

[Compare 3f2d5c4...a8386e8](https://github.com/V1ck3s/octo-fiesta/compare/3f2d5c4...a8386e8)

---

## dev-3f2d5c4 — 2026-09-21

- [feat: upgrade remaining album tracks during a quality upgrade](https://github.com/V1ck3s/octo-fiesta/commit/8c7b10285fe572c91bcd2b28655a26291266f1d1)
- [fix(subsonic): forward upstream response headers on relayed requests](https://github.com/V1ck3s/octo-fiesta/commit/edb647d37bcb289a5028da69a6462c494e64917e)
- [feat(tidal): log in as the public web client with PKCE](https://github.com/V1ck3s/octo-fiesta/commit/8dea9c6e65be9b62ddf4fbe679703f102dce0928)
- [fix(tidal): warn on lossy fallback and rank the upgrade target](https://github.com/V1ck3s/octo-fiesta/commit/3f2d5c4ae458826ebe54c7d8fa8329c021f06f7a)

[Compare afa6259...3f2d5c4](https://github.com/V1ck3s/octo-fiesta/compare/afa6259...3f2d5c4)

---

## dev-afa6259 — 2026-09-16

- [feat: add artist letter to path template](https://github.com/V1ck3s/octo-fiesta/commit/afa6259a1bbf2d34202b054e3da4f0797eca937d)

[Compare a1db7fa...afa6259](https://github.com/V1ck3s/octo-fiesta/compare/a1db7fa...afa6259)

---

## dev-a1db7fa — 2026-09-12

- [feat(subsonic): merge provider catalogue into getTopSongs](https://github.com/V1ck3s/octo-fiesta/commit/76ba52db1fb5db9ec8cfa0e744528fc4f4532413)
- [fix(subsonic): drop irrelevant provider playlists from search3](https://github.com/V1ck3s/octo-fiesta/commit/8caceb7fb6c2a038a59036efac55b38743e1ebe3)
- [feat(subsonic): merge provider catalogue into getTopSongs](https://github.com/V1ck3s/octo-fiesta/commit/723693b007e027acc6deb8e2863d36295d7cda1a)
- [refactor(subsonic): reuse the artist credit helper in getTopSongs](https://github.com/V1ck3s/octo-fiesta/commit/d2172c99fe8e3c4b8dadd4bbd8ea83956da81763)
- [fix(subsonic): drop irrelevant provider playlists from search3](https://github.com/V1ck3s/octo-fiesta/commit/cee7e80fbbc72040e5440bcd99846c6538fac947)
- [refactor(subsonic): fold playlist query normalization into the shared helper](https://github.com/V1ck3s/octo-fiesta/commit/a1db7fae18794e3283fbe77ffbf0cd1cd06502ad)

[Compare c4d0f57...a1db7fa](https://github.com/V1ck3s/octo-fiesta/compare/c4d0f57...a1db7fa)

---

## dev-c4d0f57 — 2026-09-05

- [fix(subsonic): run quality upgrade in background instead of blocking playback](https://github.com/V1ck3s/octo-fiesta/commit/c4d0f5734d1868b8f3f4c031566b705480c32efd)

[Compare 0314a42...c4d0f57](https://github.com/V1ck3s/octo-fiesta/compare/0314a42...c4d0f57)

---

## dev-0314a42 — 2026-09-04

- [fix(subsonic): upgrade quality on play for library songs](https://github.com/V1ck3s/octo-fiesta/commit/0314a427b6861b6ab8126ce9ce979fd5ed57e878)

[Compare 51b1104...0314a42](https://github.com/V1ck3s/octo-fiesta/compare/51b1104...0314a42)

---

## dev-51b1104 — 2026-09-01

- [fix(ci): version dev images from the newest tag instead of git describe](https://github.com/V1ck3s/octo-fiesta/commit/5f5cae75f0a927c024a3732c8a1570580116d302)
- [fix(qobuz): paginate playlist track fetching](https://github.com/V1ck3s/octo-fiesta/commit/57c1e260779538ac052182ed12cff9119f9a67ab)
- [fix(subsonic): merge owned albums into external artist discography](https://github.com/V1ck3s/octo-fiesta/commit/6296cb1cf5cc9bd324e0a66da9ee43e4e8d86882)
- [fix(subsonic): merge external albums for xml clients on getArtist](https://github.com/V1ck3s/octo-fiesta/commit/63032b9d93974641c8a6a56e7b1ddcdad5c28a56)
- [fix(subsonic): merge external songs for xml clients on getAlbum](https://github.com/V1ck3s/octo-fiesta/commit/d186c6f9983a251eb8e9f4fb83296d7742f952d2)
- [fix(subsonic): stop merging homonym artist albums on getAlbum](https://github.com/V1ck3s/octo-fiesta/commit/51b11043753a63a788f4017c70de4ae79179db59)

[Compare 798eaee...51b1104](https://github.com/V1ck3s/octo-fiesta/compare/798eaee...51b1104)

---

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

