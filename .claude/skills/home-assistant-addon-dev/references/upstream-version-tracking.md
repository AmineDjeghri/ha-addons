# Upstream Version Tracking for Image-Based Addons (octo-fiesta)

How the `octo-fiesta` addon in `ha-addons` tracks upstream `V1ck3s/octo-fiesta`, and how to retarget it from stable releases to a floating tag (`:dev`). Verified live 2026-08-17 against GHCR and the repo clone at `workspace/ha-addons`.

## The 3-file update chain

| File | Role |
|---|---|
| `addons/octo-fiesta/build.json` | Pins the base image: `"build_from": { "amd64": "ghcr.io/v1ck3s/octo-fiesta:v0.10", ... }` (one entry per arch) |
| `addons/octo-fiesta/config.yaml` | `version: "v0.10"` — **this string is what HA compares for update availability** |
| `.github/workflows/upstream-bump.yml` | Daily 06:00 UTC cron: fetch upstream latest release tag → compare with pinned tag → sed-replace BOTH files → commit+push to main |

The Dockerfile is a thin wrapper (`ARG BUILD_FROM` / `FROM ${BUILD_FROM}` + bashio install + `run.sh`), so the addon's actual content IS the upstream image. `build.json` is the only thing selecting which upstream build you get.

## The `upstream-bump.yml` mechanics (octo-fiesta job)

1. `curl -sL ... api.github.com/repos/V1ck3s/octo-fiesta/releases/latest | jq -r '.tag_name'` → e.g. `v0.10`
2. `CURRENT=$(grep -oP 'octo-fiesta:\K[^"]+' addons/octo-fiesta/build.json | head -1)` → `v0.10`
3. If different: `sed -i "s|octo-fiesta:${OLD}|octo-fiesta:${NEW}|g"` on `build.json`, same on `config.yaml` `version: "${OLD}"`, then bot commit + push to main.

It pushes **directly to main** (no PR). There is a second job `bump-hermes-webui` in the same file with the same pattern (but it strips the `v` prefix because nesquena GHCR tags are no-v).

## Trap 1 — the nightly revert ⚠️

If you ONLY edit `build.json` to `ghcr.io/v1ck3s/octo-fiesta:dev` and leave `upstream-bump.yml` untouched, the next daily run fetches latest release (`v0.10`), compares to pinned (`dev`), sees a mismatch, and sed-replaces `octo-fiesta:dev` → `octo-fiesta:v0.10`. The change is reverted in < 24h. **Any retarget away from the release-tag scheme must change the workflow too** (or disable the job).

## Trap 2 — version stagnation with floating tags

HA only shows "Update available" when `config.yaml version` **changes**. A floating tag (`dev` is overwritten on every upstream push) with a static version string = exactly one update, then silence even though the image keeps moving. To auto-follow a floating tag you must derive the version from something that changes per build.

## The recommended pattern: pin `:dev` + track dev-branch SHA as version

1. `build.json` → `ghcr.io/v1ck3s/octo-fiesta:dev` for all archs (drop `armv7` — see below)
2. `config.yaml` → `version: "v0.10-dev"` initially, workflow-managed after
3. Rework ONLY the `bump-octo-fiesta` job:
   - Replace `releases/latest` fetch with `api.github.com/repos/V1ck3s/octo-fiesta/commits/dev` → `.sha`
   - Keep `build.json` on `:dev` permanently (no tag sed)
   - Set `config.yaml version` to `dev-<sha7>`; commit+push only when it differs

Every upstream dev push → new SHA → new version → HA offers update → supervisor rebuilds from fresh `:dev` image. Same cadence as the existing daily cron. This mirrors upstream's own `docker.yml` version scheme (`0.4.0-dev.5+g1a2b3c4`).

Simpler semi-manual alternative: one-time pin to `:dev` + version bump, and **disable/skip** the `bump-octo-fiesta` job (or it reverts you). Then bump the version by PR whenever fresh dev features are wanted. Zero workflow surgery, but manual.

## Release-binary-tracked addons (upstream image unusable → asset download)

When upstream's Docker image cannot be the addon base but they publish per-arch prebuilt
release binaries, track the release tag and download the asset at build time. Same bump-job
shape as `bump-hermes-webui` (GitHub `releases/latest`, no-v tag); same from-scratch layout
as beets/personal-app.

**Deciding the image is unusable:**
- Runtime stage is **distroless** (`FROM gcr.io/distroless/cc-debian12` — no shell, no
  apt/apk): cannot run the bashio `run.sh` every addon needs, and its own `ENTRYPOINT`
  defeats the addon entrypoint. GHCR tag presence (semver tags + `latest`) proves nothing —
  read the Dockerfile's runtime `FROM`, not the tag list.
- Release binary is **glibc-dynamic** (check the asset with `file` + `ldd` before picking a
  base — the mediaflow 1.1.2 assets need `/lib64/ld-linux-x86-64.so.2`, `libc.so.6`,
  `libm`, `libgcc_s`). HA's default `ghcr.io/home-assistant/*-base` images are
  **Alpine/musl** and will not exec it — pin the Debian variants in `build.json`:
  `"build_from": { "amd64": "ghcr.io/home-assistant/amd64-base-debian:latest", "aarch64": "ghcr.io/home-assistant/aarch64-base-debian:latest" }`
  (both confirmed to exist on GHCR via anonymous token exchange).

**Shape:**
- `config.yaml version: "<tag>"` — GitHub release tags often lack the `v` prefix; asset
  URLs match the raw tag, so strip any `v`.
- Dockerfile: `ARG <APP>_VERSION=<current release>` (default is sed-bumped by the job) +
  arch→asset mapping with the builder-injected `ARG BUILD_ARCH`
  (`case "${BUILD_ARCH}" in amd64) A=x86_64;; aarch64) A=aarch64;; *) exit 1;; esac`) +
  `curl -fSL --retry 3 -o /usr/local/bin/<bin> "https://github.com/<owner>/<repo>/releases/download/${<APP>_VERSION}/<bin>-linux-${A}"`.
  A **version-stamped URL** keeps every rebuild reproducible — never float on `latest`.
- `arch:` only what upstream publishes (release assets / Dockerfile buildx matrix — often
  amd64+aarch64; don't invent armv7). bashio install = the apt branch of the octo-fiesta
  Dockerfile install (base is Debian, not Alpine).
- Do NOT `COPY` upstream's `config-example.toml` — placeholder secrets in it become live.
  Pass everything via env; upstream env names double the TOML path
  (`APP__AUTH__API_PASSWORD` → `[auth].api_password`), so `config-example.toml` is the
  ground-truth option surface. Skip options whose runtime deps the image doesn't ship
  (e.g. transcode needs ffmpeg) and external-infra options (Redis, Telegram session);
  document exclusions in the addon README. Omit `map:`/`/data` when the app is stateless
  (in-process caches only) — nothing to persist.
- Bump job in `upstream-bump.yml` (daily cron, hermes-webui shape): fetch
  `releases/latest` `.tag_name` (no-v) → sed `config.yaml version` AND the Dockerfile
  `ARG <APP>_VERSION=` → prepend the release-body section to `CHANGELOG.md` (rolling
  window) → bot commit to main. Supervisor shows Update when the version string changes;
  the rebuild pulls the new pinned asset.
- The Dockerfile must not reference a `CONFIG_PATH`/config file the upstream distroless
  image baked in (`ENV CONFIG_PATH=/app/config.toml` + `COPY config-example.toml`) — env
  vars override TOML, so just never set `CONFIG_PATH` and never copy the example file.

### Probe the real binary before finalizing (verified recipe)

Run the actual release asset natively in the agent container (this host IS the HAOS VM, so
the numbers are real deployment evidence, not extrapolation) BEFORE writing config.yaml
defaults, run.sh, and the README resource row:

1. `curl -o <bin> <release-asset-url>` → `file` + `ldd` (linkage decides the base image),
   `chmod +x`, run with a throwaway env config (`APP__AUTH__API_PASSWORD=test ... <bin>`).
2. Sample idle RAM: poll `/proc/<pid>/status` `VmRSS` a few times (max, not first sample —
   startup allocates). Load: serve a large sparse file (`truncate -s 200M`) from a local
   `python3 -m http.server`, pull N concurrent full streams through the proxy endpoint,
   re-sample RSS + CPU (`/proc/<pid>/stat` utime+stime delta). Zero-copy proxies keep RSS
   FLAT under load — a growing RSS under streaming is the anomaly worth reporting.
3. Probe auth/network behavior — never assume from the README:
   - **Default bind may be loopback** (`Starting ... on 127.0.0.1:8888`) when run without the
     upstream config file — upstream's own image only listens externally because it ships
     config-example.toml (`host = "0.0.0.0"`). The addon run.sh MUST export the bind env
     (`APP__SERVER__HOST=0.0.0.0`) unconditionally or the container is unreachable.
   - **Unconfigured password ≠ open.** Some apps 401 EVERYTHING when the password is empty
     (locked, not open) — curl the endpoints with/without the password param and record the
     codes; that decides whether the option is mandatory and what the README must say. An
     empty password default is then SAFER than upstream's own image, whose bundled
     config-example activates a placeholder secret.
   - Confirm which routes are unauthenticated (`/health` 200, web UI may load without auth —
     that shapes the security section) and that logs go to stdout (they flow to the HA Log tab).
4. Log the real numbers in the addon README resource row WITH the test conditions (workers,
   file size, concurrency) so they are honest and reproducible.

## Upstream facts that matter

- `V1ck3s/octo-fiesta` **default branch is `dev`** (not master). `docker.yml` builds images on: tag pushes `v*`, branch pushes `master` AND `dev`.
- GHCR tags confirmed live: `dev`, `master`, `latest` (latest only when ref==master), `v0.x`, plus per-commit sha tags and feature-branch tags (`feat-*`, `fix-*`).
- `dev` manifest = **linux/amd64 + linux/arm64 only — NO armv7**. The addon's `build.json` still lists `armv7` → that arch was already unbuildable with the release tags too. Remove `armv7` from `build.json` AND from `config.yaml arch:` if multi-arch builds matter.
- Only 2 workflows upstream: `ci.yml` + `docker.yml`.

## Probing GHCR tags/manifests (no `read:packages` token)

`gh auth token` → GHCR returns `403 invalid token` (scope mismatch). Public images work with the **anonymous token-exchange** flow:

```bash
TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:v1ck3s/octo-fiesta:pull&service=ghcr.io" | jq -r '.token')
# list all tags:
curl -s -H "Authorization: Bearer $TOKEN" "https://ghcr.io/v2/v1ck3s/octo-fiesta/tags/list" | jq -r '.tags[]' | sort
# check a tag exists + which platforms:
curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.oci.image.index.v1+json" \
  "https://ghcr.io/v2/v1ck3s/octo-fiesta/manifests/dev" | jq -r '.manifests[]? | .platform.os + "/" + .platform.architecture'
```

A `404` on a manifest = tag doesn't exist; `200` with `unknown/unknown` entries = attestation blobs, ignore them.

## Verified supervisor mechanics (source-level, 2026-08-17)

Facts pulled from `home-assistant/supervisor` source (post "addons→apps" refactor; the store files live in `supervisor/apps/` + `supervisor/store/`):

- **Update detection = plain inequality, not semver.** `supervisor/apps/app.py` `need_update` → `self.version != self.latest_version`. ANY differing version string triggers the Update button — `dev-<sha7>` works even though it's not semver.
- **Version validation is lenient.** `supervisor/validate.py` `version_tag()` wraps the value in `AwesomeVersion()` with no format constraint — `dev-abc1234` passes.
- **Changelog tab is auto-enabled by file existence.** `supervisor/apps/model.py` `path_changelog` = `<addon folder>/CHANGELOG.md`; `with_changelog` = file exists. The addon page's Changelog tab appears automatically. The frontend parses per `## <version>` heading — the heading should match the `config.yaml` version string so the right section is highlighted.
- The octo-fiesta addon already ships a 3-line `CHANGELOG.md` (link to upstream releases) → its Changelog tab is already live; it just needs useful content.

## Adding commit notes / links to the HA update UI

The bump workflow can generate the changelog at each bump (answers "can we see what changed when installing updates?"):

1. Fetch the commit list between old and new SHA:
   `curl -sL https://api.github.com/repos/V1ck3s/octo-fiesta/compare/<oldsha>...<newsha>` → array of `{sha, commit.message, author, html_url}`.
2. Prepend a markdown section to `addons/octo-fiesta/CHANGELOG.md`:
   ```markdown
   ## dev-<newsha7> — <date>
   - [<commit title>](https://github.com/V1ck3s/octo-fiesta/commit/<full-sha>)
   ...
   Compare: [<oldsha7>...<newsha7>](https://github.com/V1ck3s/octo-fiesta/compare/<oldsha>...<newsha>)
   ```
3. **Keep a rolling window** of the last ~10 dev entries — a daily bump grows the file fast, and the frontend parses per-heading so old sections are dead weight.
4. **Cadence:** HA picks up the new CHANGELOG.md when it refreshes the addon store repo (daily poll / manual reload) — the same moment the update itself appears. No extra delay.
5. Minimal fallback (zero parsing): write only `Compare: https://github.com/V1ck3s/octo-fiesta/compare/<old>...<new>` into the changelog.

## Verifying skills/Hermes data are in HA backups

- HA **full** snapshots include `/addon_configs/*` → `HERMES_HOME` (`.hermes/skills/`, memories, config) and `workspace/` are inside every automatic full backup. Verify via ha-mcp `ha_manage_backup(scope="snapshot", action="list")`: automatic backups show `with_automatic_settings: true`, `homeassistant_included: true`, `database_included: true` (e.g. this install: daily ~05:00, latest `c48f7681` 2026-08-17).
- You CANNOT inspect the tarball from inside an addon container: `/backup` is not mounted there and the supervisor API is 403/401 from addon containers. Definitive check = from the Terminal & SSH addon: `tar -tf /backup/<id>.tar | grep hermes`.
- Caveat to state when asked: this holds only while the backup policy stays FULL. A partial policy that excludes the `<hash>_hermes_agent` addon data would leave skills out.

## GitHub-side gotchas (already in SKILL.md, re-affirmed here)

- Pushing `.github/workflows/*` changes needs `workflow` OAuth scope — token lacked it; either `gh auth refresh -h github.com -s workflow` (interactive) or have the user paste the new workflow content into the GitHub web editor (zero-token path, user's preference).
- `ci.yml`, `main-release.yml`, `dev-release.yml` only watch `addons/personal-app/**` → octo-fiesta changes don't trigger them. No conflicts.
- The user's stance (2026-08-17): prefers `gh` CLI over a GitHub MCP server — no GitHub MCP configured in Hermes, and adding one would cost ~80+ tool schemas per context turn on a small model (same context-bloat argument as ha-mcp). Token scopes in use: `gist`, `read:org`, `repo`.

## Line-ending noise & the `.gitattributes` fix (durable, 2026-08-18)

Symptom: after the user pastes a workflow file into the GitHub web editor, the
PR diff shows the **WHOLE file changed** even though the content is identical.
Cause: the repo stores CRLF blobs, the web editor writes LF → Git sees every
line's ending byte differ. Content is correct and mergeable, but review is ugly.

Durable fix (user approved adding it to the same PR — `879fc20`, PR #15):

```gitattributes
# Normalize line endings: LF in the repo, native on checkout
* text=auto
# Shell scripts must always use LF (CRLF breaks them)
*.sh text eol=lf
# Workflow files: keep LF in repo (web editor writes LF; avoids whole-file diffs)
.github/workflows/*.yml text eol=lf
.github/workflows/*.yaml text eol=lf
# Explicitly mark binary files so Git never touches them
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.woff binary
*.woff2 binary
*.zip binary
```

Mechanics to explain when the user asks ("what is LF?"):
- LF = `\n` (1 byte, Unix/macOS/Git/web); CRLF = `\r\n` (2 bytes, Windows).
- `* text=auto` = Git stores the normalized (LF) form in the repo and converts
  to native endings on checkout → future web-editor pastes (LF) diff cleanly.
- **It does NOT retroactively renormalize existing blobs** — the current PR
  diff stays noisy until `git add --renormalize .` is run once after merge
  (offer this as a follow-up).
- The user did NOT know `.gitattributes` existed — surface it proactively when
  diagnosing whole-file diffs; it's a tiny, safe change (pre-commit passes on
  it: end-of-file-fixer + trailing-whitespace are the relevant hooks).
- Copy-paste starter in `templates/gitattributes-lf-normalize`.

## Config-surface sync vs upstream (verified 2026-08-18, PR #16)

Tracking the image version (above) is half the job — the addon's **config
surface** (`config.yaml` options+schema, `run.sh` env mapping) must also match
what the upstream binary actually reads. After switching to `:dev`, the image
gains features the addon UI can't configure (and keeps options upstream
deleted). The user asked to check "are the settings up to date with dev? we
don't have the latest features" — that's the trigger for this procedure.

**Ground truth sources (in order of value):**
1. Upstream `.env.example` — the canonical config surface (`SUBSONIC_*`,
   `DEEZER_*`, `SQUIDWTF_*`, `Lyrics__*`, …).
2. `octo-fiesta/Models/Settings/*.cs` — the actual bound settings models, incl.
   the exact env-var names (`Environment variable: Lyrics__Enabled` in the XML
   doc) and enum values. New model file in the tree = new feature the addon
   doesn't expose (e.g. `LyricsSettings.cs` appeared on dev — LRCLIB synced
   lyrics, 5 options, entirely absent from the addon).
3. Enumerate upstream tree: `git/trees/dev?recursive=1` → spot new
   `Models/Settings/*.cs` and new `.cs` files; grep all `.cs` files for a
   suspect option name (0 refs = dead: `retry_duration`, `force_minimal` were
   gone upstream but still in the addon).

**Findings pattern (what the diff produces):**
- 🔴 Missing features: new `*Settings.cs` models / new env sections absent from
  `config.yaml` AND `run.sh` (Lyrics block, `DisableLibraryScan`,
  `SquidWTF__Country`).
- 🟡 Incomplete schema values: addon schema enum narrower than upstream
  (`squidwtf_source: list(Qobuz|Tidal)` vs upstream `Qobuz|Tidal|AmazonMusic|Deemix`).
- 🟠 Stale options: in addon but zero references upstream (remove from
  `config.yaml` options + schema + `run.sh` together, or HA UI offers
  options that do nothing).

**Verification before commit:**
- options ↔ schema 1:1: `set(d['options']) ^ set(d['schema'])` must be empty
  (35/35 on PR #16) — the HA UI cannot save a config whose schema lacks an
  option key.
- `bash -n addons/octo-fiesta/run.sh` for export lines.
- Pre-commit on both files (same expectation as any PR).
- New env vars map via `export_if_set <Env>__<Key> <config_key>` in run.sh;
  keep the existing block structure (Subsonic/Library/Lyrics/Deezer/Qobuz/
  SquidWTF/Yandex sections).

**PR workflow:** separate PR from the version-tracking PR (`feat/octo-fiesta-dev-config`,
PR #16, based on `main` — different hunks than PR #15 so no conflict in either
merge order). **Merge order matters**: version PR first (gets the `:dev` image
with the features), config PR second (exposes them in the HA UI). Stale options
removed: `retry_duration`, `force_minimal`, `download_mode=Playlist` (upstream
enum is only Track|Album).

## Execution playbook (verified 2026-08-18, PR #15)

When actually delivering this change as a PR, the `workflow`-scope wall forces a
**split-push** pattern — the workflow file cannot ride in the same commit as the
addon files:

1. **Worktree, not the dirty clone.** The main clone had uncommitted WIP on
   `fix/hermes-webui-editable-install`; never build a PR branch on top of that.
   `git worktree add /tmp/octo-dev-pr -b chore/octo-fiesta-track-dev origin/main`
   → clean checkout of `main`, original working tree untouched.
2. **Commit ALL files, push, expect the workflow file rejected:**
   `git push` fails with `refusing to allow an OAuth App to create or update
   workflow .github/workflows/upstream-bump.yml without workflow scope`.
   Run the repo pre-commit hooks FIRST (user explicitly asks about this):
   `pip install pre-commit` if absent, then
   `pre-commit run --files <changed files>` — auto-fixes apply, re-`git add`
   afterwards. All hooks passed with zero fixes on the octo-fiesta change
   (YAML/JSON/detect-secrets all clean); the commitizen hook runs at
   commit-msg stage so the message must match the conventional-commit regex.
   `make install-dev` is personal-app-only (uv sync) — not applicable to
   other addons; mention that, but run pre-commit regardless.
3. **Split:** `git reset --soft HEAD~1 && git restore --staged .github/workflows/upstream-bump.yml`, recommit WITHOUT the workflow file, push again → succeeds (addon files only).
4. **PR:** `gh pr create --base main --head <branch>` with a SHORT body (user
   convention: problem → change → follow-up note). Verified via
   `gh pr view <n> --json files,additions,deletions` — no CI checks run because
   workflows only watch `personal-app`.
5. **Hand the workflow to the user to paste** via the GitHub web editor on the PR
   branch (their browser session has the rights the token lacks) — complete
   validated YAML in `templates/upstream-bump-dev-track.yml`.
6. **Verify the paste after they do it** (`git fetch origin`, check the new
   commit landed on the PR branch). The web editor converts the file to LF →
   the diff shows the WHOLE file changed (cosmetic noise, mergeable anyway).
   Confirm functional identity by diffing endings-normalized content:
   `diff <(git show origin/<branch>:<file> | tr -d '\r') <(tr -d '\r' < local-copy)`
   — only expected deltas: LF endings, no trailing newline, and unescaped
   quotes in `grep -oP` patterns (`"\K[^"]+` ≡ `\"\K[^\"]+` in PCRE). Then
   re-run `pre-commit run --files` on the branch state if wanted (end-of-file
   hook will flag the missing trailing newline — cosmetic; pre-commit isn't
   enforced by CI for non-personal-app paths).

CRLF pitfall (this repo stores CRLF): the `patch` tool refuses edits to
`.github/workflows/*.yml` when its YAML validator trips over the candidate
content (fails on CRLF + embedded `sed 's/\r$//'`-style quoting) — and even
plain string-replace fails on the backslash-heavy `grep -oP '...:\\K...'` lines.
Working method: edit via Python (execute_code) with **line-range replacement**
(`lines[:8] + [new_job] + lines[50:]`), then validate with `pyyaml` before
committing. The delivered workflow itself is validated YAML — the `tr -d '\r'`
cosmetic tweak was left out (awk output on CRLF source is acceptable).

Other execution notes:
- Initial `config.yaml version` = the CURRENT upstream dev SHA7 (`dev-ac35be3`),
  so the first nightly run is a no-op and the first user-visible update is
  v0.10 → dev-ac35be3 carrying the pre-seeded changelog.
- Pre-seed `CHANGELOG.md` with `compare/v0.10...<dev-sha>` commit list (33 commits
  in Aug 2026) in the PR itself — the first update shows "what's new" immediately.
- Commit message follows the repo's conventional-commits convention
  (`chore(octo-fiesta): track upstream :dev image tag`); squash-merge title
  becomes the commit message.
