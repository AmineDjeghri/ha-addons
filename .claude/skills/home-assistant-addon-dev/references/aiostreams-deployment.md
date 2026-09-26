# AIOStreams as an HA add-on (Strimio/Nuvio aggregator) — IMPLEMENTED

The Stremio/Nuvio aggregation layer for this user's debrid setup, shipped as `addons/aiostreams/`
in `ha-addons`. Two decisions were put to him and answered: **channel = nightly**, and
**architecture = AIOStreams' built-in proxy only** (so MediaFlow stays LAN-only and exactly one
service is public). Build it this way; do not re-litigate the choices.

## What the add-on is (and why it exists)

His primary goal: **one debrid account (AllDebrid) usable from many client networks** (home, phone,
family) without multi-IP problems. AIOStreams running on the same HA box makes its egress IP the
host's public IP, and its built-in proxy serves the streams — so the IP mismatch disappears
structurally and only AIOStreams needs the Cloudflare tunnel. Keeping MediaFlow public as well is
the alternative, rejected: it adds the proxy's unauthenticated utility paths to the exposure
surface for no benefit here (see `addon-exposure-security-review.md`).

The mediaflow add-on README now mirrors this: its security section is a short "keep it on the LAN"
note that points here, and the Cloudflare host-entry / service-token / OTP walkthrough it once
carried was removed at his request. Do not re-add exposure hardening to a LAN-only component.

## Upstream facts (verified)

- Official images `ghcr.io/viren070/aiostreams` (+ Docker Hub `viren070/aiostreams`): tags `latest`
  (stable), `nightly` (latest commit — the beta channel he picked), `dev`, plus version tags
  (`v1.x.y`). Platforms **linux/amd64 + linux/arm64** only (no armv7).
- **The runtime image is DISTROLESS:** `FROM gcr.io/distroless/nodejs24-debian12`, with busybox
  `/bin/sh` and `/bin/wget` copied in and NOTHING else — **no bash, no apt/apk, no curl, no jq**.
  Consequences that shape the whole add-on: bashio is impossible (so no `run.sh`), the upstream
  `ENTRYPOINT` must be replaced by ours, and any option plumbing must happen in Node (present at
  `/nodejs/bin/node`). Server entry: `/app/packages/server/dist/server.js`, WORKDIR `/app`.
- Required env (bootstrap, env-only): `BASE_URL` (public HTTPS URL — Stremio refuses non-HTTPS
  non-localhost add-ons) and `SECRET_KEY` (64-hex via `openssl rand -hex 32`). `SECRET_KEY` is
  **immutable after first run** — rotating it makes every stored configuration undecryptable, so it
  lives in the add-on options (covered by HA snapshots) and is never rotated casually.
- Everything else is a dashboard runtime setting with a matching env var; setting the env var locks
  the field read-only in the UI (that is what the add-on does for auth).
- State: SQLite DB + `DISK_CACHE_DIR` (usenet segments, grabbed NZBs, torrent metadata) — both on
  `/data` in the add-on, and the cache grows; tell the user to monitor it.
- Health path is **`/api/v1/status`** (taken from upstream's own HEALTHCHECK script, not guessed);
  the human entry point is `/stremio/configure`.
- Upstream's deployment doc recommends a server/VPS "rather than running this on a personal device"
  → this is the heaviest add-on in the repo (Node + growing cache). Accept consciously; no HA add-on
  existed in the community repos, so we build and own it.

## Implemented design

- `build.json`: `ghcr.io/viren070/aiostreams:nightly` for amd64 + aarch64 — the upstream image IS
  the base, unchanged.
- `Dockerfile`: thin wrapper, `ARG BUILD_FROM` → `FROM ${BUILD_FROM}`, `COPY bootstrap.js /bootstrap.js`,
  `ENTRYPOINT ["/nodejs/bin/node", "/bootstrap.js"]`; keep the base image's HEALTHCHECK; no USER
  directive; no packages.
- `bootstrap.js` (Node builtins only, CommonJS — it lives outside the app's package so `require`
  works): reads `/data/options.json`, fails fast with actionable messages when `base_url` is empty or
  `secret_key` is not exactly 64 hex chars, maps options → `BASE_URL`, `SECRET_KEY`,
  `DATABASE_URI=sqlite:///data/db.sqlite`, `DISK_CACHE_DIR=/data/cache`, `PORT=3000`, `LOG_LEVEL`,
  `AIOSTREAMS_AUTH` (only when set; otherwise log a loud warning that anyone reaching the URL can use
  the instance), `AIOSTREAMS_AUTH_REQUIRED`; `mkdirSync('/data/cache')`; logs one INFO line that
  never prints the secret or the credentials; `spawn`s the server and forwards signals.
- `config.yaml` options (5, mirrored 1:1 in `schema`): `base_url` (schema `url` — required),
  `secret_key` (`password?` + inline detect-secrets pragma, required in practice),
  `auth` (`str?`, comma-separated `user:pass` pairs), `auth_required` (bool, default true),
  `log_level` (enum). Fixed `ports: 3000/tcp: 3000`, `webui` → `/stremio/configure`,
  `watchdog` → `/api/v1/status`, no `map:` (all state under `/data`).
  `TRUSTED_IPS` is deliberately NOT exposed: its default already trusts loopback/link-local/private
  ranges, and the Cloudflared add-on reaches the container from the HA host.
- Version tracking: `version: "nightly-<upstream main sha7>"`; the `bump-aiostreams` job in
  `upstream-bump.yml` reads `commits/main`, seds `config.yaml` only (build.json stays on `:nightly`),
  and regenerates the changelog from the compare API — the same SHA-tracking shape as the octo-fiesta
  `:dev` job.
- CI: its own workflow with the standard two jobs (options↔schema parity + `node --check` on the
  bootstrap + scoped pre-commit; then real `docker build` + a smoke test that mounts an options file,
  waits for `/api/v1/status` 200, and `docker cp`s `/data` out of the container to prove the
  persistence wiring). See `references/addon-ci-build-gate.md`.
- **Auth-gated page assertions (fixed Sep 2026 after a red CI on PR #46):** `/stremio/configure` is
  behind `requireSessionIfAuthRequired` (`packages/server/src/app.ts` line ~166) → `requireSession`
  (`middlewares/auth.ts`), which answers an HTML navigation WITHOUT a session with **302 to
  `/login?next=<original>`** (API/XHR requests get 401 instead) — so a smoke test asserting 200 there
  fails whenever `auth_required: true`. Assert the gate, then exercise it for real:
  `curl -H 'Accept: text/html'` the page and require 302 + a `/login?next=` Location;
  `POST /api/v1/auth/login` with `Content-Type: application/json` and `{"username","password"}`
  (auth router mounted at `/api/v1/auth`, JSON body, NO CSRF token) for 200; re-request the page with
  `-b <cookiejar>` and require 200. The session cookie is set with `secure: req.secure`, i.e. NOT
  Secure over plain-HTTP CI, so the cookie jar round-trip works — and that login step is what proves
  the add-on's `auth` option wiring end-to-end, which a 200-only check never did.

## Client-side config (the MediaFlow half)

AIOStreams → Configure → **Proxy**: service = MediaFlow, then URL / Public URL / Credentials (the
proxy's `api_password`) / **Public IP** (from the proxy's `/proxy/ip`) / **Proxied Services** (select
which debrid service ids get routed). Env equivalents: `DEFAULT_PROXY_*` for defaults, `FORCE_PROXY_*`
to override the user's choice, `ENCRYPT_MEDIAFLOW_URLS` default on. Proxy-side debrid primitive:
`/proxy/forward` + the `{mediaflow_ip}` placeholder.
Caveat to state, not bury: an upstream issue reports AllDebrid still logging varying IPs depending on
which source add-on produced the link (Real-Debrid was consistent) — verify per add-on before
promising the multi-IP problem is solved.

## Sizing: bandwidth is the constraint, the proxy is not

Per stream: 720p ~3–5 Mbps · 1080p ~8–12 Mbps · 4K streaming ~20–30 Mbps · 4K remux ~60–100 Mbps.
Totals: 2 viewers 1080p ≈ 16–24 Mbps · 4 viewers 1080p ≈ 32–48 Mbps · 2 viewers 4K ≈ 40–60 Mbps ·
4 viewers 4K ≈ 80–120 Mbps. A single 4K remux can saturate a 100 Mbps upload.
Proxy cost for that: idle ~18 MB RSS / ~0% CPU; 6 concurrent streams stayed flat at ~16–18 MB and
~25% of one core (upstream benchmark: ~100 concurrent, ≈200 MB, ≤63% of 8 cores).

Every stream relays through the HA host's **upload** — say it plainly, because it is the only real
limit for 2–4 viewers. Debrid accounts additionally cap concurrent streams and now see one shared
identity (the point of the setup, and its cost).
