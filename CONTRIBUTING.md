# Contributing to ha-addons

Thanks for your interest in contributing! This repository hosts Home Assistant
add-ons. Please take a moment to read the guidelines below before opening issues
or pull requests.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development setup](#development-setup)
- [Reporting bugs](#reporting-bugs)
- [Requesting features](#requesting-features)
- [Submitting changes](#submitting-changes)
  - [Commit conventions](#commit-conventions)
  - [Branch strategy](#branch-strategy)
  - [Release process](#release-process)
- [Style guide](#style-guide)

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

## Development setup

1. **Fork** the repository and clone your fork locally.
2. Install the pre-commit hooks (used for linting and formatting):

   ```bash
   pip install pre-commit
   pre-commit install
   ```

3. Add-ons live under [`addons/`](addons/). Each add-on has its own
   `config.yaml`, `Dockerfile`, and documentation.

## Reporting bugs

- Search existing **issues** first to avoid duplicates.
- Use the **Bug report** issue template.
- Include: Home Assistant / add-on version, supervisor logs, what you expected,
  and what actually happened.

## Requesting features

- Use the **Feature request** issue template.
- Explain the use case and why it would be valuable to other users.

## Submitting changes

1. Create a branch from `main` with a descriptive name, e.g.
   `feat/add-store-option` or `fix/container-restart`.
2. Make your changes and keep them focused on a single issue.
3. Ensure pre-commit checks pass:

   ```bash
   pre-commit run --all-files
   ```

4. Open a pull request against `main`. Keep the description concise (1–2 lines):
   what changed and why.

### Commit conventions

This repo uses [Conventional Commits](https://www.conventionalcommits.org/),
enforced via [commitizen](https://commitizen-tools.github.io/commitizen/) in CI
(scoped to `addons/personal-app/**`). Examples:

- `feat: add new option to personal-app`
- `fix: correct container restart behaviour`
- `chore: update dependencies`

### Branch strategy

`main` is the default branch and the source of truth. Release branches are created
automatically by the CI pipeline (`dev-release` / `main-release` workflows).

### Release process

Releases are driven by [python-semantic-release](https://python-semantic-release.readthedocs.io/)
in CI, scoped per add-on (e.g. `personal-app`). Version bumps and changelog entries
are generated from conventional commits — so meaningful, well-scoped commits matter.

## Style guide

- **Shell / scripts:** use `shellcheck`-clean bash; fail fast with `set -euo pipefail`.
- **YAML:** follow Home Assistant add-on conventions (`config.yaml` schema).
- **Formatting:** let pre-commit handle it (yamlfix, shellcheck, etc.).
