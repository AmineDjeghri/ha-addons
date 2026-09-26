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

**Fix — serialize the push, both layers:**

```yaml
# add to EACH bump-* job (job-level concurrency queues jobs; a workflow-level
# group only scopes whole runs, so it does not prevent this race)
concurrency:
  group: upstream-bump-push
  cancel-in-progress: false
```

plus, in each push step: `git pull --rebase origin main && git push` (covers the case where two runs overlap).

**Rule:** any workflow with N jobs that independently commit+push to the same branch must serialize them; a red run that nobody reads is not a working autobump. When an add-on looks stale, inspect the workflow's recent runs before assuming the upstream tracker or version scheme is wrong.

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
