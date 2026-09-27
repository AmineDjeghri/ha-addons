# AGENTS.md — working rules for AI agents in this repo

Canonical operational rules for AI coding agents (Claude Code, Hermes) working in this
repository. Human contribution guidance lives in [CONTRIBUTING.md](CONTRIBUTING.md) — where
they differ, this file governs agent behavior, and per-addon files win over both
(e.g. `addons/personal-app/CONTRIBUTING.md`). No CLAUDE.md exists; Claude Code reads this
file natively.

## What this is

A **multi-add-on** Home Assistant repository. Each add-on is fully self-contained under
`addons/<slug>/` (`config.yaml`, `Dockerfile`, `build.json` when image-based, `run.sh`,
`README.md`). Current add-ons: `aiostreams`, `beets`, `hermes-webui`, `mediaflow-proxy-light`,
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

- CI (`ci.yml` / `quality-and-tests.yml`) triggers **only on PRs touching
  `addons/personal-app/**`** — no push trigger (pushes to feature branches used to double
  every check; PRs are the only gate now). PRs touching any other add-on (beets, hermes-webui,
  octo-fiesta, workflows) run **zero automated checks**. Manual verification is the only gate:
  pre-commit hooks locally, `bash -n` on shell, YAML validity, careful diff review. Never tell
  the user "CI will verify this" for a non-personal-app PR.
- **Exception: `mediaflow-proxy-light` and `aiostreams`** each have their own workflow
  (`mediaflow-proxy-light.yml`, `aiostreams.yml`) — they run pre-commit + a real `docker build`
  with a smoke test (mediaflow: health, auth 401/200, streaming through the proxy; aiostreams:
  options bootstrap, `/api/v1/status`, configure page, SQLite persistence in `/data`) on PRs
  touching their add-on folder, and on pushes to `main` only (not arbitrary branch pushes —
  Renovate's rebase force-pushes used to trigger these for unrelated diffs). Those add-ons'
  PRs DO get automated checks; everything else still relies on manual verification.
- Release workflows also only fire for personal-app; add-on-only changes must not be framed
  as releases.

## Versioning — by add-on type (do not guess)

- The five `upstream-bump.yml` jobs run as a `needs:` chain (each `if: always()` so one
  add-on's failure doesn't skip the rest), so only one job pushes to `main` at a time and a
  bump can no longer be discarded by a concurrent push.

- **Dev-branch-tracked image** (octo-fiesta): `build.json` pins the upstream `:dev` image
  **permanently** (the bump job never touches it) and `config.yaml version:` is derived from the
  upstream **`dev` branch commit SHA** (`dev-<sha7>`), so every upstream push surfaces as an HA
  update. `upstream-bump.yml` owns `config.yaml` only — never hand-edit either file, and never
  "sync" `build.json` back to a release tag (that silently reverts the channel).
- **PyPI-tracked** (beets): `config.yaml version:` mirrors the upstream package version and
  `upstream-bump.yml` bumps it. Add-on-code fixes are delivered by **manual reinstall** —
  never add a patch suffix to the version (user's explicit rule; a suffix makes HA offer an
  update the bump job would then fight). Preserve the add-on's `/data` with `docker cp`
  around uninstall/reinstall.
- **Pinned release** (hermes-webui): `config.yaml version:` pins an upstream app release;
  `run.sh` changes bake into the image only at **rebuild** (not plain restart).
- **Nightly-tracked image** (aiostreams): `build.json` pins the upstream `:nightly` image
  permanently and `config.yaml version:` is derived from the upstream **main commit SHA**
  (`nightly-<sha7>`), so every upstream commit surfaces as an HA update. `upstream-bump.yml`
  owns `config.yaml` only — never hand-edit either file. The image's runtime is distroless
  (no bash/bashio), so the add-on uses a Node bootstrap (`bootstrap.js`) instead of `run.sh`;
  add-on-code fixes ship via **manual reinstall** (never suffix-patch the version).
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
  Every tracked blob is LF as of the renormalize pass, so whole-file rewrites are safe; if a
  CRLF blob is ever reintroduced it shows a permanent phantom `M` that `git checkout`/`restore`
  can never clear (the worktree already matches the blob) — the fix is `git add --renormalize`,
  not a checkout. `git diff --ignore-cr-at-eol` coming back empty proves it is pure EOL noise.
- detect-secrets flags option **keywords** in `config.yaml` schemas (e.g. `*_password: str?`)
  even with empty defaults — inline `# pragma: allowlist secret` on the flagged schema line.

## Skills

Repo-specific agent skills live in `.claude/skills/<name>/` (Claude Code reads them natively);
other agents read the git symlinks in `.agents/skills/` (never edit through a symlink — edit the
canonical file). Every skill in this repo carries `metadata.hermes.origin: repo:ha-addons` in its
frontmatter (plus `exposure: private` if it must never be published), so a reader can tell a repo
skill from an agent-created one at a glance. Currently:

- `home-assistant-addon-dev` — generic add-on packaging: mount taxonomy, versioning-tracking
  patterns, CI build-gate shape, exposure-review method. Links to `AGENTS.md` for the rules
  (versioning-by-type, CI scope) rather than restating them.
- `beets-addon-dev`, `aiostreams-addon-dev`, `hermes-webui-addon-dev`, `octo-fiesta-addon-dev` —
  one skill per add-on that has genuinely add-on-specific depth (domain logic, upstream quirks,
  architecture). Keep new deep-dive content in the relevant add-on's own skill, not in
  `home-assistant-addon-dev` — it stays generic on purpose so it doesn't grow unbounded as add-ons
  are added.

Skills are **write-only-what's-reusable**: a one-off incident, a specific PR number, or a dated
"user said X" narrative does not belong in a skill — state the generalized rule instead. Keep
files scannable; when a skill file is hard to skim, that's a sign it needs trimming, not that it
needs a longer table of contents.

These files are **public**: never write real host names, LAN IPs, add-on slugs, chat ids or the
owner's name/email/numeric GitHub ID into them — use the placeholder style the content already
uses (`<repo>_<slug>`, `<hash>_<addon>`, `<lan-ip>`, `user@example.com`) and re-scan before
committing. Findings about a specific live deployment (which hostnames are exposed, sizing numbers
for a real install) are answers for whoever asked, not skill content.

General/shared skills (Hermes Agent internals, Claude Code delegation mechanics, generic git/PR
hygiene) come from the personal-os-setup chezmoi source (2-track governance in that repo's
AGENTS.md) — never vendor a Track-2 plugin's skills into this repo, and don't grow a
ha-addons-repo skill to cover something that isn't specific to this repo's own add-ons.
