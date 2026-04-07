# Branching — git branch, git switch, git merge

**Block:** Block 1 — Git & GitHub
**Topic:** Branching — git branch, git switch, git merge
**Filename:** `b1-06-branching.md`
**Path:** `block-01-git-github/daily-logs/b1-06-branching.md`

---

## The Big Picture

A branch is just a pointer to a commit — not a copy of files. Creating one is cheap and instant because Git isn't duplicating anything. `main` is your production line. A branch is your safe workspace. You do the work, test it, merge it back, delete the branch. The commit history is what carries forward — not the branch label.

Fast-forward merge is the simple case: no diverging commits, Git just moves the pointer forward. A real merge commit happens when both branches have moved independently and Git has to reconcile them. You'll see that in Topic 10.

---

## Learning by Doing

### Drill 1 — Create a branch and observe pointers

**What I ran:**
```bash
cd ~/zero-to-one/git-lab
git branch
git branch feature-test
git branch
git log --oneline
````

**Output:**

```
* main
  feature-test
* main
c19ff2d (HEAD -> main, origin/main, feature-test) docs: remote drill note
```

**What I learned:** Creating a branch doesn't copy files — it creates a new pointer at the exact same commit. `main` and `feature-test` both point to `102cd27`. They only diverge once you commit on one of them. HEAD is still on `main` — switching branches moves HEAD, not creating one.

---

### Drill 2 — Switch to branch and commit

**What I ran:**

```bash
git switch feature-test
echo "feature work" >> feature.txt
git add feature.txt
git commit -m "feat: add feature test file"
git log --oneline
```

**Output:**

```
c19ff2d (HEAD -> feature-test) feat: add feature test file
102cd27 (origin/main, main) docs: remote drill note
```

**What I learned:** HEAD moved to `feature-test`. `main` stayed at `102cd27`. `feature-test` is now one commit ahead. Two pointers, now at different commits — that's divergence. `origin/main` hasn't moved because nothing was pushed.

---

### Drill 3 — Switch back to main, observe file state

**What I ran:**

```bash
git switch main
ls
cat readme.txt
```

**What I learned:** `feature.txt` disappeared from the working directory when switching back to `main`. Git restored the project state to match the `main` snapshot. The file isn't gone — it's on `feature-test`. Switch back and it reappears. Git is swapping your working directory to match whichever branch you're on.

---

### Drill 4 — Merge feature branch into main

**What I ran:**

```bash
git merge feature-test
git log --oneline
ls
```

**Output:**

```
Updating 102cd27..c19ff2d
Fast-forward
 feature.txt | 1 +
 1 file changed, 1 insertion(+)

c19ff2d (HEAD -> main, feature-test) feat: add feature test file
102cd27 (origin/main) docs: remote drill note
```

**What I learned:** Fast-forward means `main` was directly behind `feature-test` with no diverging commits. Git didn't create a merge commit — it just moved the `main` pointer forward to where `feature-test` already was. Both pointers now point at the same commit. `feature.txt` is now in `main`.

Fast-forward is not about how many files changed. It's about whether the branches diverged. No divergence = Fast-forward.

---

### Drill 5 — Delete branch and push

**What I ran:**

```bash
git branch -d feature-test
git branch
git push
git log --oneline
```

**Output:**

```
Deleted branch feature-test (was c19ff2d).
* main
c19ff2d (HEAD -> main, origin/main) feat: add feature test file
```

**What I learned:** `-d` is safe delete — refuses if the branch isn't fully merged. `-D` is force delete — doesn't check, just deletes regardless of merge status. Always reach for `-d` first. If Git refuses, stop and think before reaching for `-D`.

Deleting the branch removes the pointer label only. The commit still exists — `main` still points to it. A branch was never anything more than a label.

---

## Putting It Together: The Lab

**Task:** Create `fix-readme` branch, add a line to readme.txt, commit, switch back to main and confirm change is gone, merge, confirm change is in main, delete branch, push, run `git log --oneline --graph`.

**What I did:**

```bash
git branch fix-readme
git switch fix-readme
echo "branching lab" >> readme.txt
git add readme.txt
git commit -m "lab: branching and adding line in readme"
git switch main
git log --oneline        # confirmed change not in main
git switch fix-readme
git log --oneline        # confirmed commit on fix-readme
git switch main
git merge fix-readme
git log --oneline
git branch -d fix-readme
git push
git log --oneline --graph
```

**Output (final graph):**

```
* 42418f9 (HEAD -> main, origin/main) lab: branching and adding line in readme
* c19ff2d feat: add feature test file
* 102cd27 docs: remote drill note
...
```

**Outcome:** Full branch workflow complete. Change landed in main after merge. Branch deleted cleanly. Pushed to remote.

**Errors hit:** Ran `git merge feature-test` instead of `git merge fix-readme` — feature-test was already deleted so Git refused. Caught and corrected immediately.

```
merge: feature-test - not something we can merge
```

**How I fixed it:** Ran `git merge fix-readme` with the correct branch name.

**Key distinction learned:** Fast-forward merge = no diverging commits, Git moves the pointer. No merge commit in history, graph stays linear. A real merge commit happens when both branches have moved independently — that's Topic 10.

`--graph` still shows a straight line here because Fast-forward doesn't create a branch visual. It earns its value when there are real merge commits bringing two lines together.

---

## What Stuck With Me

- **A branch is a pointer, not a copy.** Creating one is instant — Git isn't duplicating files, just adding a label to a commit.
- **HEAD is your position marker.** It follows you when you switch branches. Always know where HEAD is before you start work.
- **Fast-forward = pointer move.** Both branches pointed at the same ancestor, no divergence, Git just moves `main` forward. No merge commit.
- **`-d` vs `-D`.** Safe delete vs force delete. Always try `-d` first — if Git refuses, that refusal is useful information.
- **Branches are temporary.** Create, work, merge, delete. Keep main clean.

---

## Tips from the Session

- Always know which branch you're on before you start work. Your shell prompt should show the branch name — if it doesn't, fix that.
- Delete branches after merging. Stale branches are noise. A repo littered with old branches is a repo nobody wants to navigate.

---

## Carry Forward

- Real merge commit with diverging branches — Topic 10
- `--graph` will make more sense when there are actual branch lines to draw
- `git rebase` — added as Topic 11 at end of Block 1
- `git reflog` — added to Topic 7 alongside recovery commands