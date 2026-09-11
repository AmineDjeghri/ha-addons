# Octo-Fiesta Home Assistant Addon

HA Addon for [Octo-Fiesta](https://github.com/V1ck3s/octo-fiesta)

## Installation
1. Add this addon repository to Home Assistant (https://github.com/aminedjeghri/ha-addons)
2. Install the "Octo-Fiesta" addon
3. Configure your settings (see below)
4. Start the addon

## Configuration

### Basic Setup

The addon comes with default settings pointing to a local Navidrome server on port 4533. Every setting below is a normal add-on **option** (Add-on page → Configuration) — the add-on maps them to the `.NET` `Section__Key` environment variables itself, there is no separate environment-variable box to fill.

**Required:**
- `subsonic_url`: URL to your Navidrome server (default: `http://homeassistant.local:4533`)

### Advanced Configuration

All other settings are options on the same Configuration page (`music_service`, `deezer_arl`,
`qobuz_auth_token`, `squidwtf_*`, `library_download_path`, `lyrics_*`, …) — see the mapping
table in [Octo-Fiesta's configuration docs](https://github.com/V1ck3s/octo-fiesta/wiki/Configuration).

## Usage

### Connecting Your Client

Point your Subsonic-compatible client to:
```
http://YOUR_HA_IP:5274
```

Use the same credentials as your Navidrome server.

## Exposure & blocked URLs

**LAN-only — do not publish.** This add-on authenticates with your Navidrome user
credentials, so a leaked Subsonic credential is usable access to both services.

| Path | State without credentials (LAN) | Why it must never be public |
|---|---|---|
| `/swagger`, `/docs`, `/health` | `200`, no auth | Swagger UI enumerating the whole API — `/health` serves the same page, there is no separate health route |
| `/rest/*` | `401` | Subsonic API; `/rest/startScan`, `/rest/createPlaylist`, `/rest/deletePlaylist` write to the library |
| `/`, web UI `:5274` | `200` | `{"status":"ok"}` and the UI |

If you ever do publish it, block `/swagger`, `/docs` and `/health` at the edge first — they
are the only unauthenticated paths.
