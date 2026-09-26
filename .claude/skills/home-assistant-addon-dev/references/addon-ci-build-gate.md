# Per-add-on CI build + smoke gate

Why: repo CI (`ci.yml` / `quality-and-tests.yml`) only watches `addons/personal-app/**`, so every
other add-on ships with ZERO automated checks. A dedicated per-addon workflow catches the whole
class of failures that previously reached the user's HA only after merge (bad base-image
assumptions, missing runtime deps, a `run.sh` whose option mapping produces garbage).

Keep it a SEPARATE workflow file — never widen `ci.yml`'s `personal-app` scope.
Trigger on `paths: [``addons/<slug>/**``]` plus the workflow file itself; `permissions: contents: read`.

## Job 1 — validate

- `actions/setup-python` then **`python -m pip install --quiet pyyaml` FIRST** — GitHub runners ship
  no `yaml` module, and the parity check dies with `ModuleNotFoundError: No module named 'yaml'`
  otherwise (a real failure that cost a CI round-trip).
- options↔schema parity: `set(cfg["options"]) != set(cfg["schema"])` → fail.
- `bash -n addons/<slug>/run.sh`.
- repo pre-commit, scoped: `pre-commit run --files <explicit list of the add-on's changed files>` —
  python-only hooks (ruff, uv-lock) self-skip on non-matching paths.

## Job 2 — build-and-smoke (the real gate)

Plain docker, no marketplace action needed:

```bash
docker build \
  --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:latest \
  --build-arg BUILD_ARCH=amd64 \
  -t <addon>-test .
```

Then run the image and assert behavior. amd64-only in CI; aarch64 is left to the supervisor's own
build (QEMU is not worth the minutes).

### A fake Supervisor API is MANDATORY for bashio add-ons

`bashio::config` (v0.16.2) resolves options ONLY via `GET /addons/self/options/config` on the
Supervisor API — it **ignores `/data/options.json`**. Mount an options file and every option
resolves to the literal string `"null"`, which makes a typed config panic at startup
(`invalid type: string "null", expected an integer for key …`) and the smoke test hang until its
health-check loop gives up.

Wiring that works:

1. Serve the endpoint from a tiny python server on the runner, returning the REAL envelope:
   `{"data": {<all options>}, "result": "ok"}`. bashio unwraps `.data` — a bare options object
   yields an empty config and the same all-`null` symptom.
2. `docker run --add-host host.docker.internal:host-gateway \
   -e SUPERVISOR_API=http://host.docker.internal:19998 -e SUPERVISOR_TOKEN=ci-test …`
   (`SUPERVISOR_API` is bashio's documented env override; the token is unused by an
   options-only add-on, so drop it if no assertion needs it.)
3. Serve an upstream file from the runner too (`python3 -m http.server`) and stream it through the
   add-on's proxy endpoint, asserting `curl -w '%{size_download}'` equals the file size byte-exact.
4. Clean up both background servers and the container in a single `trap … EXIT`.

Assertions worth keeping: unauthenticated `/health` → 200; authenticated endpoint → 200;
unauthenticated protected endpoint → 401; byte-exact stream. Do NOT assert on a value fetched from
the public internet (e.g. the proxy's detected public IP) — that makes the gate flaky.

### Validate the workflow before pushing

YAML validity is not enough for a workflow with an embedded heredoc: `yaml.safe_load` it, extract
the python between `<<'PY'` and the closing delimiter, and `compile()` it. A broken heredoc passes
check-yaml and fails only on the runner.

### Local dry-run without docker

Same trick against the real binary: run the fake supervisor in a thread, then launch `run.sh` with
`SUPERVISOR_API=http://127.0.0.1:<port>`. This validates run.sh → env → app end to end and is how
the option mapping was proven before the image ever built.

**Clear `/tmp/.bashio` before each local sim run.** bashio caches the supervisor response at
`/tmp/.bashio/<key>.cache`; a first run where the API was missing/unreachable poisons every later
run with an empty cached config. Production hides this (fresh container per boot, /tmp empty).

## Secret scanning in workflow files

detect-secrets flags test-credential literals in workflows as "Secret Keyword". Findings inside a
`run: |` block are reported at the BLOCK HEADER line (the anchor stays put while content below it
shifts — that is the tell). Remedy: prefer removing the value (an unused `SUPERVISOR_TOKEN` needs no
pragma at all), otherwise put `# pragma: allowlist secret` after the block indicator
(`run: | # pragma: allowlist secret`, valid YAML) as well as on the flagged lines.
When the literal must live inside a JSON heredoc (JSON cannot carry a comment), keep it in a shell
variable on its own commented line and interpolate it into an unquoted heredoc
(`SECRET_KEY="<64-hex>"  # pragma: allowlist secret` + `<<JSON` … `"secret_key": "${SECRET_KEY}"`).

## Variant: add-ons whose entrypoint is a bootstrap, not bashio

When the add-on's PID 1 reads `/data/options.json` directly (a Node/Python bootstrap on a distroless
upstream image — e.g. `addons/aiostreams`), the fake Supervisor API is unnecessary: mount the options
file (`-v /tmp/<addon>-options.json:/data/options.json`) and the bootstrap resolves real values. The
rest of the shape is unchanged, with these differences:

- validate job: replace `bash -n run.sh` with the interpreter's syntax check (`node --check
  addons/<slug>/bootstrap.js`; ubuntu runners ship Node).
- health wait: use the path the upstream image's own HEALTHCHECK calls (read that script) rather than
  a generic `/health`.
- add a persistence assertion, which is the only way to prove the `DATABASE_URI`/`DISK_CACHE_DIR`
  rewiring into `/data` actually happened: `docker cp <container>:/data/db.sqlite /tmp/db.sqlite && [ -s
  /tmp/db.sqlite ]`. `docker cp` works on a shell-less (distroless) container precisely because it does
  not need a shell in the image — that is why it is the assertion tool here instead of `docker exec`.
- wait generously: a Node app with DB migrations can take a minute or two on a cold runner (retry loop
  with ~90 × 2 s, and print `docker logs` on failure).
