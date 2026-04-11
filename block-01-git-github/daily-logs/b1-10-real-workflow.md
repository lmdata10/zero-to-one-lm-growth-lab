# Real Workflow — Feature Branch → Commit → Push → Merge

**Block:** Block 1 — Git & GitHub
**Topic:** Real workflow — feature branch → commit → push → merge
**Filename:** `b1-10-real-workflow.md`
**Path:** `block-01-git-github/daily-logs/b1-10-real-workflow.md`

---

## The Big Picture

Everything in Block 1 up to this point was individual tools. This session was the first time all of them were used together in a sequence that mirrors real team workflow. A task comes in, you branch, you work, you push, conflicts get resolved, history gets merged. That cycle repeats hundreds of times over a career.

Two things that only become visible with multiple branches: what a real merge commit looks like in the graph, and what happens when local and remote diverge because someone edited in two places without pulling first.

---

## Learning by Doing

### Drill 1 — Create two branches simultaneously, observe shared pointer

**What I ran:**
```bash
cd ~/zero-to-one/git-lab
git branch feature/add-block2-readme
git branch hotfix/fix-readme-typo
git branch
git log --oneline -3
```

**Output:**

```
8fcf4d5 (HEAD -> main, hotfix/fix-readme-typo, feature/add-block2-readme)
lab: fixed commit to app log
```

**What I learned:** All three branches pointing at the same commit. Creating branches doesn't copy anything — just adds pointers. Divergence only happens once commits are made on individual branches. History is shared until that point.

---

### Drill 2 — Commit independently on each branch, observe divergence

**What I ran:**

```bash
git switch feature/add-block2-readme
echo "# Block 2 - Linux CLI Foundations" >> block2-readme.md
echo "Coming soon" >> block2-readme.md
git add block2-readme.md
git commit -m "feat(block2): add block 2 readme placeholder"

git switch hotfix/fix-readme-typo
echo "hotfix: corrected readme typo" >> readme.txt
git add readme.txt
git commit -m "fix(readme): correct typo in readme"

git log --oneline --graph --all
```

**Output:**

```
* bf24478 (HEAD -> hotfix/fix-readme-typo) fix(readme): correct typo in readme
| * 8384169 (feature/add-block2-readme) feat(block2): add block 2 readme placeholder
|/
* 8fcf4d5 (main) lab: fixed commit to app log
```

**What I learned:** Two branches, two independent commits, one common ancestor. The graph shows the split — two lines diverging from `8fcf4d5`. `main` hasn't moved yet. `--all` is required to see all branches — without it you only see history reachable from current branch.

---

### Drill 3 — Merge both branches into main, observe fast-forward vs merge commit

**What I ran:**

```bash
git switch main
git merge hotfix/fix-readme-typo      # fast-forward
git log --oneline --graph --all
git merge feature/add-block2-readme   # real merge commit
git log --oneline --graph --all
```

**Output after both merges:**

```
*   19b4753 (HEAD -> main) merge: Merge branch 'feature/add-block2-readme'
|\
| * 8384169 (feature/add-block2-readme) feat(block2): add block 2 readme
* | bf24478 (hotfix/fix-readme-typo) fix(readme): correct typo in readme
|/
* 8fcf4d5 lab: fixed commit to app log
```

**What I learned:** Hotfix merged as Fast-forward — `main` was directly behind it, no divergence, pointer just moved forward. No merge commit, graph stayed linear.

Feature merge created a real merge commit — by the time feature was merged, `main` had already moved to `bf24478` via the hotfix. Feature branched from `8fcf4d5` which was now behind `main`. Two diverging histories required reconciliation. Merge commit `19b4753` has two parents.

The `|\` split and `|/` rejoin in the graph shows exactly where the branches diverged and where they came back together.

---

### Drill 4 — Create a conflict and resolve it

**What I ran:**

```bash
git switch -c conflict-test
echo "line from conflict branch" >> readme.txt
git add readme.txt
git commit -m "feat(test): add line from conflict branch"

git switch main
echo "line from main" >> readme.txt
git add readme.txt
git commit -m "feat(main): add line from main"

git merge conflict-test
```

**Output:**

```
CONFLICT (content): Merge conflict in readme.txt
Automatic merge failed; fix conflicts and then commit the result.
```

**Conflict markers in file:**

```
<<<<<<< HEAD
line from main
=======
line from conflict branch
>>>>>>> conflict-test
```

**Resolution:** Opened in VS Code, kept both lines, removed conflict markers.

```bash
git add readme.txt
git commit -m "merge(conflict-test): resolve readme conflict keep both lines"
```

**What I learned:** Conflicts happen when two branches change the same lines. Git stops and inserts markers — `<<<<<<<` is your version, `>>>>>>>` is the incoming version, `=======` is the divider. You edit the file to what you actually want, remove all markers, stage, commit. Always resolve from the branch you're merging INTO — you stay on `main` throughout.

---

### Drill 5 — Push rejected, local and remote diverged, reconcile

**What I ran:**

```bash
git push
# rejected — remote had a commit made directly on GitHub
git pull --no-rebase
# conflict again — same file edited in both places
# resolved conflict, staged, committed
git commit -m "merge: reconcile local and remote divergence"
git push
git log --oneline --graph
```

**What I learned:** Push rejected because remote had work local didn't have — a commit made directly on GitHub without pulling first. Local and remote had diverged. `git pull --no-rebase` fetched the remote commit and attempted a merge — triggered another conflict because the same file had changed in both places. Resolved, committed, pushed cleanly.

The final graph showed three separate merge commits and multiple diverging lines — an accurate picture of everything that actually happened.

Root cause: never edit files directly on GitHub if you're also working locally on the same branch. Always `git pull` before starting work.

**Global config set:**

```bash
git config --global pull.rebase false
```

Merge is now the default pull behavior. No more prompt asking how to reconcile.

---

## Putting It Together: The Lab

**Task:** Read and annotate the final graph — explain every commit and merge from `42418f9` to `0b7b650` in plain English as if explaining to a teammate.

**My annotation:**

```
*   0b7b650 — merge commit: pulled and merged remote with local (divergence reconciled)
|\
| * 105e4b9 — commit made directly on GitHub remote, not local
* |   555b877 — merge commit: conflict between conflict-test and main resolved
|\ \
| * | 19c8483 — commit on conflict-test branch
* | | 36218eb — commit on main during conflict drill
|/ /
* |   19b4753 — merge commit: feature/add-block2-readme merged into main
|\ \
| * | 8384169 — commit on feature branch
* | | bf24478 — commit on hotfix branch (fast-forwarded into main first)
|/ /
* / 8fcf4d5 — common ancestor where both feature and hotfix branched from
|/
* 42418f9 — last commit shared by local and remote before divergence
```

**Key distinction:** `42418f9` is the common ancestor where local and remote diverged — not `8fcf4d5`. The remote line (`105e4b9`) branches from `42418f9` because that was the last commit both shared before GitHub and local went separate ways.

---

## What Stuck With Me

- **Fast-forward vs real merge commit.** Fast-forward = no divergence, pointer moves, graph stays linear. Real merge = two histories reconciled, two-parent commit created, graph shows the split and rejoin.
- **`--all` shows everything.** Without it you only see history reachable from current branch. With it you see every local and remote branch at once.
- **Conflicts are not a crisis.** Git stops, marks the file, you decide, stage, commit. Resolve from the branch you're merging into. Stay calm.
- **Never edit on GitHub and locally simultaneously.** Pick one or always pull first. Divergence creates extra reconciliation work and messy history.
- **`git pull` before starting work.** Always. Non-negotiable on shared repos.

---

## Tips from the Session

- When a push is rejected the answer is always `git pull` first — never force push on a shared branch. Force push rewrites remote history and breaks everyone else's local copy.
- Set `git config --global pull.rebase false` once and never see the reconciliation prompt again. Merge is the honest default.

---

> Carry Forward
> - `git rebase` — Topic 11, final topic of Block 1
> - Pull request workflow on GitHub — covered in Topic 11 as part of rebase and the professional merge workflow