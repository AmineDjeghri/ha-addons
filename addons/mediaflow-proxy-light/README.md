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

### `api_password` is required

Upstream treats authentication as mandatory: **without `api_password` set, every proxy
endpoint returns `401`**. Only `GET /health` and the web UI at `/` are reachable
unauthenticated. Set a strong value in the addon options before relying on the proxy.

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

### Securing your instance

The proxy only listens on your LAN — **never port-forward `8888`**. Recommended exposure:
a **Cloudflare Tunnel** (map a hostname to `http://homeassistant.local:8888`) with
**Cloudflare Access** in front, and a strong `api_password` as the second gate
(unset ⇒ every `/proxy/*` and `/metrics` request returns `401`).

Access rules should be split **by path**, because who calls each path differs:

- **Stream / API paths** — `/proxy/*`, `/player_api.php`, `/xmltv.php`, `/get.php`,
  `/generate_url`, `/base64/*`, `/extractor/*` — use a **service-token** rule
  (`CF-Access-Client-Id` / `CF-Access-Client-Secret` request headers). Stremio-style add-ons
  that only accept a base URL + password still work: run
  `cloudflared access tcp --hostname mediaflow.yourdomain.com --url http://localhost:PORT`
  next to the add-on and point it at `localhost:PORT` — cloudflared attaches the token
  headers automatically. A leaked stream URL then bounces at the edge instead of reaching
  the proxy.
- **Web UI** (`/` and friends) — use an **email-OTP** rule for yourself in the browser.

Add a WAF rate-limit rule on the hostname. For clients that support it, prefer upstream's
`/generate_url` **signed, expiring URLs** over embedding the master password in stream URLs.

> **Why not a service token everywhere?** A service token is a single long-lived shared
> secret with no user identity and no expiry — if it leaks you must rotate it manually
> everywhere it is used, and it grants full access to every client that holds it. It is a
> machine credential, not a replacement for per-user auth: browsers cannot attach it without
> exposing it in the page, and the local `cloudflared access tcp` forwarder means anyone who
> compromises the add-on host bypasses the edge rule entirely.

### Resources

Measured on the prebuilt release binary (amd64):

- Idle: ~18 MB RSS, ~0% CPU.
- Under 6 concurrent 200 MB streams: RSS stays roughly flat at ~16–18 MB, ~25% of one core.
- Image: ~90–130 MB compressed (estimate).
- Stateless — the addon uses no `/data` and nothing is persisted.

Upstream's [benchmarks](https://github.com/mhdzumair/MediaFlow-Proxy-Light#benchmarks) report
7.5–8.2× less memory than the original Python proxy, making a 512 MB VPS viable.

## Notes

- **Transcode endpoints are disabled** — the image ships no `ffmpeg`, matching upstream's
  distroless image. The `[transcode]` config is not exposed.
- **Redis** (external infra) and **Telegram** (a compile-time feature) options are not exposed.
- Only `amd64` and `aarch64` are supported — upstream publishes no `armv7` build.
- The addon version follows upstream releases and is auto-bumped daily by the repo's
  `upstream-bump` workflow. The new binary is fetched at image build time, so the update
  applies when you press **Update** (rebuild) in the HA UI — a plain restart is not enough.
