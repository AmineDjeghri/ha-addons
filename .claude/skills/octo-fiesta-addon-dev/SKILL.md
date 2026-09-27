---
name: octo-fiesta-addon-dev
description: Develop and maintain addons/octo-fiesta — a dev-branch-tracked image add-on, its floating-tag pin plus SHA-derived version scheme, and keeping its config surface in sync with upstream.
metadata:
  hermes:
    origin: repo:ha-addons
---

# Octo-Fiesta Add-on

`addons/octo-fiesta/` is the repo's reference image-wrapping add-on: a thin bashio wrapper around an
upstream Docker image, with no add-on-owned application code. General versioning/mount/CI
conventions live in the `home-assistant-addon-dev` skill; this covers what's specific to this
add-on's upstream-tracking setup.

## Update chain

| File | Role | Who owns it |
|---|---|---|
| `build.json` | Pins the upstream base image per arch — permanently `:dev`, all arches | **Manual** — the bump job never touches it |
| `config.yaml` | `version:` — the string HA compares for update availability, `dev-<sha7>` | The bump job (sed) |
| `.github/workflows/upstream-bump.yml` (`bump-octo-fiesta` job) | Resolves upstream `dev` HEAD → new version string | Manual |

This split is the whole point of the pattern: because the image tag is a *floating* pin, it must
stay fixed while the version string moves. Never "sync" `build.json` back to a release tag — that
reverts the channel. Never hand-edit `config.yaml version:` either; the next scheduled run
recomputes it from upstream's `dev` HEAD.

The Dockerfile is a pure wrapper (`ARG BUILD_FROM` / `FROM ${BUILD_FROM}` + bashio + `run.sh`), so
the add-on's actual behavior *is* whatever the pinned upstream image does.

## Dev-branch SHA tracking

This add-on tracks upstream's `dev` branch by commit SHA rather than release tags — see
`home-assistant-addon-dev`'s `versioning-patterns.md` for the generic pattern. The copy-paste
workflow for this exact shape is in `templates/upstream-bump-dev-track.yml`. Two traps specific to
this setup:

- If `build.json` is retargeted to `:dev` without also reworking the bump job to stop comparing
  against release tags, the next scheduled run reverts the pin within a day.
- A floating tag with a version string that never changes yields exactly one HA update banner, then
  silence, even as the image keeps moving — the version string must track something that changes
  per build (the commit SHA).

## Keeping the config surface in sync

Tracking the image version is only half the job. After any retarget onto a faster-moving channel,
diff the add-on's `config.yaml` options/schema and `run.sh` env mapping against upstream's own
config surface (its `.env.example` or settings model source, whichever is ground truth):

- New upstream settings model files / env sections absent here → missing feature.
- Add-on schema enum narrower than upstream's current enum → incomplete.
- Add-on option with zero remaining upstream references → stale, remove option + schema + env
  mapping together.

Verify options ↔ schema stay a 1:1 set before committing — the Supervisor UI can't save a config
whose schema is missing a key for an option that exists.

## Linked Files
- `templates/upstream-bump-dev-track.yml` — validated `upstream-bump.yml` job retargeted to track
  an upstream `:dev` branch HEAD SHA (`dev-<sha7>` version scheme + rolling changelog generation).
