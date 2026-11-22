# Agent instructions

Rules for AI coding agents working in `addons/personal-app/`. They extend the repository-root
`AGENTS.md`; where they differ, this file governs this add-on.

## What this is

The Personal App Home Assistant add-on: a uv workspace with two packages, `backend/` (FastAPI,
`personal_app_backend`) and `frontend/` (NiceGUI, `personal_app_frontend`), plus the add-on files
(`config.yaml`, `build.json`, `Dockerfile`, `run.sh`), tests, a documentation site (properdocs / MkDocs
Material) and semantic-release. A release bumps the three `pyproject.toml` versions and `config.yaml`
together, tags `personal-app-vX.Y.Z`, and publishes a GitHub release with both packages' wheels and
sdists, plus the documentation on GitHub Pages. Developer docs: `docs/developer/`.

The tooling is aligned with the python-package-template and generative-ai-project-template. Shared
files (`makefiles/`, `scripts/`, workflows) should stay close to the templates; the deliberate
differences are the add-on files, the `personal-app-v` tag prefix, subfolder paths in the workflows and
the shared repository-root configuration.

## Commands

Run them from `addons/personal-app/`.

```bash
make install-dev          # .venv with dev and docs tools, plus the git hooks in a checkout
make pre-commit-install   # reinstall the git hooks if needed
make test-all             # required comprehensive software validation
make pre-commit           # static hooks; make test-all remains required
make run                  # backend + frontend
make build-package        # dist/ wheels + sdists of backend and frontend
make docker-build         # build the add-on image (needs Docker)
make deploy-doc-local     # build and serve the documentation
make release-status       # read-only preflight: branch, tree, origin sync, tag, GitHub release state
make release-version      # semantic-release: versions, CHANGELOG, tag (main/dev, clean, in sync)
make release-assets       # attach dist/ to the GitHub release
make release              # release-version + verified release-assets (manual release)
make deploy-doc-gh        # documentation to GitHub Pages
```

## Rules

- Use the `make` targets; workflows call `make`, never re-implement a step. A manual release and
  a GitHub Actions release run the same targets (`makefiles/release.mk`).
- Never commit, push, tag, create a GitHub release, run `make release*` / `make deploy-doc-gh` or
  `gh workflow run` without asking first.
- `make release-version` must keep its guards: branch `main` or `dev`, clean tree, in sync with
  `origin`, token from `GH_TOKEN`, then `gh auth login`, then a prompt. Never print a credential.
- Versions, tags and `CHANGELOG.md` belong to semantic-release (Conventional Commits,
  `docs/developer/3.conventions.md`): never edit a `project.version` or the `config.yaml` `version` by
  hand. The three `pyproject.toml` versions always stay equal.
- Settings in `backend_settings.py` / `frontend_settings.py`; secrets as `SecretStr`, set by
  environment or `.env`, never in a file of the repository. A new or renamed environment variable also
  goes in `.env.example` and, for an add-on option, in `config.yaml` and `run.sh`.
- Logging with each package's loguru logger
  (`from personal_app_backend.backend_settings import logger`, the same for the frontend).
- Unit tests run in parallel (pytest-xdist): no shared state between tests.
- The add-on has no authentication: keep it LAN-only (see the README's exposure section).
- Docs: numbered pages in `docs/developer/`, one purpose line, numbered steps, short tables, no
  long prose. Keep the `properdocs.yml` nav in step.

## Required software validation

`make test-all` is the required comprehensive software check for users, developers and CI.
`make test-local` is only a focused diagnostic command. Keep artifact and runtime checks explicit
alongside software validation: unit tests do not prove the add-on image builds or runs in Home
Assistant. If a check was not run, report validation as incomplete instead of claiming the change
fully verified.

## Agent files and skills

`AGENTS.md` is canonical; `CLAUDE.md` is a relative symlink to it. Edit this file directly.
Repo-specific skills live in the repository root `.claude/skills/`.
