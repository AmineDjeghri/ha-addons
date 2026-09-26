# Reviewing an add-on before exposing it to the internet

## Method: probe the auth matrix, don't read the README

An upstream claim like "all endpoints require a password" is not evidence of enforcement. Run the
real binary/container with a password set and record the status of every path class with **no**
credentials supplied:

- proxy/streaming paths, metrics, encoding/utility endpoints
- the web UI, health endpoint, static assets, builder pages
- vendor-specific route families (a third-party auth scheme may live entirely outside the app's
  own credential)
- anything that accepts a destination URL as a parameter (fetch primitives)

A 400/500 with a validation message instead of 401 means the request reached the handler
unauthenticated — a validation error is an auth-model leak, not a rejection.

## Findings classes to expect

- **Utility endpoints can be unauthenticated fetch primitives** even when the "real" API is
  locked — never conclude "no password = inert" from one gated family.
- **Media/relay proxies can be SSRF by design** — a documented private-IP guard often covers only
  one route, not every proxy path; redirects are frequently followed into private ranges by
  default (`follow_redirects`-style options). State this plainly rather than describing a proxy as
  sandboxed.
- **An unauthenticated fetch primitive doubles as a port/host scanner** — response latency alone
  (timeout vs fast-refused vs fast-no-route) leaks internal network topology to anyone who can
  reach the endpoint.
- **CORS reflecting any `Origin` while allowing credentials** means a page the user visits can read
  responses from a reachable instance — reason enough to keep the whole hostname behind an edge
  gate, not just the sensitive routes.
- **Credentials in query strings** land in edge/CDN logs and browser history — prefer signed,
  expiring, or IP-bound URLs where upstream offers them, and strip query strings from any
  centralized log pipeline.
- **Check the compile-time feature matrix, not the Dockerfile's installed packages.** Opt-in build
  features (transcoding, an external cache backend) are often absent from prebuilt release
  binaries even when the image ships the runtime dependency — installing it does not enable a
  feature that needed a from-source build.

## Edge exposure checklist (reverse-proxy / tunnel front-ends generally)

- Default-deny the hostname, then split by audience: machine paths get a token/header-based rule;
  human UI paths get an interactive login rule (a browser can't attach custom headers, so a
  bearer-token-only rule is not UI protection).
- Cover **every** machine path, including utility/UI-adjacent ones — an allowlist scoped to only
  the "main" API family leaves an unauthenticated builder/fetch endpoint open at the edge.
- One credential per person where several people share a service — a single shared app password
  cannot revoke one user without breaking everyone.
- Block transparent full-relay/forward endpoints with a WAF-style rule unless genuinely needed —
  an allow-based access layer can gate a route but not block it outright.
- For a header-less client (can't send custom auth headers, can't do interactive login): scope
  hardening to the browser-only paths and leave API/stream paths on the app's own credential —
  don't default-deny a hostname a header-less client depends on.
- Know the platform's free-tier rule/rate-limit budget before proposing a list of rules; rank by
  value and leave headroom rather than filling the quota speculatively.
- A rate limit belongs on auth/admin paths, not on a streaming hostname where it throttles
  legitimate use.
- Local hardening and edge hardening are not substitutes for each other: an edge rule can't fix an
  overly-broad `map:` or a container running with excess Linux capabilities, and no dashboard
  setting fixes a router-level hole. Check both layers explicitly.

## Add-on hardening baseline (should already be true before shipping)

- No `map:` beyond what's needed (never `homeassistant_config:rw` casually — it exposes
  `secrets.yaml`).
- No `homeassistant_api` / `hassio_api` / `docker_api` unless the add-on genuinely calls those
  APIs.
- No `privileged` capabilities, no `host_network`.
- Stateless where possible; no secret ever echoed to logs.
- CI least-privilege: `contents: read`, no `pull_request_target`, no secrets available to
  PR-triggered workflows.

## What NOT to put in a public repo

The *method* above is reusable and belongs in the repo. Specific findings about a live deployment
— which hostnames are exposed, which services sit behind which gate, sizing/RAM numbers for a real
install — are answers for the person who asked, not committed docs. If an add-on genuinely needs a
security section in its own README, keep it to the generic finding ("gates `/proxy/*`; the rest of
the hostname is the real perimeter") and put the measured detail nowhere that becomes a map of a
real deployment.
