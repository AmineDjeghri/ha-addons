# Reviewing an add-on before exposing it to the internet

The user exposes add-ons through his Cloudflared add-on (`additional_hosts` → `http://<ha-host>:<port>`),
so every new service add-on eventually faces this review. Do it with evidence, before promising safety.

## Method: probe the auth matrix, don't read the README

An upstream claim like "all endpoints accept an `api_password`" is NOT evidence of enforcement.
Run the real binary/container with a password set and record the status of every path class with
NO credentials:

- proxy/streaming paths, metrics, encoding/utility endpoints
- the web UI, health endpoint, static assets, builder pages
- vendor-specific route families (e.g. Xtream Codes: `/player_api.php`, `/xmltv.php`, `/get.php`,
  short-stream URLs)
- anything that takes a destination URL (fetch primitives)

500/400 with a validation message instead of 401 means the request reached the handler
unauthenticated — validation errors are an auth-model leak, not a rejection.

## Findings to expect (verified against the mediaflow proxy release binary)

- `/proxy/*`, `/metrics`, `/base64/*`, `/extractor/*` → 401 without the password. Good.
- UI + `/health` → 200 by design (harmless, but publicly enumerable).
- **Utility endpoints can be unauthenticated fetch primitives:** `/playlist/builder?url=<any>`
  returned 200 WITH the fetched body and no password. Never tell the user "no password = inert" —
  the proxy family locks, utility/UI paths do not.
- **Media proxies are SSRF by design:** `/proxy/stream?d=http://127.0.0.1:…` succeeded from inside
  the container even though upstream documents a loopback/RFC-1918 guard — that guard covers
  `/proxy/forward` only. Anyone holding the password (or a leaked stream URL) can enumerate/read LAN
  services. Say this plainly rather than describing the proxy as sandboxed.
- **Redirects are followed into private ranges** (`follow_redirects` defaults on): a public URL that
  302s to `http://127.0.0.1/…` is fetched. Surface the option to turn it off.
- **The unauthenticated fetch primitive doubles as a port/host scanner** — response latency
  separates filtered (30 s timeout), up-but-closed (~3 s) and no-route (~0 s) targets, so an exposed
  instance leaks LAN topology to anyone. Use that when arguing it must sit behind the edge rule.
- **CORS reflects any `Origin`** while allowing credentials — a page the user visits can read
  responses from a reachable instance. One more reason to keep the WHOLE hostname (not just
  `/proxy/*`) behind the edge.
- **Vendor routes may use a different credential scheme:** the Xtream Codes proxy authenticates with
  the *provider's* username/password, not the proxy password — a shared player config is usable
  access. Feature caveat: it also needs the upstream provider URL configured in the proxy, so check
  that the add-on actually exposes such an option before advertising the feature.
- **Passwords travel in query strings** → they land in edge/CDN logs, browser history and anything
  the URL is pasted into. Strip query strings from log push; prefer upstream's signed/expiring/
  IP-bound URL generator for clients over embedding the master secret.
- **Check upstream's compile-time feature matrix before documenting options.** Opt-in build features
  are absent from prebuilt release binaries: the shipped binary has no transcoding and no Redis even
  though the image could ship ffmpeg — installing the external dependency does NOT enable them, only
  a from-source build does. Document such features as unavailable instead of exposing dead options.

## Edge exposure checklist (Cloudflare)

- Default-deny the hostname; then split by audience:
  - machine paths → **service-token** rule (`CF-Access-Client-Id`/`CF-Access-Client-Secret`);
  - human UI paths → email-OTP/IdP rule (a browser cannot attach custom headers, so a token is
    useless as UI protection — say why in the docs).
- **Cover every machine path, including utility/UI-adjacent ones** — a `/proxy/*`-only allowlist
  leaves an unauthenticated builder/fetch endpoint open at the edge.
- **One service token per user** where several people share the service: it is the only per-person
  revocation path (a single shared app password cannot revoke one user).
- **Block transparent full-relay endpoints** (`/proxy/forward`-style any-method relays) with a WAF
  rule unless the user needs them; Access can gate but not block.
- WAF rate-limit the hostname; strip query strings from logs; keep the app password long and random
  (signed-URL tokens are derived from it).
- **Gate only the BROWSER-ONLY paths of a header-less service with a path-scoped Access app.** When the
  client cannot answer OTP, do not default-deny the whole hostname — add an Access self-hosted app on the
  same hostname with a narrow path (`/admin*`, `/app/*`, `/stremio/configure*`) and leave the API/stream
  paths to the app's own credential. Verified shapes: Vaultwarden's `/admin` and Navidrome's `/app/` answer
  200 anonymously while the mobile clients only touch `/identity/*` and `/rest/*`; AIOStreams' startup log
  states `/stremio/configure requires login` while Stremio only needs `/stremio/<uuid>/*`.
- **Header-less clients (Stremio/AIOStreams-class) cannot use a service token at all** — they embed
  the app's own credential in requests and never send custom headers. With the Cloudflared ADD-ON
  owning the tunnel there is no local token-injecting forwarder either, so those paths stay on
  tunnel + app credential, and the README should say that plainly. Do NOT tell the user to run
  `cloudflared access tcp …` locally (user correction: exposure docs must match the add-on he
  actually runs). Keep the token rule for clients that genuinely send headers, and state which
  paths are credential-only.
- **Know the plan budget before proposing rules** — Free is **5 WAF custom rules, no regex** and exactly
  **1 rate-limiting rule** (IP-only counting, 10 s window; Pro = 20 rules / 2 rate-limit rules). So rank
  the block list and spend them deliberately: path blocks first (admin panels, registration endpoints,
  docs/config dumps), and the single rate-limit rule on the crown jewel's auth paths (a vault's
  `/identity/*`) — never on a streaming hostname, where a 10 s window throttles legitimate playback.
  Keep 1-2 rules unspent and say so, rather than filling the quota with speculative rules.
- **Answer the "what's local vs what's Cloudflare" split explicitly** — he asks it that way, and the two
  layers do not substitute for each other: LOCAL carries account second factors, closing an app's own
  signups, the router's IPv6 firewall, over-broad `map:`s and an add-on's static privileges; EDGE carries
  path blocking, Access apps and rate limits. An edge rule cannot fix a router hole, and no dashboard
  setting fixes an app that ships `SYS_ADMIN`. Also audit for an **unproxied A/AAAA record pointing at the
  home IP** — it bypasses Access AND the WAF, and it is the record nobody remembers creating.
- **When an agent needs zone access, prefer a zone-scoped API token over the account-wide OAuth login.**
  Cloudflare's MCP accepts a bearer token (their docs: account tokens need `Account Resources: Read` so
  the server can resolve the account id, and tokens with *Client IP Address Filtering* enabled are NOT
  supported). Minimum useful scopes: Account → Settings:Read + Access: Apps & Policies:Edit + Access:
  Organizations/IdPs/Groups:Read; Zone → Zone:Read + DNS:Read + Zone WAF:Edit — restricted to that one
  zone. Keep the value in `~/.hermes/.env` and reference it as `${VAR}` inside the MCP entry, then pair it
  with `trust: untrusted` so every write still asks. First use is READ-ONLY (pull DNS, WAF and Access
  state) and the proposed rule set comes back for approval before anything is created.

## Reactive audit — "can my add-ons / HA be hacked?" (an install that is ALREADY exposed)

The sections above review a service you are about to expose. When the question is about the LIVE
setup, audit what is actually there instead of reading configs, and report worst-first.

1. **Enumerate the surface from live options, never from a doc:** `ha_get_app(slug='<repo>_cloudflared')`
   → `external_hostname` + `additional_hosts` (each `{hostname, service: http://<ha-host>:<port>}`).
   No `catch_all_service` = unlisted hostnames get nothing; prove that with a control hostname you
   know is absent and expect NO answer (a response means a catch-all route exists).
   **Saved options are NOT the running tunnel.** The add-on reads its options once at start, so a hostname
   removed in the UI keeps serving until that add-on restarts — and then disappears *silently*. Detect the
   divergence by probing the hostname AND reading the add-on's own log (`ha_get_logs(source='supervisor',
   slug='<repo>_cloudflared')` → lines like `dest=https://<host>/<path> ingressRule=<n>
   originService=http://homeassistant.local:<port>`): a hostname in the log but not in the saved options means
   a removal is PENDING, and you must say so explicitly (he may think the service is already offline).
   **Uninstalling the ORIGIN does not unpublish the hostname either:** the CNAME survives, so DNS still
   resolves to Cloudflare IPs while nothing answers — signature: the hostname resolves to edge IPs and then
   hangs with **0 bytes received** (`curl` code `000`, no headers) where a live sibling returns a status
   code. Never read a `000` as "not exposed": it means the record is orphaned at the edge, and the service
   comes back when the add-on is reinstalled (or the tunnel entry restored + the Cloudflared add-on
   restarted so it rewrites the record). Confirm the resolution with `getent hosts <hostname>` before
   blaming DNS.
2. **Probe every hostname with ZERO credentials and no redirect-following** (`curl -sD - -o /dev/null`).
   The reply carries `server: cloudflare` + `cf-ray: <hash>-<edge>` → it came from the Cloudflare
   edge, so a probe launched from the LAN still measures what an anonymous internet client sees.
   `302 → <team>.cloudflareaccess.com/cdn-cgi/access/login` = Access applies (interactive policy); a
   plain **`403` from the edge** (`cf-ray` present, no origin headers) = Access applies too, as a
   **service-token-ONLY app**: it has no interactive policy, so it never redirects a browser to a login
   page and the web UI is blocked by design — add an email-allow policy alongside it if the browser UI
   must open (Access allows when ANY policy matches). `200`, or a `302` to an
   app path (`/app/`, `/admin`), = the app's own login is the only gate. State the caveat: the source
   IP was the home WAN, so an IP-scoped policy would look different — and the policy itself needs a
   Cloudflare API token he probably does not have on the box.
3. **Read the blast radius of every reachable add-on** from the same `ha_get_app(slug=…)`: `host_network`,
   `privileged`, `udev`, `devices`, `map`, `homeassistant_api`/`hassio_api`/`docker_api`. Two grants turn
   a popped public service into a whole-host compromise:
   - `privileged: [SYS_ADMIN, DAC_READ_SEARCH]` with host block devices in `devices` (`/dev/sda*`,
     `/dev/nvme*`, `/dev/fuse`): SYS_ADMIN alone is enough to mount the HAOS data partition and read
     HA's `/config`, its `.storage`, and every add-on's config. Third-party add-ons that support
     mounting local disks carry this BY DEFAULT — read the live grants, the README never mentions it.
   - `map: config:rw` = HA's own config dir (`secrets.yaml`, `.storage/auth` refresh tokens);
     `all_addon_configs:rw` = every add-on's options (tunnel config, app secrets).
   Say "reported grants, not an exploit": exposure alone still needs an RCE in the app first — but it
   moves the payoff from "my music" to "my smart home", which is what changes the recommendation.
4. **HA-side auth** (tool shapes in `hermes-ha-integration`): WS `config/auth/list` → per-user
   `credentials`; service accounts should be `local_only: true`. ⚠ **This list does NOT report MFA** —
   a user whose only entry is `{"type": "homeassistant"}` can still have the authenticator app (TOTP)
   enabled and be prompted for a code at login (verified live: the real login screen demanded a 2FA code
   while the API listed a single credential). Never conclude "no 2FA" from it; confirm from an actual
   login prompt or the user's own Profile → Security. `GET /auth/providers` unauthenticated → enabled
   providers (a `trusted_networks`
   entry = LAN devices skip the login form). Zero matches for `ha_config_get_yaml(yaml_path='http')` = no
   `http:` block = no `ip_ban` and no `trusted_proxies` (so never add `ip_ban` without `trusted_proxies`
   — it would ban the tunnel and lock him out).
5. **Direct-path bypass — Access protects the HOSTNAME, not the machine.** HA's HTTP server also listens
   on IPv6 and ISP routers can be permissive by default (Freebox ships its IPv6 firewall OFF), so
   `http://[<ha-global-ipv6>]:8123` may reach HA with no Cloudflare in the path. What you CAN collect
   from the container: HA answers over IPv6 (`curl -6 http://homeassistant.local:8123`), and
   `system_log/list` may show it logging requests from public IPv6 peers. What you CANNOT: prove
   internet reachability — the container has no global IPv6, and a NAT-hairpin curl to the WAN IP
   answering nothing is INCONCLUSIVE, not a pass. Hand over a 30-second user check instead (phone on
   mobile data, Wi-Fi off, open the IPv6 URL; or the router's IPv6 firewall mode). A third-party
   vantage point helps for the IPv4/hostname case and is quick: `check-host.net/check-tcp?host=<host>:<port>`
   with `Accept: application/json`, then poll `/check-result/<request_id>` — several countries, real
   TCP connect. It REJECTS raw IPv6 literals (`invalid_url`), so an IPv6 path still needs the phone test.
   A router-side IPv6 firewall that is already ON is what makes ALL nodes time out — read the mode, not the
   outcome alone, before reporting a pass.
6. **The LAN is not a trust boundary:** list host-published ports (`ha_get_app` → `network: {"<host_port>/tcp":
   <port>}`). Any RCE in one exposed container can reach HA on 8123, every published port, the router,
   and any LAN MCP endpoint whose secret URL sits in plaintext in the agent's config.
   The follow-up question ("so if one add-on is hacked, does it own everything?") has a fixed answer shape —
   give it in this order: (a) FILES are isolated: a container reads only what its own `map:` grants, so
   cross-add-on access is not a given — the escalation runs through the wide grants above
   (`all_addon_configs:rw` = every add-on's config, `config:rw` = HA's `/config` with `secrets.yaml` and
   `.storage/auth`); (b) NETWORK is not isolated: the popped container inherits a LAN position and can talk
   to every published port, HA, the router and any LAN MCP endpoint; (c) the AGENT is a target, not a
   gateway — unreachable from outside (no tunnel hostname, dashboard/terminal/API off) but it holds a
   long-lived HA admin token in a plaintext file in its home, so anything that can read that home (or mount
   the host disk) inherits HA control; (d) the ONE true hop to host root is the `privileged` + host-block-device
   grant, which is why that single add-on's exposure is the finding — never "you have N add-ons so you have N risks".
7. **Verdict shape (matches his evidence discipline):** answer each question in ONE line first, then the
   live surface, then findings worst-first — each with the probe that produced it, then a short explicit
   "what I could NOT verify" with the check he can run himself, then fixes ranked value-per-effort. State
   plainly that every probe was unauthenticated and read-only, and never imply an intrusion happened
   because a port answers. Where the fix is out of your hands upstream (a third-party add-on that ships
   SYS_ADMIN), recommend the alternative he owns — **but only when he can accept losing remote access**.
   For a service he genuinely uses from outside the LAN, "publish your own non-privileged add-on" is NOT
   an answer he will take (his words on Navidrome: "I don't want to code another Navidrome") — rank the
   no-code options instead: the client's own capability decides (a Subsonic/Bitwarden-class mobile app
   cannot do an interactive login, so it needs a token it can attach as a header, a tailnet/VPN path, or
   the status quo), **promote a capability-light sibling that is ALREADY installed and fronts it** (verified
   shape: expose Octo-Fiesta — `privileged: []`, `devices: []`, and `app.UseSubsonicAuthentication()` runs
   before any endpoint, so unauthenticated callers cannot use its provider downloader — and keep the
   privileged app LAN-only, changing only the client URL; the client must be on the sibling's supported list,
   and the sibling's own upstream channel, e.g. a `:dev`-tracked add-on, is a trade-off to state), or say the
   residual risk plainly (keep it public, keep it
   auto-updating, keep the app's own credential strong) rather than proposing a fork.
   **Two no-code options that KEEP remote access (the ones he accepts):** (a) **move the service off the
   HAOS box** — the Cloudflared add-on reaches LAN addresses, so an `additional_hosts` entry pointing at
   `http://192.168.<lan-ip>:<port>` serves an app running on his Ubuntu server and the privileged add-on
   then never faces the internet at all (verified: a bridged add-on container reaches `192.168.x.x` hosts,
   so the tunnel container can too); (b) **tailnet** — keep it LAN-only and reach it over Tailscale
   (`hassio-addons/app-tailscale`, community add-on) and drop the tunnel entry. The client's own capability
   then decides whether a CF Access **service token** is even possible: mobile Subsonic clients that send
   custom headers = Symfonium, Amperfy (recent), Nautiline, **Narjo** (the user's own client — he states it sends
   `CF-Access-Client-Id`/`CF-Access-Client-Secret`, and the token route then goes live: verified by an anonymous
   `403` from the edge. A first-hand claim about the app he runs daily outranks a vendor-doc-derived list — ask
   which client he actually uses before writing the token route off. When creating the client's source entry, set
   the public hostname AND the headers together: retro-fitting headers onto an existing entry has silently failed
   for other Subsonic clients); those that do NOT = Substreamer,
   Feishin (researched from vendor docs/issues, not verified on his devices — say so before he reconfigures
   a client).

Pitfalls:
- `ha_config_get_yaml` takes `yaml_path` (not `key`). A key that is ABSENT returns 0 matches — that empty
  result is the finding (no custom `http:` block), not a tool failure.
- One `ha_get_app(slug=…)` call returns ~10-30 KB of translations: characterise only the add-ons you must,
  and read the add-ons you own straight from the repo's `addons/*/config.yaml`.
- The audit is READ-ONLY: nothing is written, no credential is tried, and any fix waits for his explicit
  confirmation.
- **A probe that trips the terminal security scan is not retried** (private-network/localhost or plain-HTTP
  URLs inside a command trigger it — read-only or not). Establish the behaviour from the app's upstream
  source instead (middleware order in `Program.cs`/`main.py`, route files, compose defaults) and LABEL the
  finding source-derived, so he can tell it apart from a live probe.
- **Fixes that need his accounts are his to run, and a decision form returning only SOME answers is not
  partial consent.** Act on the answered branch, hold every unanswered one, and re-offer it explicitly in the
  next reply (the dashboard may reject `admin*`-style path wildcards — say which syntax to try).

## Verified anonymous surface per service (this stack — the block-list source)

Probe each service with ZERO credentials and record the status. That table IS the per-add-on block list he
asks for; verified live on this install:

| service | answers with no credentials | the real gate | edge action |
|---|---|---|---|
| AIOStreams `:3000` | `/api/v1/status` (large settings/flags payload; secret fields masked), login page | `settings.protected: true`; `/api/v1/user` → 400 `Authorization header (Basic) is required` | keep public (header-less clients); WAF-block `/api/v1/status` — only the HA watchdog reads it, over the LAN |
| Navidrome `:4533` | `/app/` login UI; `/rest/*` → `status="failed"`; `/metrics` → 302 `/app/` | app login (Subsonic creds) | nothing to block; rate-limit the login paths |
| Vaultwarden `:7277` | `/admin` (admin login page), `/api/config` (reports `disableUserRegistration` = the signup state) | vault master password + 2FA | block `/admin`; block the registration endpoints while signups are open |
| Hermes WebUI `:8787` | nothing (`/api/*` 401) | Access OTP + app password | keep Access on the whole hostname |
| mediaflow `:8888` (LAN-only) | `/health`, UI root, **`/playlist/builder?url=` — unauthenticated fetch primitive** | password covers `/proxy/*` and `/metrics` (both 401) | never publish; the whole hostname is the perimeter |
| octo-fiesta `:5274` (LAN-only) | **`/swagger`, `/docs`, `/health` ALL serve the .NET Swagger UI**; `/` → `{"status":"ok"}` | `/rest/*` 401 (Subsonic creds) | never publish; if ever exposed, WAF-block `/swagger` + `/docs` |
| personal-app `:8080` (LAN-only) | SPA shell only — `/docs`, `/openapi.json`, `/api/*` fall through to the SPA 404 | — | never publish |

What the table teaches, beyond the individual rows:

- **An app's credential gates only the paths it actually wraps.** Admin, monitor, docs and utility routes
  routinely sit outside it — `/playlist/builder` ignores the proxy password, `/admin` and `/swagger` need
  none at all. "Password is set" is never the same claim as "the service is gated".
- **API-docs endpoints are published by DEFAULT** (ASP.NET `/swagger`, FastAPI `/docs`+`/openapi.json`):
  a read-only surface leak that enumerates every route for an attacker. Report it as a block-the-path
  finding, not as "this service is unsafe". FastAPI apps that mount an SPA last are immune (the catch-all
  answers 404 for `/docs`) — probe, don't assume either way.
- **The app's own request log is the block-list source AND names the real clients.** Vaultwarden logs every
  request with its status; Navidrome logs the client and account (`player="Narjo [Narjo]" user=<name>`,
  `Streaming file`, `remoteAddr=`). `ha_get_logs(source='supervisor', slug=<slug>)` therefore shows which
  paths the real clients hit — keep exactly those, block the browser/admin surface — and it proves whether a
  service is genuinely used before you propose removing it.
- **Publish the list where he reads it:** a short `Security notice` / blocked-URLs section in the ADD-ON
  README (`addons/<slug>/README.md`) AND a one-line notice on that add-on's entry in
  `personal-os-setup/docs/home-server/readme.md` → `### Apps / Add-ons` (add any add-on missing from that
  list in the same pass — his expectation is that the exposure notice lives with the add-on inventory,
  not only in the repo README).

## Publishing a new service through the existing tunnel (operational sequence)

**Verify the tunnel MODE first — `ha_get_app` on the Cloudflared add-on** (`slug` `<repo>_cloudflared`):
if `tunnel_token` is set the tunnel is REMOTELY managed and "all other options will be ignored" (its
own docs) — public hostnames and ingress are configured in the Cloudflare Zero Trust dashboard, so the
sequence below does NOT apply; say that instead of editing `additional_hosts`. Only with `tunnel_token`
absent is the tunnel local. **Read the LIVE options, not the documented intent:** the same call returns
`external_hostname`/`additional_hosts` — the complete public surface — and it is normal for the live list
to still route a service the docs describe as LAN-only. Surface that discrepancy rather than assuming
the plan shipped; dropping the entry is the user's call (and the DNS record survives the removal).

His Cloudflared add-on runs a **local tunnel** (no `tunnel_token` set): `external_hostname` (HA
itself) plus `additional_hosts` ARE the entire public surface, and the add-on **creates the proxied
DNS records itself** — never send him to the Cloudflare dashboard to pre-create a CNAME, and never
tell him to run `cloudflared` by hand.

1. Add/edit the host entry in the Cloudflared add-on options, then **restart that add-on** — it reads
   its config once at start, and on start it overwrites any existing DNS entries matching
   `external_hostname`/`additional_hosts`:
   `additional_hosts: [{hostname: <service>.<domain>, service: http://homeassistant.local:<port>}]`
   (`<port>` = the add-on's published port, i.e. `config.yaml`'s `ports:` host side).
2. Prove routing BEFORE the service exists: open the URL and expect Cloudflare **502**. That is the
   correct intermediate state — DNS + tunnel ingress verified, only the service missing. A 502 here
   is a pass, not a failure.
3. Only then set the app's own public-URL option (`base_url`-style) to exactly that `https://`
   hostname, no trailing slash, and start it. **Order matters and the value is sticky:** any app that
   bakes its public URL into what it hands clients (manifest/stream/webhook URLs) binds that hostname
   permanently — changing it later means re-installing the client config everywhere, so pick it once.
4. Removing a host from `additional_hosts` stops serving it but **does NOT delete the DNS record** —
   the add-on can create DNS entries, not remove them; the leftover CNAME must be deleted manually in
   the Cloudflare dashboard. State that whenever advising a hostname be dropped.
5. Keep Cloudflare Access OFF for header-less client paths (checklist above): at the tunnel edge the
   app's own credential is the gate — that is the design, not a gap.

Per-hostname troubleshooting knob: `disableChunkedEncoding: true` on the entry when a
streaming/SSE service stalls behind the tunnel.

## Add-on hardening that should already be true

No `map:` unless needed (never `homeassistant_config:rw` casually — it exposes `secrets.yaml`),
no `homeassistant_api`/`hassio_api`/`docker_api`, no `privileged`/`host_network`, stateless
(no secrets written to disk), no secret echoed to logs, CI least-privilege
(`contents: read`, no `pull_request_target`, no secrets available to PR workflows).

## What the audit must NOT end up in a repo (publication discipline)

The audit's *method* stays here; the *findings about his deployment* go to him in the answer.
Three corrections he made after seeing an audit published in the repos:

- **Never commit the hostname map — not even as `service.<domain>` placeholders.** The docs-site
domain is already public (CNAME, badges, `contact@` in SECURITY.md), so a table pairing each
service with its tunnel hostname hands over the tunnel layout. Describe the service and its gate
generically ("its own tunnel hostname", "whatever the Cloudflared add-on is configured with") and point the reader at `external_hostname`/`additional_hosts` instead of repeating them.
- **Live findings stay out of the docs.** A concrete weakness in his own network (an IPv6 direct
path, his instance's signup state) is chat, not a doc section; the repo docs carry only the
operational hygiene (what to block, which option to set, how to verify it).
- **Sanitizing means the metadata too.** Such content lands in more than the diff: fix the files,
then `git commit --amend` + `git push --force` (his explicit request overrides the standing
no-force-push preference) **and** repair the PR with `gh pr edit <n> --title … --body-file …`.
Editing only the diff leaves the domain named in the commit subject, the PR title and the PR body.

Where the sanitized block list does get published: a short `Exposure & blocked URLs` section in the
ADD-ON README (`addons/<slug>/README.md`) and one row per add-on in
`personal-os-setup/docs/home-server/readme.md` → `### Apps / Add-ons` (generic phrasing only).

## Hardening fixes verified on this stack

- **Close public signups on the community Vaultwarden add-on** — its schema has no `env_vars` and no
  signups option, so nothing in the add-on Configuration can do it: `/admin` → General → uncheck
  **Allow new signups** → Save. That Save is hot-applied and writes the whole editable config to
  `/data/config.json`, which outranks every env var; the add-on auto-generates the admin token and
  logs it on start **only while `/data/config.json` does not exist** (restart = the recovery path when
  the token was never saved; once the file exists, a missing token needs `docker exec` on the add-on
  container from the SSH add-on). Clear the signup-domains whitelist too — a non-empty whitelist
  overrides the signups setting. Verify: `GET /api/config` → `settings.disableUserRegistration: true`.
  The edge WAF fallback (`POST /identity/accounts/register*`) also blocks legitimately *invited* users,
  which the server-side fix does not — prefer the panel.
- **HA MFA is a user action, and the docs' "activate MFA" line is aspirational until it happens:**
  `config/auth/list` showing only a `homeassistant` credential means TOTP is NOT enabled — check the
  live registry before describing his HA as 2FA-protected. **When he pushes back ("are you sure? I see
  that I have it"), re-run the check LIVE before defending the claim** — sessions are days apart and he
  may have enabled it in between, so the evidence must be from this minute: print the raw per-user line
  (`credential_types=[…] MFA_present=…`) rather than re-asserting the earlier reading. Then name the
  three things he is almost certainly looking at, because only one of them is HA MFA: the **Cloudflare
  Access email-OTP screen** on the tunnel hostname (the usual confusion — that is the edge gate, not
  HA), the Profile → Security tab *listing* the TOTP module (available ≠ enabled; a **Disable** button
  appears only once it is really on), and the phone app's biometric app-lock (device-local, not MFA).
  Hand him a 30-second self-check that bypasses the edge — incognito at the LAN URL
  (`http://homeassistant.local:8123`): if nothing asks for a code, HA has no MFA — and ask for the exact
  on-screen label instead of arguing, since he cannot send you a readable screenshot.
- **`/api/error_log` returns 404 on current HA.** Read logs through MCP instead:
  `ha_get_logs(source='error_log', search=<keyword>)` for HA's log, and
  `ha_get_logs(source='supervisor', slug=<addon>)` for one add-on's log (also the way to tell whether a
  service is genuinely used before proposing its removal).
- **Before dropping OR keeping a `map:`, find the app's REAL consumer of that path** — read the upstream
  compose/env defaults first, then check the add-on's own schema can even reach it. Verified: octo-fiesta's
  `config:rw` (= HA's `/config`: `secrets.yaml`, `.storage/auth`) exists only for the Tidal OAuth token store
  (`Tidal__TokenStore`, compose comment "only needed when MUSIC_SERVICE=Tidal"), while the add-on's
  `music_service` enum has no Tidal value and `run.sh` exports no Tidal var → pure liability, drop it; if Tidal
  is ever added, point `Tidal__TokenStore` at `/data/...` instead of restoring the mount. `map:` is applied at
  container CREATION, so the drop lands on the next reinstall — `docker cp` `/data` out and back around it.
- **A third-party add-on's `privileged`/`devices` are static in its `config.yaml` — no runtime option removes
  them.** Read that repo's `config.yaml` (not its README) to say this with certainty: alexbelgium's Navidrome
  declares `privileged: [SYS_ADMIN, DAC_READ_SEARCH]` + `udev: true` + the full `/dev/sd*`/`/dev/nvme*` list to
  support its disk-mount feature, so the levers are exposure, a tailnet/VPN, or accepting the grant — never an
  option flip.
