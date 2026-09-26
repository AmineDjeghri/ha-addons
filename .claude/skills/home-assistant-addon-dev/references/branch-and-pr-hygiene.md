# Branch & PR hygiene (this user's repos: ha-addons, personal-os-setup)

Two procedures that cost real damage when improvised. Both are approval-gated: never commit,
push, delete a branch, or edit a PR without an explicit per-action yes.

## 1. Stale-branch sweep ("clean up the old branches")

Classify by **PR state, never by ancestry**. A squash-merge leaves the branch tip as its own
commit, so `git branch --merged origin/main` and `git merge-base --is-ancestor` both report
squash-merged branches as "unmerged".

```bash
git fetch --prune origin
# local branches: name | last commit | upstream, with [gone] when the remote is deleted
git for-each-ref --sort=-committerdate refs/heads \
  --format='%(refname:short)|%(committerdate:short)|%(upstream:short)%(upstream:track)'
# remote branches the default branch does not contain
git branch -r --no-merged origin/main
# the authority: branch -> PR -> state
gh pr list --state all --limit 100 --json number,state,headRefName \
  -q '.[]|"\(.headRefName)|#\(.number)|\(.state)"' | sort
```

Rules:
- **Subtract the OPEN-PR branches from the delete list before removing anything.** A naive
  "everything except `main`" filter deletes the working branch of a live PR (`grep -vE
  '^(main|backup/)'` did exactly that). The remote copy and GitHub's `refs/pull/<N>/head`
  survive, so recovery is `git checkout -b <b> origin/<b>` — but the sweep is wrong and he
  notices.
- `%(upstream:track)` = `[gone]` means the remote branch is already deleted → the local copy
  is an orphan and always safe to drop.
- **Recoverability ladder:** any branch whose PR exists (merged *or* closed) stays fetchable
  from its PR ref, so deleting it loses nothing. A branch with **no PR at all** is the only
  unrecoverable case → `git branch backup/<name> origin/<name>` first, and name those branches
  when proposing the sweep.
- **Batch the whole sweep into ONE command.** Every `git branch -D` and `git push origin
  --delete` raises its own approval prompt and prompts time out (~1 min): one command = one
  approval. Re-fire the identical command only when he says "prompt me again"; never rephrase
  it into a variant. Keep a push of NEW work in a separate command from deletions.
- Keep publishing branches (`gh-pages`) and branches of dependency PRs still open
  (`renovate/*`, `dependabot/*`).
- Verify after: re-list local + remote branches and re-check every open PR's head
  (`gh pr view <n> --json headRefOid`) to prove nothing live moved.
- Fast-forwarding local `main` is part of the same pass (`git checkout main && git pull
  --ff-only origin main`); a sweep that leaves main behind is half done.

## 2. PR-tightening pass ("what did you update / which can be reduced")

Audit before editing anything:

```bash
gh pr view <n> --json title,body,commits,files   # what the PR CLAIMS
git diff --stat origin/main...HEAD               # what it actually changes
gh pr view <n> --json commits -q '.commits[]|"\(.oid[0:7]) \(.messageHeadline)"'
```

Reduce in this order:
1. **Stale body first.** A body that names a target deleted mid-PR, or says something is "NOT
   included" that later commits added, is a REWRITE, not a trim. Verify with
   `gh pr view <n> --json body -q .body | grep -c '<stale-token>'` → expect 0 after the fix.
2. **Mixed topics.** Group the commits into logical topics; name them and ask whether to
   consolidate into this PR or move one out. He consolidates and closes the redundant PR
   rather than keeping two open (= one file in two PRs makes the second merge a 0-diff no-op).
3. **Duplicated prose.** The same explanation in a build/makefile header comment AND the doc,
   or one section repeated twice: keep it in ONE place (the doc) and leave a pointer. Report
   each cut as `file: <before> → <after>` lines with re-verified numbers — he counts lines.
4. Approval before pushing the trim, with the body rewrite under the SAME approval
   (`gh pr edit <n> --body …`): the two go together.
5. Before adding a NEW doc, check where it publishes (docs-site `docs_dir` + `exclude` glob):
   anything under a published tree goes public on the next deploy, and a fresh `docs/<area>/`
   is usually NOT excluded while the root `AGENTS.md`/`CLAUDE.md` are — internal process docs
   belong in an excluded path.
