
# The Core Loop — git add, git commit

**Block:** Block 1 — Git & GitHub
**Topic:** The core loop — git init, git add, git commit
**Filename:** `b1-02-core-loop.md`
**Path:** `block-01-git-github/logs/b1-02-core-loop.md`

---

## The Big Picture

The staging area exists because you need control over what goes into each snapshot. You might have 10 files changed but only want 3 in this commit. `git add` is you selecting what to include. `git commit` is you locking the snapshot. Nothing moves without you explicitly telling Git to move it.

The default instinct of `git add .` is wrong. Stage specifically. Every time.

---

## Learning by Doing

### Drill 1 — Commit without staging

**What I ran:**
```bash
cd ~/git-lab
echo "testing commit flow" >> readme.txt
git commit -m "test: skipping add"
````

**Output:**

```
On branch master
Changes not staged for commit:
	modified: readme.txt
Untracked files:
	ops-lab/
no changes added to commit (use "git add" and/or "git commit -a")
```

**What I learned:** Git refuses to commit anything that hasn't been staged. The change exists in the working directory but never crossed into the staging area — nothing to snapshot.

---

### Drill 2 — Stage specifically, inspect before committing

**What I ran:**

```bash
git add readme.txt
git diff --staged
```

**Output:**

```
diff --git a/readme.txt b/readme.txt
index b2a2cef..f965db8 100644
--- a/readme.txt
+++ b/readme.txt
@@ -1,2 +1,3 @@
 first git repo
 learning git
+testing commit flow
```

**What I learned:** `git diff --staged` shows the diff between the last commit and what's currently staged. The `+` marks added content. This is the last check before committing — you can see exactly what's going into the snapshot before it's permanent. Run this before every commit on real work.

---

### Drill 3 — Commit and inspect with git show

**What I ran:**

```bash
git commit -m "docs: test commit flow note"
git show HEAD
```

**Output:**

```
commit bc22609e36e1f0ba8215208f3387c09bb5dc67f3 (HEAD -> master)
Author: LM-10 <lm-10@email.com>
Date:   Mon Mar 30 20:45:13 2026 -0300
    docs: test commit flow note

diff --git a/readme.txt b/readme.txt
index b2a2cef..f965db8 100644
--- a/readme.txt
+++ b/readme.txt
@@ -1,2 +1,3 @@
 first git repo
 learning git
+testing commit flow
```

**What I learned:** `git log` shows the chain. `git show HEAD` opens the snapshot — hash, author, date, and the actual diff of what changed. Use it when you need to verify exactly what landed in a specific commit.

---

### Drill 4 — Stage two files, commit together, log oneline

**What I ran:**

```bash
echo "command notes" >> commands.txt
echo "general notes" >> notes.txt
git add commands.txt notes.txt
git status
git commit -m "docs: add command and general notes"
git log --oneline
```

**Output:**

```
5bf2374 (HEAD -> master) docs: add command and general notes
8477061 lab: tracking lab files
```

**What I learned:** `--oneline` condenses the log to hash and message only. Go-to view when orienting on a repo or looking for a specific commit to reference. Shortened hashes are accepted by Git as long as they're unambiguous.

---

### Drill 5 — Stage then unstage

**What I ran:**

```bash
echo "scratch notes" >> scratch.txt
git add scratch.txt
git status
git restore --staged scratch.txt
git status
```

**Output:**

```
# After git add:
On branch master
Changes to be committed:
	new file: scratch.txt

# After git restore --staged:
On branch master
Untracked files:
	scratch.txt
nothing added to commit but untracked files present
```

**What I learned:** `git restore --staged` pulls a file back out of staging without touching the file itself. Real use case: accidentally staging a file with credentials or sensitive config before it hits the permanent history.

---

## Putting It Together: The Lab

**Task:** Create runbook-lab, init as Git repo, create four files with content, stage and commit two together, stage a third then unstage it, verify two files remain untracked, check log with --oneline.

**What I did:**

```bash
mkdir runbook-lab && cd runbook-lab
git init
touch runbook.md checklist.md draft.md temp.txt
echo "Runbook file" >> runbook.md
echo "Checklist file" >> checklist.md
echo "draft file" >> draft.md
echo "temp file" >> temp.txt
git add runbook.md checklist.md
git status
git add draft.md
git restore --staged draft.md  # failed — no HEAD yet
git rm --cached draft.md       # correct fix with no HEAD present
git commit -m "lab: committing two files together"
git add draft.md
git restore --staged draft.md  # worked correctly this time
git status
git log --oneline
```

**Outcome:** Both commits landed. draft.md and temp.txt confirmed untracked.

**Errors hit:** `git restore --staged` failed on first attempt with `fatal: could not resolve 'HEAD'` — no HEAD existed yet because the first commit hadn't been made. Git needs a reference point to restore to.

**How I fixed it:** Used `git rm --cached draft.md` instead. This removes a file from staging without touching the working directory — works even with no HEAD. Made the first commit, then repeated the restore drill successfully.

**Key distinction learned:**

- `git rm --cached <file>` — unstage when no HEAD exists yet
- `git restore --staged <file>` — unstage when HEAD exists Same outcome, different tool depending on repo state.

---

## What Stuck With Me

- **Stage intentionally, not lazily.** `git add .` will eventually include something you didn't mean to commit. Stage by name.
- **`git diff --staged` is your pre-commit review.** See exactly what's going into the snapshot before it's permanent.
- **`git show HEAD` opens the snapshot.** `git log` shows the chain. Different tools for different questions.
- **`git restore --staged` needs HEAD.** No commits yet means use `git rm --cached` instead.
- **Commit messages are permanent documentation.** Write them for the person debugging at 2am — that person might be you.

---

## Tips from the Session

- Follow every `git add` with `git status` before committing. Typos in filenames fail silently — Git won't warn you.
- Clean commit history isn't about aesthetics. When something breaks in production, meaningful commit messages let you find the cause in minutes. Messy history turns that into hours.

---

## Carry Forward

None — the HEAD/restore edge case came up and got resolved cleanly.