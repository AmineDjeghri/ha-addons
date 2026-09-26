# Claude Code delegation & interactive sessions (in the HA addon containers)

Operational rules verified on this install (native claude binary at the persistent home).
Complements the bundled `claude-code` skill, which is generic; THIS file is the
environment-specific layer: paths, trust semantics, and the failure modes that cost time here.

## Invocation

- Always invoke the absolute path with the persistent home set, because auth
  (`.claude.json`), plugins, and workspace-trust state all live there:
  `HOME=/addon_configs/<hash>_hermes_agent /addon_configs/<hash>_hermes_agent/.local/bin/claude ...`
  A bare invocation under `/root` (or on the agent addon without the right HOME) loses the
  login and appears "not authed". The gateway PATH never includes `~/.local/bin`.
- After addon updates the `~/.local/bin/claude` symlink can dangle — but note
  `~/.local/share/claude/versions/<version>` is the executable FILE itself, not a directory:
  invoke `/config/.local/share/claude/versions/<ver>` directly (works), or relink the
  symlink to it (`ln -sfn ~/.local/share/claude/versions/<ver> ~/.local/bin/claude`).
  Verify auth first with `claude auth status --text` (Pro OAuth expected on this box).
- A `-p` child whose `--allowedTools` excludes `Bash` CANNOT run validation — print mode
  auto-denies tools outside the whitelist (no prompt), so `bash -n`, `pre-commit`, and
  `python3` checks are silently skipped and the child reports "could not validate". Either
  grant `Bash` in allowedTools or plan to run every verification parent-side after the
  child returns; do not expect the child to self-verify under a restricted whitelist.
- Print mode (`-p`) is the clean default for one-shot tasks; the interactive and
  remote-control modes carry the caveats below.

## Print-mode turn budget: the silent zero-output failure

A `-p` analysis that reads many files can burn its ENTIRE `--max-turns` budget before
producing any output: it exits with `Error: Reached max turns (N)` and an empty result
(symptom: the output log contains only the error line — no findings).

- Budget by scope: ~20 turns fits a focused single-file task; a multi-file PR review
  (19+ files) needed more than 20 and produced NOTHING at 20.
- Prefer piping content as stdin (`git diff main...HEAD | claude -p '...'`) over letting it
  read files turn-by-turn — reading costs a turn per file.
- For genuinely large analysis, use a long-lived interactive/remote session (no turn cap)
  instead of `-p`.
- The Hermes terminal tool caps one foreground call (~420 s) — long `-p` runs must launch as
  `terminal(background=true, notify=true)` and be read from a log file.

## Workspace trust, first-run onboarding, remote control

- Interactive and remote-control sessions refuse an untrusted directory:
  `Error: Workspace not trusted. Please run claude in <dir> first to review and accept the
  workspace trust dialog.`
- **Print mode does NOT record workspace trust.** A directory can be reviewed dozens of
  times with `-p` and still be untrusted for interactive/remote use.
- Trust can be granted WITHOUT the onboarding TUI: the trust dialog only writes
  `"hasTrustDialogAccepted": true` under `"projects": {"/abs/project/path": {...}}` in
  `~/.claude.json` (the persistent home's copy). Patch that field and interactive/remote
  sessions accept the directory immediately — this is the fast path when the only goal is
  trust (e.g. before `remote-control`).
- The first-run onboarding is fragile and should be avoided when credentials already
  exist: it re-runs the login-method screen even when `claude auth status` reports a Pro
  OAuth account, demanding a fresh device-flow URL + a user browser step. If onboarding IS
  needed, do it inside **tmux** and drive with send-keys/capture-pane — a raw Hermes PTY
  cannot advance the Claude TUI (Enter does not move the pickers; repeated submits wedge
  it). tmux is NOT in the webui image — `apt-get install tmux` (also listed in
  personal-os-setup packages.yaml `terminal_tools`). Onboarding order (one Enter per step):
  text-theme picker → syntax-theme picker → "Select login method" — choose **1. Claude
  account with subscription** (Pro/Max OAuth) → an OAuth device URL prints (one long
  `claude.com/cai/oauth/authorize?...` line wrapped across pane rows — capture with
  `tmux capture-pane -p -J`) → the USER opens it in a browser and authorizes → paste any
  returned code back. Progress persists across killed runs (a relaunch resumes past
  confirmed steps).
- `claude remote-control` (control from the Claude phone/desktop app) requires an OAuth
  "Claude Pro/Max account" login — verify with `claude auth status` (an API-key/console
  login will not pair with the app).

### Remote-control server runbook (verified)

- Launch in a persistent tmux session INSIDE the project dir (outlives chat disconnects):
  `tmux new-session -d -s claude-rc '<cmd>'`, then answer its prompts — "Enable Remote
  Control? (y/n)" → `y`; spawn-mode picker → [1] same-dir (default) or [2] worktree per
  spawned session. Success banner: `·✔︎· Ready · <repo> · <branch>` + `Capacity: 0/32` +
  a `claude.ai/code?environment=...` URL. Verify liveness with `tmux capture-pane` — an
  EMPTY pane with `pane_dead=0` means it is quietly waiting, not crashed.
- The user then drives sessions from the Claude mobile app (Code tab) or claude.ai/code;
  permission prompts surface there too. Sessions are SINGLE-controller: the phone drives,
  or you take over via `claude --resume <session-id>` — you cannot both type at once. You
  CAN passively monitor a phone-spawned session's file writes in the repo, but its
  transcript may live cloud-side (nothing new appears under `~/.claude/projects/...`) —
  don't burn time searching for it; ask the user to paste the verdict.
- The server and its tmux session die with the container; both need relaunching after an
  addon update (tmux itself is overlay-ephemeral).

## Plugins (Claude Code)

- Install: `claude plugin marketplace add <owner>/<repo>` then
  `claude plugin install <plugin>@<marketplace> -y` (scope: user default). The registered
  marketplace NAME can differ from the repo (obra/superpowers registers as
  `superpowers-dev`) — read it back with `claude plugin marketplace list` before installing.
- Plugins land under `~/.claude/plugins/` (marketplace git clones + installed_plugins.json)
  and do NOT drop files into `~/.claude/skills` — the shared skills dir stays the curated
  Track-1 set and Hermes' external_dirs index is unaffected. Verify with `claude plugin list`.
- superpowers (v6.x) is a full dev-methodology suite; Hermes already bundles the equivalent
  skills (test-driven-development, writing-plans, subagent-driven-development,
  requesting-code-review) — install it for the Claude side only; its shipped `.hermes-plugin`
  would duplicate what is already loaded.
- Plugin engagement ≠ activation: skills trigger on TASK match, not per session. Pure
  analysis/review prompts leave superpowers mostly idle (a trivial `-p` task still finished
  in 1 turn with it loaded — per-session overhead is just the skill index + bootstrap). Its
  heavyweight methodology (brainstorming → sign-off → plan → TDD) engages only on
  feature/build work — where it adds 30-100% turns by design. To size the cost on a real
  task, run it twice with `--output-format json` and compare `num_turns`/`total_cost_usd`;
  to strip it for a fastest-possible `-p` run, `claude plugin disable superpowers` around
  that run and re-enable after.
- Community skill installers: `npx skills` needs Node (absent in the webui container by
  design); PyPI CLIs are immature (agent-skill-manager, ~2 stars) and desktop managers add a
  second source of truth — neither fits. Track-1 vendoring needs no manager:
  `git clone --depth 1 --filter=blob:none --sparse <repo>` + `sparse-checkout set <dir>`,
  then copy the SKILL.md folder into the shared dir. Install/usage governance: personal-os-
  setup AGENTS.md § "Skills & plugins".
- Plugins (superpowers etc.) load in normal and remote sessions but are skipped by
  `--bare` and are never loaded by Hermes — skills in the shared `~/.claude/skills` dir are
  the only cross-agent currency.

## Two proven delegation shapes

**A. Spec-driven file creation (build work).** Hand the child a written spec — target paths, the repo
conventions, reference files to read first, verified upstream facts — and whitelist ONLY
`Read,Write,Edit`. It creates the files and cannot touch git; the parent reviews, runs pre-commit,
and owns the commit/PR gate. Expect the child to report "could not validate" (no Bash), so every
mechanical check (YAML/JSON parse, options↔schema parity, `bash -n`, heredoc compile) is the
parent's job afterwards.

**B. Independent verification of claims (security/correctness review).** Whitelist `Read,Bash` and
BLOCK git (`--disallowedTools "Bash(git *)"`), then hand it the artifact path plus instructions to
start/stop the service itself. Give each claim to check an ID and the evidence you think supports
it, and require a per-claim verdict (`CONFIRMED` / `PARTLY` / `REFUTED` / `COULD NOT VERIFY`) with
the exact command and observed output. This pass reproduces findings, sharpens wording, and surfaces
things missed (guard asymmetry, CORS behavior, a token that is encrypted rather than signed) — but
the verdicts are self-reports: read the returned commands and results, and adopt corrections into
the deliverable before claiming verification.

## Consultation discipline (user expectation)

Re-view this file — and the bundled `claude-code` skill — when the task class shifts
mid-session (e.g. moving from a background `-p` job to interactive onboarding, remote-control,
or plugin work). A skill file read at session start goes stale: it may have been patched since
that read, and its detail degrades in context. The user expects a fresh re-consultation at the
moment the task type changes, not reliance on an early load — do not treat a session-start
skill load as permanent coverage.
