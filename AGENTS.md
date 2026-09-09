# AGENTS.md — working rules for AI agents in this repo

Canonical operational rules for AI coding agents (Claude Code, Hermes) working in this
repository. Human contribution guidance lives in [CONTRIBUTING.md](CONTRIBUTING.md) — where
they differ, this file governs agent behavior, and per-addon files win over both
(e.g. `addons/personal-app/CONTRIBUTING.md`). No CLAUDE.md exists; Claude Code reads this
file natively.

## What this is

A **multi-add-on** Home Assistant repository. Each add-on is fully self-contained under
`addons/<slug>/` (`config.yaml`, `Dockerfile`, `build.json` when image-based, `run.sh`,
`README.md`). Current add-ons: `beets`, `hermes-webui`, `mediaflow-proxy-light`,
`octo-fiesta`, `personal-app`.

## Conventions (all add-ons except where personal-app says otherwise)

- **Branch from `main`** — there is no `dev` branch workflow here. Conventional commits
  (commitizen is a pre-commit hook; CI enforces the same regex on PR titles); PRs are
  **squash-merged** — the PR title becomes the commit message.
- **Git identity**: copy the author email from existing commits (`git log --format='%ae'`),
  never invent one — GitHub attributes commits by email, and a wrong noreply address creates
  a phantom participant. Repo-local `.git/config` has carried the wrong email before; check it.
- **Run pre-commit** on changed files before every commit (`pre-commit run --files …`).
  Auto-fixers may modify files and abort the commit — `git add` and recommit; that is normal.
- **`personal-app` is special**: it owns its tooling (Makefile, pyproject, mkdocs, its own
  CONTRIBUTING) and its own release pipeline. Read `addons/personal-app/` docs before touching it.

## CI reality — know what is NOT checked

- CI (`ci.yml` / `quality-and-tests.yml`) triggers **only on `addons/personal-app/**`**.
  PRs touching any other add-on (beets, hermes-webui, octo-fiesta, workflows) run **zero
  automated checks**. Manual verification is the only gate: pre-commit hooks locally,
  `bash -n` on shell, YAML validity, careful diff review. Never tell the user "CI will
  verify this" for a non-personal-app PR.
- **Exception: `mediaflow-proxy-light`** has its own workflow
  (`mediaflow-proxy-light.yml`) — on PRs/pushes touching `addons/mediaflow-proxy-light/**`
  it runs pre-commit + a real `docker build` with a smoke test (health, auth 401/200,
  streaming through the proxy). That add-on's PRs DO get automated checks; everything else
  still relies on manual verification.
- Release workflows also only fire for personal-app; add-on-only changes must not be framed
  as releases.

## Versioning — by add-on type (do not guess)

- **Image-pinned** (octo-fiesta): `build.json` pins the upstream image and
  `upstream-bump.yml` (nightly) owns both `build.json` and `config.yaml version:`.
  Never hand-edit them — the next nightly run reverts or re-bumps.
- **PyPI-tracked** (beets): `config.yaml version:` mirrors the upstream package version and
  `upstream-bump.yml` bumps it. Add-on-code fixes are delivered by **manual reinstall** —
  never add a patch suffix to the version (user's explicit rule; a suffix makes HA offer an
  update the bump job would then fight). Preserve the add-on's `/data` with `docker cp`
  around uninstall/reinstall.
- **Pinned release** (hermes-webui): `config.yaml version:` pins an upstream app release;
  `run.sh` changes bake into the image only at **rebuild** (not plain restart).
- **Release-tracked binary** (mediaflow-proxy-light): `config.yaml version:` mirrors the
  upstream GitHub release tag (no `v`); the Dockerfile pins the same version as
  `ARG MEDIAFLOW_VERSION` (the binary is downloaded from the release assets at build time —
  the upstream image is distroless and unusable as an addon base). `upstream-bump.yml`
  (nightly) owns both files. Add-on-code fixes ship via **manual reinstall** — never
  suffix-patch the version (same rule as PyPI-tracked).

## Persistence & containers

- Containers are disposable: runtime state lives in `/data/<addon>`; `run.sh` reads options
  via bashio, never hardcodes secrets. Add-ons that need the agent home set `HOME` onto a
  persistent volume.
- `run.sh` is committed as `100644` and made executable by the Dockerfile
  (`COPY run.sh /` + `chmod a+x` + `ENTRYPOINT`); don't chmod +x it in git (mode-noise).
  If `git status` shows every file modified (mode churn), set `git config core.fileMode false`.
- Share **data** between add-ons, never venvs/checkouts (they couple update lifecycles and
  break when mounted at different paths).

## File conventions

- `.gitattributes` ships `* text=auto` + `eol=lf` for shell/workflows — write new files as LF.
  Some legacy blobs are CRLF: prefer line-range edits (`patch`) over rewrites on those, or the
  whole file diffs.
- detect-secrets flags option **keywords** in `config.yaml` schemas (e.g. `*_password: str?`)
  even with empty defaults — inline `# pragma: allowlist secret` on the flagged schema line.

## Skills

Repo-specific agent skills (if ever needed) live in `.claude/skills/<name>/` here.
General/shared skills come from the personal-os-setup chezmoi source (2-track governance in
that repo's AGENTS.md) — never vendor a Track-2 plugin's skills into this repo.
