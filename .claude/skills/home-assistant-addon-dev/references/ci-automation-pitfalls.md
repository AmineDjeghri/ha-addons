# CI automation pitfalls — upstream-bump jobs, Renovate, path filters

Two failure modes that look like "the automation is broken" but are workflow-design bugs. Both are silent from the outside: nothing in the repo says anything is wrong, the add-on version just stops moving (or CI noise appears).

## 1. Parallel bump jobs that each commit+push to `main` race — the loser's bump is lost

**Symptom.** One job in the bump workflow is red with:

```
! [remote rejected] main -> main (cannot lock ref 'refs/heads/main': is at <sha> but expected <sha>)
```

and that add-on's `config.yaml version:` never moves while every other add-on tracks upstream fine.

**Mechanism.** Every `bump-*` job checks out `main` at job start and pushes independently. The first push wins; the others are rejected and their commit is discarded. The slowest job (the one making extra upstream API calls / building a changelog) loses **every** time it has something to push — so it looks "usually green" and never updated at the same time.

**Diagnose — per-job conclusions across runs, not the run conclusion:**

```bash
for id in $(gh run list --workflow=upstream-bump.yml --limit 12 --json databaseId --jq '.[].databaseId'); do
  d=$(gh api repos/$OWNER/$REPO/actions/runs/$id --jq '.created_at')
  gh api repos/$OWNER/$REPO/actions/runs/$id/jobs --jq '[.jobs[]|"\(.name):\(.conclusion)"]|join(" ")' | sed "s/^/$d | /"
done
```

- `success` on a bump job is NOT proof it pushed: when upstream did not move, the step's `if:` guard skips the commit entirely, so "success" means "nothing to do".
- Cross-check the losing file's own history: `git log origin/main --oneline -- <addon>/config.yaml`. If it shows only the add-on's creation commit while runs reported successes, the race ate the bumps.
- `gh run view <id> --log-failed` gives the exact `is at <sha>` / `expected <sha>` pair to prove which sibling job won.

**Fix — serialize the jobs. This repo uses a `needs:` chain** (the implemented solution in
`upstream-bump.yml`): each `bump-*` job declares `needs: <previous bump job>` plus `if: always()`,
so exactly one job runs at a time and one add-on's failure does not skip the rest.

```yaml
bump-<second-addon>:
  needs: bump-<first-addon>
  if: always()          # without this, a failed predecessor skips every later bump
```

Alternative if you need the jobs to stay parallel (they run concurrently but queue at the push):
job-level `concurrency: {group: upstream-bump-push, cancel-in-progress: false}` on each job — a
workflow-level group only scopes whole runs and does NOT prevent this race. Either way, make the
push step tolerant of an overlap: `git pull --rebase origin main` before `git push`.

**Rule:** any workflow with N jobs that independently commit+push to the same branch must serialize
them; a red run nobody reads is not a working autobump. When an add-on looks stale, inspect the
workflow's recent runs before assuming the upstream tracker or version scheme is wrong.

## 2. Path-filtered `push` triggers fire on Renovate rebases

**Symptom.** A Renovate PR whose diff touches only one add-on (e.g. `addons/personal-app/**`) also runs other add-ons' validate/build workflows — visible as duplicate/irrelevant check names on the PR.

**Mechanism.** Renovate rebases its branch (force-push). GitHub evaluates a `push` trigger's `paths` against everything the branch gained relative to its previous tip, so every file `main` picked up since the branch was first cut counts as "changed" — including add-on folders added to main in the meantime.

**Diagnose — compare the PR's real files with what actually ran:**

```bash
gh pr view <N> --json files,headRefOid
gh run list --workflow=<wf>.yml --limit 30 --json event,headBranch,createdAt,conclusion \
  --jq '.[]|select(.headBranch|startswith("renovate/"))|"\(.createdAt) \(.event) \(.headBranch)"'
```

`event=push` on a `renovate/*` branch while the PR diff matches none of that workflow's `paths` = this bug. Confirm the correlation: the workflows that fired are exactly those whose add-on folders landed on main after the branch's old base.

**Fix — do not path-filter branch pushes.** Scope `push` to the branch where automation lands and let `pull_request` handle validation (its `paths` correctly uses the PR diff):

```yaml
on:
  push:
    branches: [main]
    paths: [...]
  pull_request:
    paths: [...]
```

Same edit removes the duplicate run on every normal PR: with `branches: ["**"]`, both `push` and `pull_request` match, so pre-commit/tests/docker builds execute twice per PR (and every push of a rebase re-burns the runners).

## 3. Identically-named jobs across per-add-on workflows make `gh run list` report the wrong run

**Symptom.** You check CI after a push, see both jobs green, and report the PR as passing — while the
add-on you actually changed was red.

**Mechanism.** Every per-add-on workflow here uses the SAME job names (`validate`,
`build-and-smoke`), and one push can trigger several workflows (their `paths:` overlap on shared
files like `upstream-bump.yml`). `gh run list --branch <b> --limit 1` returns whichever run GitHub
ordered first — easily a *sibling* add-on's green run rather than the one under test.

**Fix — scope the query, then verify by SHA:**

```bash
# scope by workflow, not by branch alone
gh run list --workflow "<exact workflow name>" --branch <branch>
# or: check EVERY run for the commit you pushed (push + pull_request create two)
gh run list --branch <branch> --json databaseId,workflowName,headSha,conclusion \
  --jq '.[] | select(.headSha=="<sha>")'
```

**Pull a failing step's log from the JOB, not the run.** `gh run view <id> --log-failed` only echoes
the container's own output and `--log` can come back empty. The reliable path:

```bash
gh api repos/<owner>/<repo>/actions/runs/<run_id>/jobs \
  --jq '.jobs[] | "\(.id) \(.name) \(.conclusion)"'
gh api repos/<owner>/<repo>/actions/jobs/<job_id>/logs --allow-escape-sequences
```

(plain `gh api` refuses the logs endpoint: "the response contains terminal escape sequences"). Grep
that output for the smoke test's own `echo` markers to learn WHICH assertion failed, instead of
reading startup spew.

**Rule:** never report a check as green from a run you did not match to your own commit SHA and
workflow — a false green on a PR page is worse than saying "still running".
