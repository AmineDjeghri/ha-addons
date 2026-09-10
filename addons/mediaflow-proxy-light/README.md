# MediaFlow Proxy Light Home Assistant Addon

HA Addon for [MediaFlow Proxy Light](https://github.com/mhdzumair/MediaFlow-Proxy-Light) — a
fast Rust streaming-media proxy for HTTP(S), HLS and MPEG-DASH streams, with EPG, Xtream,
and extractor support. It is a lighter rewrite of the original Python MediaFlow Proxy.

## Installation
1. Add this addon repository to Home Assistant (`https://github.com/aminedjeghri/ha-addons`)
2. Install the "MediaFlow Proxy Light" addon
3. Set `api_password` (see below) and adjust any other options
4. Start the addon
5. Open the Web UI from the addon page

## Configuration

| Option                   | Default     | Description                                                             | Upstream env var                |
|--------------------------|-------------|-----------------------------------------------------------------------|---------------------------------|
| `api_password`           | *(unset)*   | Password required by every proxy endpoint. **Must be set** (see below). | `APP__AUTH__API_PASSWORD`       |
| `log_level`              | `info`      | Log verbosity: `debug`, `info`, `warn`, `error`.                        | `RUST_LOG` / `APP__LOG_LEVEL`   |
| `workers`                | `0`         | HTTP worker threads. `0` = upstream CPU-core default (not exported).    | `APP__SERVER__WORKERS`          |
| `connect_timeout`        | `30`        | Upstream connection timeout (seconds).                                  | `APP__PROXY__CONNECT_TIMEOUT`   |
| `follow_redirects`       | `true`      | Follow HTTP redirects from upstream servers.                            | `APP__PROXY__FOLLOW_REDIRECTS`  |
| `buffer_size`            | `262144`    | Streaming buffer size (bytes).                                          | `APP__PROXY__BUFFER_SIZE`       |
| `proxy_url`              | *(unset)*   | Outbound proxy URL for upstream requests.                               | `APP__PROXY__PROXY_URL`         |
| `all_proxy`              | `false`     | Route all upstream traffic through `proxy_url`.                         | `APP__PROXY__ALL_PROXY`         |
| `hls_prebuffer_segments` | `5`         | HLS segments to prebuffer.                                              | `APP__HLS__PREBUFFER_SEGMENTS`  |
| `hls_segment_cache_ttl`  | `300`       | HLS segment cache TTL (seconds).                                        | `APP__HLS__SEGMENT_CACHE_TTL`   |
| `hls_inactivity_timeout` | `60`        | Drop an idle HLS session after this many seconds.                       | `APP__HLS__INACTIVITY_TIMEOUT`  |
| `mpd_live_playlist_depth`| `8`         | Segments kept in a live MPEG-DASH playlist.                             | `APP__MPD__LIVE_PLAYLIST_DEPTH` |
| `mpd_live_init_cache_ttl`| `60`        | Live MPEG-DASH init-segment cache TTL (seconds).                        | `APP__MPD__LIVE_INIT_CACHE_TTL` |
| `mpd_remux_to_ts`        | `false`     | Remux MPEG-DASH to MPEG-TS.                                             | `APP__MPD__REMUX_TO_TS`         |
| `drm_key_cache_ttl`      | `3600`      | ClearKey DRM key cache TTL (seconds).                                   | `APP__DRM__KEY_CACHE_TTL`       |
| `epg_cache_ttl`          | `3600`      | EPG cache TTL (seconds).                                                | `APP__EPG__CACHE_TTL`           |
| `acestream_host`         | `localhost` | AceStream engine host.                                                  | `APP__ACESTREAM__HOST`          |
| `acestream_port`         | `6878`      | AceStream engine port.                                                  | `APP__ACESTREAM__PORT`          |

The addon always exports `APP__SERVER__HOST=0.0.0.0` and `APP__SERVER__PORT=8888` so the
proxy is reachable from Home Assistant (upstream defaults to binding `127.0.0.1`).

For the full config surface see the upstream
[`config-example.toml`](https://github.com/mhdzumair/MediaFlow-Proxy-Light/blob/main/config-example.toml).
Every option maps to an `APP__<SECTION>__<KEY>` environment variable (env > TOML > defaults).

### Authentication model (verified against the 1.1.2 binary)

Set a strong `api_password` — for most endpoints it is the only gate. Measured behaviour:

| Endpoint family | Behaviour without `api_password` |
|---|---|
| `/proxy/*` (stream, hls, mpd, epg, acestream, telegram, forward), `/metrics`, `/base64/*`, `/extractor/*` | `401` — fail-closed, even when no password is configured at all |
| `/`, `/index.html`, `/speedtest.html`, `/health`, static assets | reachable (public) |
| `/playlist/builder` | **reachable — and it performs the fetch** (see below) |
| `POST /generate_url` | reachable (mints plain URLs; `_token_` URLs are only usable with the real password) |
| Xtream Codes routes (`/player_api.php`, `/xmltv.php`, `/get.php`, `/<u>/<p>/<id>.<ext>`) | not gated by `api_password`; they validate the XC credential blob (`{base64_upstream}:{username}[:{api_password}]`) |

An empty password locks the `/proxy/*` family but does **not** make the addon inert.

## Usage

All examples assume the addon runs on `YOUR_HA_HOST:8888`.

- **Proxy a stream:**
  `http://YOUR_HA_HOST:8888/proxy/stream?d=<encoded-stream-url>&api_password=<key>`
- **HLS / MPEG-DASH:** `http://YOUR_HA_HOST:8888/proxy/hls/...` and `/proxy/mpd/...`
- **EPG** (for Channels DVR, Plex, Jellyfin, etc.):
  `http://YOUR_HA_HOST:8888/proxy/epg?...&api_password=<key>`
- **Extractor** (resolve a page to a playable URL):
  `http://YOUR_HA_HOST:8888/extractor/video?host=<provider>&d=<page-url>&api_password=<key>`
- **URL builder / generator:** `/generate_url`, `/base64/*`, `/playlist/builder`
- **Health check (no auth):** `http://YOUR_HA_HOST:8888/health` → `200`

### Keeping it on the LAN (recommended)

Never port-forward `8888` — the addon publishes its port directly on your LAN IP and has no
ingress-only mode, so exposure would have to be a deliberate act. Don't:

- **Expose the self-hosted [AIOStreams](../aiostreams) addon instead.** AIOStreams reaches
  this proxy over the LAN and serves Stremio/Nuvio clients through its **own built-in
  proxy**, so only AIOStreams needs a public URL — MediaFlow stays LAN-only. The debrid API
  calls and the stream fetches still originate from the same home IP, which is the whole
  point of running the proxy.
- **Still set a strong `api_password`**: it is the gate for the `/proxy/*` family, and it
  keeps anything else on your network (or a stray browser page) from using the proxy.
- If you ever *do* expose it directly, treat the **whole hostname** as the perimeter — the
  API password does not cover the UI, `/playlist/builder` or `/generate_url`.

### Worth knowing (verified against the 1.1.2 binary)

- **No private-IP guard on the stream paths.** `/proxy/stream`, `/proxy/hls`, `/proxy/mpd`
  and `/proxy/epg` will fetch loopback and RFC-1918 addresses (verified `200` from
  `127.0.0.1`); only `/proxy/forward` enforces the documented `403` SSRF guard. Anyone
  holding the password (or a leaked URL) can therefore reach unauthenticated services on your
  LAN. Redirects are also followed into private ranges — set `follow_redirects: false` if you
  don't need them.
- **CORS reflects any `Origin`** (`Access-Control-Allow-Origin` + `Allow-Credentials: true`),
  so a web page open on your network can read responses from a reachable instance.
- **`/playlist/builder` and `/generate_url` are not password-gated** — `/playlist/builder`
  performs a server-side fetch of any URL you hand it. One more reason to keep the addon on
  the LAN, as above.

### Resources

Measured on the prebuilt release binary (amd64):

- Idle: ~18 MB RSS, ~0% CPU.
- Under 6 concurrent 200 MB streams: RSS stays roughly flat at ~16–18 MB, ~25% of one core.
- Image: ~90–130 MB compressed (estimate).
- Stateless — the addon uses no `/data` and nothing is persisted.

Upstream's [benchmarks](https://github.com/mhdzumair/MediaFlow-Proxy-Light#benchmarks) report
7.5–8.2× less memory than the original Python proxy, making a 512 MB VPS viable.

#### Bandwidth & concurrency

The addon is a relay — every stream flows `source → addon → player` — so the only real
constraint is the **upload bandwidth of the machine running it**. The proxy itself is
negligible: ~18 MB RSS and ~0% CPU idle, ~25% of one core under 6 concurrent streams (rated
for ~100 concurrent connections at ≈200 MB RSS upstream).

**Per stream (typical):**

| Quality | Bitrate |
|---|---|
| 720p | ~3–5 Mbps |
| 1080p | ~8–12 Mbps |
| 4K (streaming) | ~20–30 Mbps |
| 4K remux (full bitrate) | ~60–100 Mbps |

**Total upload needed, by concurrent viewers:**

| Concurrent viewers | 720p | 1080p | 4K |
|---|---|---|---|
| 2 | ~6–10 Mbps | ~16–24 Mbps | ~40–60 Mbps |
| 3 | ~9–15 Mbps | ~24–36 Mbps | ~60–90 Mbps |
| 4 | ~12–20 Mbps | ~32–48 Mbps | ~80–120 Mbps |

So **2–4 viewers at 1080p** fits any fibre line with room to spare; a single 4K remux can
saturate a 100 Mbps upload, and 4× 4K needs a fast symmetric line. Watch real throughput on
`GET /metrics` (requires `api_password`) or your router.

Two non-proxy limits to keep in mind for a shared setup:

- **Debrid concurrent-stream limits** — one account shared by 4 viewers can hit the
  provider's own simultaneous-stream cap regardless of proxy headroom.
- **One shared identity** — every viewer leaves through the proxy's public IP (that's what
  fixes multi-IP issues), so provider activity and limits apply to the account as a whole.

## Notes

- **Transcode and Redis are compile-time opt-in features** — they are *not* compiled into the
  prebuilt release binaries this addon ships (upstream `docs/reference/limitations.md`:
  `--features "redis,transcode"` requires building from source). Installing `ffmpeg` into the
  image would **not** enable transcoding, so neither is exposed.
- **Telegram** streaming needs its own API credentials and an MTProto session — not exposed.
  **Acestream** works via the exposed `acestream_host` / `acestream_port` options, but the
  addon does not bundle an Acestream engine.
- Only `amd64` and `aarch64` are supported — upstream publishes no `armv7` build.
- The addon version follows upstream releases and is auto-bumped daily by the repo's
  `upstream-bump` workflow. The new binary is fetched at image build time, so the update
  applies when you press **Update** (rebuild) in the HA UI — a plain restart is not enough.
