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

**`base_url`** is the public URL the addon is reached at: it is embedded in the manifest and in
every stream link a client holds, so it must be the hostname the addon is actually reachable on and
changing it later means reinstalling the manifest in every client. Create that hostname **first**, in
the **Cloudflared** add-on: add `hostname: aiostreams.example.com` with
`service: http://homeassistant.local:3000` to `additional_hosts`, then save and restart it — the
add-on creates the tunnel rule and the proxied DNS record itself, so there is nothing to add in the
Cloudflare dashboard. Until this add-on is running, that hostname answers Cloudflare's `502`.

## First run

1. Create the public hostname for the addon first and set `base_url` to it — see the `base_url`
   note above. Stremio refuses non-HTTPS addons that are not on localhost.
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

### MediaFlow: LAN playback vs. away-from-home

The proxy **URL** is used by this add-on itself, but the **player** fetches the stream URL it
was handed — so a LAN address plays on the home Wi-Fi and fails over cellular, where
`192.168.x.x` is unroutable.

- **URL** — an address this add-on can reach: the HA host's LAN address, e.g.
  `http://<ha-host-ip>:8888`.
- **Public IP** — the proxy's public IP (the MediaFlow add-on logs `Detected public IP: …` at
  startup). Required whenever **URL** is a private address: without it AIOStreams skips the
  lookup, gets nothing back, and the request dies with
  `Failed to get Proxy public IP after 3 attempts`.
- **Public URL** — an address players can reach (a tunnel hostname for the MediaFlow add-on).
  Required for playback away from home; leave empty while every client is on the LAN.
- **Credentials** — the MediaFlow add-on's `api_password`; every `/proxy/*` endpoint answers
  `401` without it.
- If the proxy must stay unexposed, use the **built-in proxy** instead: its stream URLs point at
  this add-on's own public URL, so away-from-home playback works without publishing MediaFlow.

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

## Exposure & blocked URLs

This add-on is meant to be published through the Cloudflared tunnel, on its own hostname.
That is deliberate: Stremio/Nuvio-class clients are
header-less and cannot answer a Cloudflare Access challenge, so the app's own login is the
gate. **Keep `auth` set and `auth_required: true`** — an empty `auth` leaves the whole
dashboard (and your debrid credentials) open.

Block them with one WAF custom rule (Security → WAF → Custom rules), action **Block**, scoped to
this add-on's tunnel hostname — paste the expression below but **replace `<addon-hostname>` with
the hostname you assigned this add-on in the Cloudflared add-on's `additional_hosts`**. The rule
matches that literal string, so a leftover placeholder silently matches nothing and blocks nothing:

```
(http.host eq "<addon-hostname>" and (http.request.uri.path eq "/api/v1/status" or starts_with(http.request.uri.path, "/builtins/") or http.request.uri.path eq "/metrics"))
```

Never put Cloudflare Access or a Managed/JS Challenge on this hostname — clients are header-less.
Add a **Bypass cache** Cache Rule for it too (Caching → Cache Rules). Rate limiting is optional
here: this add-on already rate-limits logins and Stremio catalog requests itself, and free plans
include only one such rule, which the proxy hostname needs more.

Why those three: `/api/v1/status` is a ~293 KB unauthenticated dump of server settings and flags
(the HA watchdog reads it over the LAN, which never passes through Cloudflare), `/builtins/*` are
internal engine routes already `403` without the internal key, and `/metrics` isn't served today.

Verify from outside the LAN: the blocked paths must return Cloudflare's "Sorry, you have been
blocked" page — if they still return app content, the rule's hostname doesn't match the real one.

Everything else stays reachable: `/api/v1/*` is account-gated, and
`/stremio/<uuid>/<encryptedPassword>/…` embeds the credential **in the URL** — treat an
installed manifest URL as a bearer secret. Rate-limit the hostname.
