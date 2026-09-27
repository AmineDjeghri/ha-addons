# Upstream version-tracking patterns

Which pattern an add-on uses is a repo-level decision recorded in the root `AGENTS.md` (do not
re-decide it here). This reference is the *mechanics* for each pattern once chosen.

## 1. Image-pinned (upstream ships a usable Docker image)

- `build.json` `build_from` pins the upstream image per arch: `ghcr.io/<owner>/<repo>:vX.Y`.
- `config.yaml` `version:` is the string HA compares for update availability — keep it in sync
  with the pinned tag.
- `upstream-bump.yml` (cron) fetches the upstream latest release tag, sed-replaces both files,
  commits + pushes directly to `main`.
- **Trap — the nightly revert:** if you retarget `build.json` to a floating tag (e.g. `:dev`)
  without also reworking the bump job, the next cron run sees a mismatch against the release-tag
  scheme and reverts you within a day. Any move off the release-tag pattern must change the
  workflow, not just the pin.
- **Trap — version stagnation:** HA only shows "Update available" when `config.yaml version`
  *changes*. A floating tag whose version string never changes yields exactly one update, then
  silence, even though the image keeps moving upstream.

### Tracking a floating tag (`:dev`, `:nightly`) by commit SHA

Pin the floating tag permanently in `build.json`; derive `config.yaml version` from the upstream
branch's HEAD commit SHA instead of a release tag:

1. `build.json` → `ghcr.io/<owner>/<repo>:dev` (or `:nightly`), permanent, all arches.
2. Bump job: fetch `api.github.com/repos/<owner>/<repo>/commits/<branch>` → `.sha`; set
   `config.yaml version` to `<tag>-<sha7>`; commit+push only when it differs.
3. Every upstream push to that branch → new SHA → new version string → HA offers an update →
   supervisor rebuilds from the fresh floating-tag image.

Check what upstream actually publishes before committing to this (arch list per tag can differ
from the release-tag builds; some floating tags omit a platform present in tagged releases).

## 2. PyPI-tracked (upstream is a Python package, no Docker image)

- `config.yaml version:` mirrors the upstream package version.
- Dockerfile pins the same version as a single `ENV <APP>_VERSION=X.Y.Z` — the one source of
  truth the bump job edits.
- Bump job: `curl pypi.org/pypi/<pkg>/json` → `.info.version`, compare against `config.yaml`,
  sed both files, regenerate `CHANGELOG.md` from the GitHub release body, commit `chore: bump
  <pkg> OLD → NEW` (a `chore:` commit doesn't trip a path-gated semantic-release job).
- Add-on-only code fixes (no upstream bump) ship via **manual reinstall**, never a version-suffix
  hack — a suffix (`2.13.1.1`) makes HA offer an update the next bump job would then fight, and the
  repo's standing rule is to keep `version:` an exact mirror of upstream. Uninstalling deletes the
  add-on's `/data` — preserve it with `docker cp <container>:/data/<dir> /tmp/backup` before
  uninstall, restore after reinstall while the add-on is stopped.

### From-scratch Dockerfile shape (Alpine, `uv tool install`)

```dockerfile
RUN apk add --no-cache --virtual .build build-base \
    && uv tool install --python 3.14 \
           --default-index https://pypi.org/simple \
           --index-strategy unsafe-best-match \
           "<pkg>[extras]==${APP_VERSION}" \
    && apk del .build \
    && ln -s /root/.local/bin/<pkg-bin> /usr/local/bin/<pkg-bin>
```

**The index flags are required, not optional.** HA's builder injects
`https://wheels.home-assistant.io/musllinux-index/` as the *only* pip index via `/etc/pip.conf`
baked into the base image — it mirrors old wheel versions, so a fresh dependency needing a newer
release fails to resolve. An extra PyPI index does not help (uv's dependency-confusion guard is
first-index-wins). Env-var overrides (`UV_DEFAULT_INDEX=...`) also fail — uv honors the base
image's `pip.conf` over env vars. Only CLI flags (highest precedence) work.

## 3. Release-binary-tracked (upstream image unusable as a base)

Decide the upstream image is unusable before reaching for this pattern:
- **Distroless runtime** (`FROM gcr.io/distroless/*` — no shell, no apt/apk): can't run a bashio
  `run.sh`, and its own `ENTRYPOINT` can't be overridden by the supervisor. Read the Dockerfile's
  runtime `FROM` stage, not the GHCR tag list — tags existing proves nothing about usability.
- **glibc-dynamic binary on a musl base**: check the release asset with `file`/`ldd` — HA's
  default `-base` images are Alpine/musl and won't exec a glibc binary. Pin the Debian variant
  (`ghcr.io/home-assistant/<arch>-base-debian:latest`) instead.

Shape:
- `config.yaml version:` mirrors the upstream release tag (strip any `v` prefix — asset URLs
  usually match the raw tag).
- Dockerfile: `ARG <APP>_VERSION=<current>` + arch→asset mapping keyed on the builder-injected
  `ARG BUILD_ARCH`, then `curl -fSL -o /usr/local/bin/<bin> ".../releases/download/${VERSION}/<bin>-linux-${ARCH}"`.
  Pin the version in the URL — never float on `latest`.
- Don't `COPY` an upstream example config with placeholder secrets — pass everything through env
  vars instead; diff the app's own env-var naming against its example config to find the real
  option surface.
- Bump job: same shape as PyPI-tracked, fetching `releases/latest` instead of the PyPI JSON API.

## 4. Distroless image kept as base + a language-native bootstrap

When the upstream image is distroless but *does* ship its own runtime (Node/Python), keep it as
`build_from` and replace `run.sh` with a small bootstrap in that language instead of switching
base images:

- No bashio, no Supervisor API — the bootstrap reads `/data/options.json` directly (same values
  bashio would have re-queried), validates required options, sets env vars, then `spawn`s the
  upstream server with `stdio: inherit`, forwarding SIGTERM/SIGINT (the bootstrap is PID 1 —
  without signal forwarding, restarts wait out the supervisor's kill timeout).
- Read the upstream image's own `HEALTHCHECK` for the real health path to put in `config.yaml`
  `watchdog:` — don't guess `/health`.
- No shell means no `docker exec` debugging — `docker logs` + `docker cp` are the tools; the CI
  smoke test mounts `/data/options.json` directly rather than needing a fake Supervisor.

## Verifying a config surface stays in sync with upstream

Tracking the image/package version is only half the job — after a bump (especially onto a
faster-moving channel like `:dev`), the add-on's own option surface can drift from what the binary
actually reads.

1. Read upstream's own env-var reference (`.env.example`, or the settings/config model source
   files) as ground truth — new files there mean new features the add-on doesn't expose yet.
2. Diff that against `config.yaml` options + schema and `run.sh`'s env mapping: options present
   upstream but missing here (🔴 missing feature), schema enums narrower than upstream's (🟡
   incomplete), and add-on options with zero upstream references left over from removed features
   (🟠 stale — remove option, schema, and env mapping together).
3. Verify options ↔ schema stay 1:1 before committing — the Supervisor UI cannot save a config
   whose schema is missing a key.

## Probing GHCR without a `read:packages` token

Public images work via anonymous token exchange:

```bash
TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:<owner>/<repo>:pull&service=ghcr.io" | jq -r '.token')
curl -s -H "Authorization: Bearer $TOKEN" "https://ghcr.io/v2/<owner>/<repo>/tags/list" | jq -r '.tags[]'
curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.oci.image.index.v1+json" \
  "https://ghcr.io/v2/<owner>/<repo>/manifests/<tag>" | jq -r '.manifests[]?.platform | .os + "/" + .architecture'
```

A `404` means the tag doesn't exist; `200` with `unknown/unknown` entries are attestation blobs —
ignore them.

## Supervisor mechanics worth knowing

- Update detection is plain string inequality (`self.version != self.latest_version`), not
  semver — any differing string (`dev-abc1234`) triggers the Update button.
- Version validation is lenient (`AwesomeVersion()` with no format constraint).
- A `CHANGELOG.md` in the add-on folder auto-enables its Changelog tab; the frontend parses
  `## <version>` headings, so keep the heading in sync with `config.yaml version` and keep the
  file to a rolling window of recent entries (old sections are dead weight once parsed).
