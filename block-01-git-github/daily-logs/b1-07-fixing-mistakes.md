# Fixing Mistakes — git restore, git reset, git revert, git reflog

**Block:** Block 1 — Git & GitHub 
**Topic:** Fixing mistakes — git restore, git reset, git revert, git reflog 
**Filename:** `b1-07-fixing-mistakes.md`
**Path:** `block-01-git-github/daily-logs/b1-07-fixing-mistakes.md`

---

## The Big Picture

How bad a Git mistake is depends on one thing: how far did it get before you caught it? Git has a different tool for each stage of damage. Knowing which one to reach for — and when not to reach for the nuclear option — is what separates someone who panics from someone who fixes it in 30 seconds.

Four stages, four tools:

- Working directory (unstaged) → `git restore`
- Staged → `git restore --staged`
- Committed, not pushed → `git reset`
- Committed and pushed → `git revert`
- Think you've lost everything → `git reflog`

---

## Learning by Doing

### Drill 1 — Discard working directory changes

**What I ran:**

```bash
echo "bad change" >> readme.txt
cat readme.txt
git restore readme.txt
cat readme.txt
```

**What I learned:** `git restore` discards unstaged changes in the working directory and restores the file to its last committed state. The change is gone permanently — Git never tracked it so there's nothing to recover from. Only use it when you're certain you don't need what you're throwing away.

---

### Drill 2 — Unstage a file

**What I ran:**

```bash
echo "staged by mistake" >> readme.txt
git add readme.txt
git status
git restore --staged readme.txt
git status
cat readme.txt
```

**What I learned:** `git restore --staged` moves the file back out of the staging area into the working directory. The change is preserved — it just moves back a zone. Two steps if you want it fully gone: `--staged` first to unstage, then `git restore` to discard the working directory change.

Drill 1 discarded the change entirely. Drill 2 only moved it back a zone. Different tools, different outcomes, same file.

---

### Drill 3 — Reset a bad commit (not pushed)

**What I ran:**

```bash
echo "bad commit content" >> readme.txt
git add readme.txt
git commit -m "mistake: bad commit"
git log --oneline
git reset --soft HEAD~1
git log --oneline
git status
```

**What I learned:** `--soft` moves HEAD back one commit but leaves changes staged. The commit disappears from history but the work is preserved and ready to recommit. Use it when you committed too early or with the wrong message.

Three reset modes:

- `--soft` — HEAD moves back, changes stay staged
- `--mixed` — HEAD moves back, changes unstaged but in working directory (default)
- `--hard` — HEAD moves back, changes wiped entirely. Unrecoverable without reflog.

---

### Drill 4 — Revert a pushed commit safely

**What I ran:**

```bash
git revert 42418f9 --no-edit
git log --oneline
```

**Output:**

```
050aba1 (HEAD -> main) Revert "lab: bracnhing and adding line in readme"
42418f9 (origin/main) lab: bracnhing and adding line in readme
```

**What I learned:** `git revert` creates a new commit that undoes a previous one — it doesn't rewrite history. The original commit stays, the revert sits on top. Safe for shared branches because everyone who pulls gets the revert cleanly. No force push required.

`git reset` rewrites history — if someone already pulled the commit, their history and yours are now different. Force push required, conflicts possible. Rule: not pushed → `git reset` is fine. Already pushed → `git revert` is the safe move.

---

### Drill 5 — Reflog rescue

**What I ran:**

```bash
git reset --hard HEAD~1
git log --oneline
git reflog
git checkout 050aba1
git log --oneline
git switch main
```

**What I learned:** `git log` only shows commits in the current branch history. `git reflog` shows every HEAD movement Git has ever recorded — resets, merges, checkouts, branch renames, everything. It's the black box recorder.

After `--hard` reset the revert commit `050aba1` was invisible to `git log` but still visible in reflog at `HEAD@{1}`. Checked it out, confirmed it was there, switched back to main.

Detached HEAD isn't a crisis — HEAD is pointing at a commit directly instead of a branch. `git switch main` gets you back. `git branch <name> <hash>` saves the work permanently if needed.

---

## Putting It Together: The Lab

**Four deliberate scenarios, fixed with the right tool each time.**

### Scenario 1 — Working directory mistake

```bash
echo "bad line for lab test" >> readme.txt
tail -2 readme.txt       # bad line visible
git restore readme.txt
tail -2 readme.txt       # bad line gone
```

**Tool used:** `git restore` — change was unstaged, working directory only. Discarded cleanly. No recovery possible after this, which was the intent.

---

### Scenario 2 — Staged mistake

```bash
echo "bad line for lab test" >> readme.txt
git add readme.txt
git restore --staged readme.txt   # unstage first
git restore readme.txt            # then discard
tail -2 readme.txt                # clean
```

**Tool used:** `git restore --staged` then `git restore` — two steps because the change had crossed into the staging area. Unstage first, discard second.

---

### Scenario 3 — Committed but not pushed

```bash
echo "bad commit - lab test" >> app.log
git add app.log
git commit -m "lab: bad commit to app log"
git reset --soft HEAD~1
git status                        # changes still staged
git commit -m "lab: fixed commit to app log"
```

**Tool used:** `git reset --soft` — commit not pushed yet, wanted to keep changes staged for recommit with corrected message. `--soft` preserved the work exactly where it needed to be.

---

### Scenario 4 — Reflog recovery

```bash
echo "important change to log" >> app.log
git add app.log
git commit -m "lab: a good commit indeed"   # hash: 232af2c
git reset --hard HEAD~1                     # wiped it
git log --oneline                           # 232af2c gone
git reflog                                  # 232af2c at HEAD@{1}
git branch recovery 232af2c                 # attach branch to lost commit
git switch recovery
git log --oneline                           # 232af2c recovered
```

**Tool used:** `git reflog` to find the hash, `git branch` on the hash to recover. The commit was invisible to `git log` but reflog had it. Branched on it directly — no data lost.

---

## What Stuck With Me

- **Four stages, four tools.** Working directory → `git restore`. Staged → `git restore --staged`. Committed not pushed → `git reset`. Pushed → `git revert`. Know the stage, pick the tool.
- **`--soft` keeps staged. `--mixed` unstages. `--hard` wipes.** Know which mode before you run it — especially `--hard`.
- **`git revert` is history-safe.** Always use it on pushed commits. Never `git reset` on shared history.
- **`git reflog` is the black box.** Every HEAD movement recorded. Your last resort when you think work is lost.
- **`git restore` is permanent.** No staging, no reflog, no undo. Use it only when you're certain.

---

## Tips from the Session

- Before any `git reset --hard`, run `git reflog` first so you have the hash if you need it back. Two seconds of caution, potentially hours of recovery avoided.
- Detached HEAD isn't a crisis. HEAD is just pointing at a commit instead of a branch. `git switch main` gets you back. `git branch <name> <hash>` saves it if you need it.

---

> Carry Forward: None — all four recovery tools clear. Reflog rescue workflow locked in.