---
name: home-assistant-addon-dev
description: Workflow for developing, packaging, and deploying Home Assistant add-ons in this repo — architecture principles, versioning patterns, and where to find per-add-on deep dives.
---

# Home Assistant Add-on Development

Governs the creation and maintenance of add-ons in this repo. Repo-wide conventions (branching,
CI scope, git identity, versioning-by-type, secrets pragmas) live in the root `AGENTS.md` — that
file is canonical; this skill holds the deeper architecture/packaging knowledge and defers to it
whenever the two could drift.

## Trigger Conditions
- Creating a new add-on, or adding a service/API to an existing one.
- Deciding which upstream-tracking pattern an add-on should use (see `references/versioning-patterns.md`).
- Deciding where an add-on's data should live, or removing a `map:` entry (see
  `references/addon-capability-hygiene.md`).
- Setting up or debugging a per-add-on CI build/smoke gate (see `references/addon-ci-build-gate.md`).
- Reviewing an add-on before exposing it to the internet (see `references/exposure-review-checklist.md`).
- Working on a specific add-on with its own deep-dive skill: `beets-addon-dev`, `aiostreams-addon-dev`,
  `hermes-webui-addon-dev`, `octo-fiesta-addon-dev`. `mediaflow-proxy-light` and `personal-app`
  deliberately have none — mediaflow's add-on-specific detail (its option surface and which paths
  answer without credentials) lives in its own README, and `personal-app` owns its own tooling and
  docs under `addons/personal-app/`.

## Core Architecture Principles

- **Modular monolith over a swarm of small add-ons.** Prefer one "hub" API (FastAPI + routers) to
  minimize DevOps overhead, unless the workload genuinely needs its own container (see "batch jobs"
  below).
- **Disposable containers, `/data` is truth.** Treat the container filesystem as ephemeral; all
  runtime state lives in `/data/<addon>`.
- **Mount taxonomy** — pick the mount by what the data actually is, not by habit:
  - `/data` — the add-on's private, always-present volume. Included in snapshots, **deleted on
    uninstall**. Home for state: DB, cache, credentials.
  - `addon_config` (mounted at `/config` inside the container, backed by
    `/addon_configs/<repo>_<slug>` on the host — see `references/haos-app-config-paths.md` for the
    host-vs-container naming split) — for files a human provides or inspects (user config, a
    browsable DB/log). User-writable, so never home a live SQLite DB here.
  - `homeassistant_config` — HA's own config tree (`secrets.yaml`, `.storage`). Read-only when an
    add-on must consume it; never a place to write add-on state.
  - `share` / `media` — cross-add-on data.
  - Every mount is an exposure path — declare only what's needed, and re-verify against the actual
    artefact on disk before keeping or dropping one (`references/addon-capability-hygiene.md`).
  - `map:` is read by the Supervisor at container **creation** — a mount change needs a
    reinstall, not a restart.
- **Persistence via `HOME`.** Docker containers are ephemeral by default; never rely on `/root`.
  Set `ENV HOME=/data/<addon>` (or `/config`) in the Dockerfile so pip user-site packages, `gh`
  auth, and tool configs land on a persistent volume. Give each add-on its own `HOME` subdir to
  avoid lock contention between containers.
- **Share data, never venvs.** In multi-container add-on pairs, share persistent *data* between
  containers — never Python venvs or checkouts. Shared venvs couple independent update lifecycles
  and break when the same directory is mounted at a different path in each container.
- **Batch jobs go where the files are.** A job touching `/media` belongs in a container with
  `map: media:rw` (local-disk I/O); the host only sees HAOS `/media` over a network share.
  Long-running services and one-shot batch CLIs should not share a container — a multi-minute job
  must not compete with a service that restarts on every update.

## Versioning & Upstream Tracking

Decision framework and mechanics (image-pinned, PyPI-tracked, nightly-tracked, release-binary-tracked):
`references/versioning-patterns.md`. The *rule* for which type an add-on is and who owns the bump
files is in the root `AGENTS.md` — don't restate it here, link to it.

## Development Workflow

1. **Local development:** build the API outside HA first.
2. **Scaffolding** (mirror an existing from-scratch add-on, e.g. `personal-app`):
   - `config.yaml`: metadata, ports, options + matching schema (1:1 — the Supervisor UI cannot
     save an option missing from the schema). Options the app cannot start without must NOT be
     optional (`str`, not `str?`) — an optional field that's actually required lets the UI save an
     empty value and the container dies at boot.
   - `Dockerfile`: base image + deps + `bashio` (already present on HA base images — only install
     it when tracking a foreign upstream base).
   - `run.sh` (or a language-native bootstrap for a distroless upstream image — no bashio, no
     shell; read `/data/options.json` directly, `spawn` the app, forward signals since the
     bootstrap is PID 1): bridge options to env vars and launch the app.
3. **Shipping:** branch from `main`, get explicit approval before `git commit` and again before
   `git push` (see the repo-conventions skill for the general PR flow), open the PR with `gh pr
   create` (title = conventional commit, squash-merge uses it as the commit message), merge to
   `main`.
4. **Releasing:** bump `version` in `config.yaml` — HA compares this string for exact inequality,
   not semver, so any change works; no update banner appears if it's unchanged even when `map:` or
   other config did change.

## Pitfalls

- **`run.sh` is committed as `100644`**, made executable by the Dockerfile
  (`COPY run.sh /` + `RUN chmod a+x /run.sh` + `ENTRYPOINT`) — never `chmod +x` it in git (causes
  mode-noise diffs). If `git status` shows every file modified, run
  `git config core.fileMode false`.
- **Declare API/mount permissions explicitly** — they default to OFF and fail at runtime, not at
  save time: `homeassistant_api: true` (else 401 from `http://supervisor/core/api/*`),
  `hassio_api: true` + `hassio_role` (else 403 from the supervisor API, only `/info` works
  without it).
- **`map:` changes need a reinstall; `run.sh` changes need an image rebuild.** A plain restart
  applies neither.
- **detect-secrets flags option *keywords*, not just values** — a schema line like
  `some_password: str?` trips "Secret Keyword" even with an empty default. Fix with an inline
  `# pragma: allowlist secret` on that exact line only (not on unrelated defaults).
- **CI only runs where a workflow's `paths:` says so.** Repo-wide CI is scoped to
  `addons/personal-app/**` (see `AGENTS.md`); other add-ons need their own workflow
  (`references/addon-ci-build-gate.md`) or rely on manual review. Path-filter and multi-job-push
  pitfalls that make automation silently stop working: `references/ci-automation-pitfalls.md`.

## Linked Files

- `references/versioning-patterns.md` — upstream-tracking patterns (image-pinned, PyPI-tracked,
  nightly/dev-branch SHA-tracked, release-binary-tracked) with the Dockerfile/workflow shape for each.
- `references/addon-capability-hygiene.md` — evidence procedure for adding or removing a `map:` entry.
- `references/haos-app-config-paths.md` — the host-vs-container config-path naming split
  (`app_configs`/`addon_configs`) and why a host-side path silently resolves to nothing in-container.
- `references/addon-ci-build-gate.md` — per-add-on CI build + smoke-test workflow shape, including
  the mandatory fake-Supervisor-API pattern for bashio add-ons.
- `references/ci-automation-pitfalls.md` — why upstream-bump jobs silently stop pushing, and why
  Renovate rebases can fire unrelated add-ons' workflows.
- `references/exposure-review-checklist.md` — probing an add-on's real auth matrix before exposing
  it, plus a generic edge-exposure checklist.
- `templates/config.yaml`, `templates/Dockerfile` — from-scratch add-on boilerplate.
- `templates/gitattributes-lf-normalize` — starter `.gitattributes` to stop whole-file diffs from
  CRLF/LF mismatches.
