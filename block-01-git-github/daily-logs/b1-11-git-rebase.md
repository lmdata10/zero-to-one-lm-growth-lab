# git rebase — When and Why

**Block:** Block 1 — Git & GitHub 
**Topic:** git rebase — when and why 
**Filename:** `b1-11-git-rebase.md` 
**Path:** `block-01-git-github/daily-logs/b1-11-git-rebase.md`

---

## The Big Picture

Rebase and merge both integrate changes from one branch into another. The difference is what the history looks like afterward. Merge preserves the full honest record — when branches diverged, when they came back together. Rebase rewrites history to look linear — as if you always branched from the latest version. Neither is wrong. Context determines which to reach for.

> Golden rule: rebase locally before you push. Merge to integrate into shared branches. Never rebase commits already pushed to a shared branch.

---

## Learning by Doing

### Drill 1 — Set up divergence to rebase

**What I ran:**

```bash
cd ~/zero-to-one/git-lab
git switch main
git pull
echo "main moved forward" >> app.log
git add app.log
git commit -m "chore(main): simulate main moving forward"
git switch -c feature/rebase-demo HEAD~1
echo "feature work" >> feature-rebase.txt
git add feature-rebase.txt
git commit -m "feat(rebase-demo): add feature file"
git log --oneline --graph --all
```

**Output:**

```
* c048d9a (HEAD -> feature/rebase-demo) feat(rebase-demo): add feature file
| * e85d392 (main) chore(main): simulate main moving forward
|/
* 0b7b650 (origin/main) merge: reconcile local and remote divergence
```

**What I learned:** Feature branch created from `HEAD~1` — one commit behind main's tip. Main moved forward independently. Two diverging lines from the same ancestor. This is the exact scenario rebase is built for — feature needs to catch up to main before merging.

---

### Drill 2 — Rebase feature onto main

**What I ran:**

```bash
git rebase main
git log --oneline --graph --all
```

**Output:**

```
* 2896620 (HEAD -> feature/rebase-demo) feat(rebase-demo): add feature file
* e85d392 (main) chore(main): simulate main moving forward
* 0b7b650 (origin/main) merge: reconcile local and remote divergence
```

**What I learned:** Feature commit hash changed from `c048d9a` to `2896620` because rebase replays commits — same changes, new commit objects, new hashes. The originals are gone. History is now linear — feature sits directly on top of main's tip as if it always branched from there.

`git rebase main` run while ON `feature/rebase-demo` means: replay my feature commits on top of main. Main never moves. Only the feature branch gets rewritten. This is correct — always rebase the branch that needs to catch up, onto the branch that's ahead.

---

### Drill 3 — Merge after rebase, observe fast-forward

**What I ran:**

```bash
git switch main
git merge feature/rebase-demo
git log --oneline --graph
```

**What I learned:** Merged as Fast-forward — no merge commit, pointer just moved forward. Rebase made feature a direct descendant of main's tip so there was no divergence to reconcile. Compare to Topic 10 where merging without rebasing first produced a merge commit because the branches had genuinely diverged. Rebase + merge = clean linear history with no merge commit noise.

---

### Drill 4 — Rebase conflict resolution

**What I ran:**

```bash
git switch -c feature/conflict-rebase
echo "conflicting line from feature" >> readme.txt
git add readme.txt
git commit -m "feat(test): add conflicting line from feature"

git switch main
echo "conflicting line from main" >> readme.txt
git add readme.txt
git commit -m "chore(main): add conflicting line to main"

git switch feature/conflict-rebase
git rebase main
# CONFLICT — readme.txt
```

**Resolution:**

```bash
# Edit readme.txt in VS Code — remove markers, keep both lines
git add readme.txt
git rebase --continue
```

**What I learned:** Rebase conflict resolution follows the same process as merge conflict resolution — edit the file, remove markers, keep what you want, stage. The difference is the final step:

- Merge conflict: `git add` → `git commit`
- Rebase conflict: `git add` → `git rebase --continue`

No commit command — rebase is replaying commits one by one. `--continue` tells it to move to the next commit in the replay sequence. Multiple commits being replayed can mean multiple conflicts, one per commit.

**Three rebase options:**

- `--continue` — conflict resolved, keep going. Default 95% of the time.
- `--skip` — skip this commit entirely. Use only when the change already exists in the target branch — duplicate change. Rare.
- `--abort` — abandon the entire rebase, return to pre-rebase state. Always safe. Use when conflicts are too complex or you need to reassess.

**Mistake noted:** Commit message during `--continue` was messy — `reabse: resolve readme conflixt...` — typo and two messages concatenated. When rebase opens the editor during `--continue` you can and should edit the message. In a real repo that's permanent history noise.

---

### Drill 5 — Merge rebased branch, clean up, push

**What I ran:**

```bash
git switch main
git merge feature/conflict-rebase
git branch -d feature/rebase-demo
git branch -d feature/conflict-rebase
git push
git log --oneline --graph
```

**Output (top of graph):**

```
* 3b97c1c (HEAD -> main, origin/main) rebase: resolve conflict
* ee48cda chore(main): add conflicting line to main
* 2896620 feat(rebase-demo): add feature file
* e85d392 chore(main): simulate main moving forward
```

**What I learned:** Top four commits are linear — result of rebase before merging. Everything below `0b7b650` has branching lines from Topic 10's merge commits. Two different approaches producing two different looking histories in the same repo.

---

## Putting It Together: Rebase vs Merge

**Use merge when:**

- You want the honest record — when branches diverged, when they rejoined.
- Merging into shared branches like `main` — merge commits are auditable.
- Long-lived feature branches where the full history matters.

**Use rebase when:**

- You want clean linear history before opening a pull request.
- Catching up a local feature branch to main before merging.
- Cleaning up messy local commits before they hit the shared repo.

**The practical rule most teams follow:** Rebase locally before you push. Merge to integrate into shared branches. Never rebase after pushing to a shared branch.

---

## What Stuck With Me

- **Rebase replays, merge reconciles.** Rebase rewrites commits with new hashes. Merge creates a new commit with two parents. Same end result, different history shape.
- **Golden rule: never rebase pushed commits.** Rewrites history, breaks everyone else's local copy. Force push required, conflicts guaranteed.
- **Rebase conflict resolution uses `--continue`, not `git commit`.** Stage the resolved file, then continue the replay sequence.
- **`--abort` is always safe.** When in doubt, abort and merge instead. Merge is always the safe fallback.
- **Rebase before merge = fast-forward.** Linear history, no merge commit noise. The professional pull request workflow.

---

## Tips from the Session

- Fix the commit message when rebase opens the editor during `--continue`. It's your last chance before it becomes permanent history.
- If a rebase feels complicated — `--abort` and merge instead. Merge is never wrong. Rebase is an optimization, not a requirement.

---

> Carry Forward: None — rebase mental model clear, conflict resolution clear, rebase vs merge decision framework clear. Block 1 complete.