# Test map

Locate self-contained tests and run the existing validation commands.

## Layout

```text
tests/unit/
├── backend/
│   ├── test_metrics.py             Metrics route: status and fields
│   └── test_settings.py            Settings defaults, environment overrides and logging
├── docs/test_doc_stubs.py          API references for packages and workspaces
└── release/
    ├── test_artifacts.py           Complete wheel/sdist sets, version and tag spelling
    ├── test_release_guards.py      Preconditions, failed commands and recovery
    ├── test_release_assets.py      Upload prerequisites and build ordering
    ├── conftest.py                 Temporary projects and command setup
    └── fixtures/release_command.py Fake Git, uv, GitHub and Make boundaries
```

## Run checks

1. Prepare the locked development tools with `make install-dev`.
2. Run `make test-all` for every existing software test, using four pytest workers by default.
3. Run `make pre-commit` for static hooks and strict docs, or `make check` for hooks and software tests.
4. Use `make docs-build` independently when checking documentation.
5. Run `make build-package` separately when artifact inputs change; synthetic test artifacts do not
   prove a real wheel installs or runs.

`make test-unit ARGS="-k release"` selects a focused diagnostic run. `make test-all` rejects filters.
Release tests execute isolated command substitutes; they never publish or mutate this checkout.
