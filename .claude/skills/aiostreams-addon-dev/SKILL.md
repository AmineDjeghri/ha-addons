---
name: aiostreams-addon-dev
description: Develop and deploy addons/aiostreams — the AIOStreams (Stremio/Nuvio) aggregator add-on, a distroless-image, bootstrap-based add-on with a nightly upstream channel.
---

# AIOStreams Add-on

`addons/aiostreams/` wraps [AIOStreams](https://github.com/Viren070/AIOStreams), a Stremio/Nuvio
stream-aggregation service, as a nightly-tracked, distroless-base add-on. General add-on packaging
conventions live in the `home-assistant-addon-dev` skill; this is what's specific to this add-on.

## Upstream facts

- Images: `ghcr.io/viren070/aiostreams` (+ Docker Hub mirror). Tags: `latest` (stable), `nightly`
  (latest commit), `dev`, semver tags. Platforms: linux/amd64 + linux/arm64 only (no armv7).
- **The runtime image is distroless** (`FROM gcr.io/distroless/nodejs24-debian12`) — no shell, no
  apt/apk, no curl/jq. This add-on therefore uses the "distroless base + language-native bootstrap"
  pattern documented in `home-assistant-addon-dev`'s `versioning-patterns.md`, not bashio.
- Required env: `BASE_URL` (public HTTPS URL — Stremio refuses non-HTTPS, non-localhost add-ons)
  and `SECRET_KEY` (64 hex chars). **`SECRET_KEY` is immutable after first run** — rotating it
  makes every stored client configuration undecryptable, so it lives in add-on options (covered by
  HA snapshots) and should never be rotated casually.
- State: SQLite DB + a disk cache for grabbed metadata, both under `/data`; the cache grows over
  time and is worth monitoring.
- Health path is `/api/v1/status` (from upstream's own `HEALTHCHECK`, not a guess); human entry
  point is `/stremio/configure`.

## Add-on design

- `build.json` pins `ghcr.io/viren070/aiostreams:nightly` unchanged — the image *is* the add-on.
- `Dockerfile` is a thin wrapper: `ARG BUILD_FROM` → `FROM ${BUILD_FROM}`, `COPY bootstrap.js`,
  `ENTRYPOINT ["/nodejs/bin/node", "/bootstrap.js"]`; keep the base image's own `HEALTHCHECK`.
- `bootstrap.js` (Node builtins only, CommonJS): reads `/data/options.json` directly, fails fast
  with an actionable message when `base_url` is empty or `secret_key` isn't exactly 64 hex chars,
  maps options to `BASE_URL`/`SECRET_KEY`/`DATABASE_URI=sqlite:///data/db.sqlite`/
  `DISK_CACHE_DIR=/data/cache`/`PORT`/`LOG_LEVEL`/auth vars, creates the cache dir, logs one INFO
  line that never prints the secret, then `spawn`s the server and forwards signals.
- `config.yaml`: 5 options mirrored 1:1 in `schema` — `base_url` (required `url`), `secret_key`
  (required in practice, `password?` + a detect-secrets pragma), `auth` (comma-separated
  `user:pass` pairs), `auth_required` (bool, default true), `log_level`. No `map:` — all state is
  under `/data`.
- Version tracking: nightly/dev-branch-SHA pattern (`nightly-<sha7>`) — see
  `versioning-patterns.md` for the generic mechanics; the bump job touches `config.yaml` only,
  `build.json` stays pinned to `:nightly`.

## Testing the auth gate in CI

`/stremio/configure` sits behind session middleware: an unauthenticated HTML navigation gets a
**302 to `/login?next=<original>`**, not a bare 401 (API/XHR requests get 401 instead) — a smoke
test asserting a flat 200 on that page will fail whenever `auth_required: true`. Assert the
redirect, then exercise the real flow: `POST` credentials to the JSON auth endpoint, capture the
session cookie, re-request the page with the cookie jar and expect 200. That round-trip is what
actually proves the `auth` option is wired end-to-end — a 200-only check never tested it.

## Client-side proxy configuration (MediaFlow)

This add-on is deliberately the *only* public-facing half of the debrid-proxy pairing — MediaFlow
stays LAN-only, reached only via AIOStreams' own built-in proxy pass-through. Client config:
AIOStreams → Configure → Proxy → service = MediaFlow, then URL / public URL / credentials (the
proxy's own password) / public IP (from the proxy's own IP-echo endpoint) / which debrid services
to route through it. Note: some debrid providers have been observed still reporting inconsistent
egress IPs per source add-on — verify per-provider before promising the multi-IP problem is fully
solved.

## Sizing

Bandwidth is the real constraint, not the proxy: 1080p ≈ 8–12 Mbps/stream, 4K remux ≈ 60–100
Mbps/stream — a single 4K remux can saturate a 100 Mbps upload. The proxy itself stays flat under
load (tens of MB RSS, well under one core) — don't spend hardening effort optimizing it before the
upload link.

## Config templates, variants, and sharing a setup

AIOStreams has its own template/variant/parent-child config feature for sharing a configuration
with other users — distinct from add-on packaging. Authoring/publishing a template, the metadata
schema, and the sharing routes are in `references/config-templates.md` and
`references/aiostreams-template-format.md`.

## Linked Files

- `references/config-templates.md` — authoring and publishing an AIOStreams config template:
  de-personalizing a config export, making it service-agnostic, and the sharing routes.
- `references/aiostreams-template-format.md` — the metadata/input/condition schema tables and JSON
  skeleton in full.
