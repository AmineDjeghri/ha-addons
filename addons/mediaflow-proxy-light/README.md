# MediaFlow Proxy Light Home Assistant Addon

HA Addon for [MediaFlow Proxy Light](https://github.com/mhdzumair/MediaFlow-Proxy-Light) — a
fast Rust streaming-media proxy for HTTP(S), HLS and MPEG-DASH streams, with EPG, Xtream
and extractor support.

## Installation
1. Add this addon repository to Home Assistant (`https://github.com/aminedjeghri/ha-addons`)
2. Install the "MediaFlow Proxy Light" addon
3. Set `api_password` (see below) and adjust any other options
4. Start the addon
5. Open the Web UI from the addon page

## Configuration

| Option                   | Default     | Description                                                             | Upstream env var                |
|--------------------------|-------------|-----------------------------------------------------------------------|---------------------------------|
| `api_password`           | *(unset)*   | Password required by every proxy endpoint. **Must be set**.             | `APP__AUTH__API_PASSWORD`       |
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

`api_password` is required and is the gate for the `/proxy/*` family, so set a strong one.
The addon always exports `APP__SERVER__HOST=0.0.0.0` and `APP__SERVER__PORT=8888` so the
proxy is reachable from Home Assistant (upstream binds `127.0.0.1`); every option above maps
to an `APP__<SECTION>__<KEY>` env var. Full surface: upstream
[`config-example.toml`](https://github.com/mhdzumair/MediaFlow-Proxy-Light/blob/main/config-example.toml).

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

Never port-forward `8888`. **Expose the self-hosted [AIOStreams](../aiostreams) addon
instead** — it reaches this proxy over the LAN and serves Stremio/Nuvio clients through its
own built-in proxy, so only AIOStreams needs a public URL and the debrid calls still leave
from your home IP. Keep a strong `api_password` anyway. If you ever do expose the addon
directly, treat the **whole hostname** as the perimeter — the password does not cover the UI,
`/playlist/builder` or `/generate_url`.

### Resources

Measured on the prebuilt release binary (amd64): ~18 MB RSS and ~0% CPU idle, holding at
~16–18 MB and ~25% of one core under 6 concurrent 200 MB streams; ~90–130 MB compressed
image; stateless (no `/data`). Upstream's
[benchmarks](https://github.com/mhdzumair/MediaFlow-Proxy-Light#benchmarks) report 7.5–8.2×
less memory than the original Python proxy.

#### Bandwidth & concurrency

This addon is a relay — every stream flows `source → addon → player` — so the only real
constraint is the **upload bandwidth of the machine running it**; the proxy itself is
negligible (~18 MB RSS, ~25% of one core under load).

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

2–4 viewers at 1080p fits any fibre line; one 4K remux can saturate a 100 Mbps upload. A
single debrid account shared by all viewers is also subject to the provider's own
concurrent-stream limit. Watch real throughput on `GET /metrics`.

## Notes

- **Transcoding and Redis are compile-time opt-in features** and are *not* in the prebuilt
  release binaries this addon ships — installing `ffmpeg` would not enable transcoding, so
  neither is exposed. Telegram streaming needs its own API credentials and an MTProto
  session (not exposed); Acestream works through the `acestream_host` / `acestream_port`
  options, but no engine is bundled.
- Only `amd64` and `aarch64` are supported — upstream publishes no `armv7` build.
- The version follows upstream releases and is auto-bumped daily by `upstream-bump`. The
  binary is fetched at image build time, so an update needs **Update** (rebuild) in the HA
  UI — a plain restart is not enough.

## Exposure & blocked URLs

**LAN-only — do not publish.** This add-on is intentionally not in the Cloudflared tunnel;
AIOStreams reaches it over the LAN (see [Keeping it on the LAN](#keeping-it-on-the-lan-recommended)).

If it is ever published anyway, this is the order that matters:

| Path | State without a password | Why it must be blocked first |
|---|---|---|
| `/playlist/builder?url=<any>` | `200` **with the fetched body** | Unauthenticated fetch primitive that doubles as a LAN port/host scanner |
| `/proxy/forward` | `401` | Transparent any-method full relay |
| `/proxy/*`, `/base64/*`, `/extractor/*`, `/metrics` | `401` | SSRF by design once the password leaks |
| `/`, `/health` | `200` by design | Enumerable, unprotected |

The `api_password` covers `/proxy/*`, not the UI/builder paths — the whole hostname is the
perimeter. `/generate_url` is not served by this build (`404`).
