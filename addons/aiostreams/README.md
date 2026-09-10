# AIOStreams Home Assistant Addon

HA Addon for [AIOStreams](https://github.com/Viren070/AIOStreams) — a self-hosted Node.js
Stremio addon that aggregates other Stremio addons plus debrid, usenet and torrent services
behind a single manifest, with its own proxying, filtering, sorting and deduplication. Full
documentation: <https://docs.aiostreams.viren070.me>.

## Installation

1. Add this addon repository to Home Assistant (`https://github.com/aminedjeghri/ha-addons`)
2. Install the "AIOStreams" addon
3. Fill the required options `base_url` and `secret_key` (see below), and set `auth`
4. Start the addon
5. Open the **Web UI** from the addon page — it lands on `/stremio/configure`

## Configuration

| Option          | Default   | Description                                                                                                                                             |
|-----------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| `base_url`      | *(unset)* | **Required.** Public HTTPS URL this instance is reached at, e.g. `https://aiostreams.example.com`. Stremio requires HTTPS for non-localhost addons.     |
| `secret_key`    | *(unset)* | **Required.** 64-char hex string that encrypts stored credentials. Generate with `openssl rand -hex 32`. **Cannot be changed after the first start.**   |
| `auth`          | *(unset)* | Comma-separated `user1:pass1,user2:pass2` pairs allowed to open the dashboard. Empty = no login at all (see warnings).                                  |
| `auth_required` | `true`    | Require one of the `auth` accounts to log in. Locked read-only in the dashboard because it is set here.                                                 |
| `log_level`     | `info`    | One of `error`, `warn`, `info`, `http`, `verbose`, `debug`, `silly`.                                                                                   |

## First run

1. Expose the addon over **HTTPS** — e.g. point the **Cloudflare** add-on at
   `http://homeassistant.local:3000` and set `base_url` to the resulting public `https://…`
   hostname. Stremio refuses non-HTTPS addons that are not on localhost.
2. Generate `secret_key` once with `openssl rand -hex 32` and keep it permanently — changing
   it later makes every stored credential unreadable.
3. Start the addon, open the Web UI (`/stremio/configure`), build your configuration, then
   install the generated manifest URL into Stremio, Nuvio and other Stremio-addon clients.

## Storage

Everything lives under `/data`, which is included in Home Assistant snapshots:

- `/data/db.sqlite` — the database. The addon wires `DATABASE_URI` to this path.
- `/data/cache` — disk cache holding usenet segments, grabbed NZBs and torrent metadata. It
  **grows with use** — monitor it and clear it if the addon disk fills up.

## Proxy architecture

Recommended setup: enable AIOStreams' **built-in proxy** and keep the **MediaFlow Proxy**
add-on on the LAN (unexposed). Only AIOStreams is then reachable from the internet, and
debrid API calls and stream fetches all leave from the same public IP — which is what debrid
services expect.

## Updates

This addon tracks the upstream **`nightly`** channel:

- `version:` is `nightly-<sha7>` of upstream `main`; the `nightly` image is bumped daily by
  this repo's `upstream-bump` workflow.
- Each update **recreates the container** — expect brief downtime, and sometimes database
  migrations on the first boot after an update.

## Warnings

- **`nightly` is a beta channel.** It builds from the latest upstream commit and can break
  between updates.
- **If `auth` is empty, anyone who can reach `base_url` can use your instance** — including
  the debrid/usenet credentials you configured. Set `auth` unless the URL is otherwise
  protected.
- You are responsible for complying with the terms of service and the laws that apply to the
  content sources you configure AIOStreams to aggregate.
