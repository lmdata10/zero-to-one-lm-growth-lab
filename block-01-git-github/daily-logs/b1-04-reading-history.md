# Reading History — `git log`, `git diff`, `git show`

**Block:** Block 1 — Git & GitHub
**Topic:** git log, git diff, git show — reading history
**Filename:** `b1-04-reading-history.md`
**Path:** `block-01-git-github/logs/b1-04-reading-history.md`

---

## The Big Picture

These three tools are your investigation kit. Something broke in production — you need to answer three questions fast: what's the commit chain, what changed between two points in time, and what's inside a specific commit. 
`git log`, `git diff`, and `git show` answer those questions in that order.

Investigation workflow: orient → scope → isolate. Broad first, then narrow.

---

## Learning by Doing

### Drill 1 — Build history to work with

**What I ran:**
```bash
cd ~/git-lab
echo "version 1" >> app.log && git add app.log && git commit -m "logs: add app log v1"
echo "version 2" >> app.log && git add app.log && git commit -m "logs: update app log v2"
echo "version 3" >> app.log && git add app.log && git commit -m "logs: update app log v3"
git log --oneline
```

**Output:**
```
186efb8 (HEAD -> master) logs: add app log v3
cd8e5cc logs: add app log v2
3d21449 logs: add app log v1
4ffbc06 chore: remove secret key from tracking
38f59ae chore: accidentally commit a secret
4f0ea33 chore: add gitignore for secrets and temp files
bc22609 docs: tets commit flow note
ca921d8 docs: update readme with learning note
5ed3f7a init: add readme
```

**What I learned:** Nine commits, clean chain. Good baseline to run
investigation commands against.

---

### Drill 2 — Read the log with flags

**What I ran:**
```bash
git log --oneline --graph
git log --since="1 hour ago"
git log --oneline --author="LM-10"
```

**What I learned:** 
- `--graph` adds visual branch/merge lines — not useful on a linear branch but essential once branching starts. 
- `--since` narrows by time window 
  - ops use case: something broke at 14:00, run `git log --since="2 hours ago"` to see every commit in the incident window
- Flags compose `--oneline` combined with `--author` gives a clean filtered view without noise.

---

### Drill 3 — git diff across states

**What I ran:**
```bash
echo "debug line" >> app.log
git diff
git add app.log
git diff
git diff --staged
```

**What I learned:** 
- `git diff` compares working directory against staging area.Once a file is staged, it disappears from `git diff` and appears in `git diff --staged` instead.
- The second `git diff` returned nothing for `app.log` because it had already crossed into the staging area — only `.gitignore` (still unstaged) showed up. Two different diffs for two different zones.

---

### Drill 4 — Compare specific commits with HEAD~N

**What I ran:**
```bash
git log --oneline
git diff HEAD~1 HEAD
git diff HEAD~3 HEAD
```

**Output (HEAD~3 HEAD):**
```
diff --git a/app.log b/app.log
@@ -1 +1,4 @@
 version 1
+version 2
+version 3
+debug line
```

**What I learned:**
- `HEAD~N` means N commits behind HEAD. 
- `HEAD~1` is one commit back, `HEAD~3` is three back. 
- **Diffing** a wider range shows more accumulated changes. The further back you go, the more history you're spanning.

Commit reference map from this session:
```
787d5b5 HEAD~0 (HEAD)
186efb8 HEAD~1
cd8e5cc HEAD~2
3d21449 HEAD~3
```

---

### Drill 5 — git show by relative ref and hash

**What I ran:**
```bash
git show HEAD~3
git show 3d21449
```

**What I learned:** Both return identical output — they're two ways to reference the same commit object. **Relative refs** (`HEAD~N`) are useful for navigating recent history. **Absolute hashes** are useful for pinning a specific commit in a bug report, rollback command, or sharing with a teammate.

---

## Putting It Together: The Lab

**Task:** 
Add three commits across two files, orient with log, diff the last two commits, show the middle commit by both ref and hash, narrow with`--since`, then walk through the investigation workflow for a broken app scenario.

**What I did:**
```bash
echo "lab work testing" >> app.log
git add app.log
git commit -m "lab: commit 1"
echo "lab work testing" >> readme.txt
git add readme.txt
git commit -m "lab: commit 2"
echo "new file for lab test" >> lab_test.md
git add lab_test.md
git commit -m "lab: commit 3"

git log --oneline --graph
git diff HEAD~2 HEAD
git show HEAD~1
git show c639a0b
git log --since="15 minutes ago"
```

**Output (log):**
```
* 173ebf6 (HEAD -> master) lab: commit 3
* c639a0b lab: commit 2
* cf45d78 lab: commit 1
* 787d5b5 chore: update gitignore with secret key entries
...
```

**Outcome:** All three commits landed across two files. Relative ref and hash confirmed same commit. `--since` narrowed correctly to the three lab commits.

**Investigation workflow answer:**
A teammate says something broke in the last three commits. Commands in order:

1. `git log --oneline` — orient, identify the three commits in question
2. `git diff HEAD~3 HEAD` — scope the full blast radius across all three commits
3. `git show HEAD~2`, `git show HEAD~1`, `git show HEAD` — isolate, open each commit individually to find which one introduced the change
4. `git log --since="X hours ago"` — confirm you're in the right time window

Broad first, then narrow. Diff tells you what changed across the range.
Show tells you which specific commit introduced it.

---

## What Stuck With Me

- **Three tools, three questions.** `git log` = what's the chain. `git diff` = what changed between two states. `git show` = what's inside this commit.
- **`HEAD~N` is relative, hash is absolute.** Both reference the same object. Use relative for navigation, absolute for pinning.
- **`git diff` zone awareness.** Unstaged changes show in `git diff`. Staged changes show in `git diff --staged`. Know which zone you're diffing.
- **Flags compose.** `--oneline --graph --since --author` can all combine. Build the exact view you need.
- **Investigation order: orient → scope → isolate.** Log → diff the range → show each commit.

---

## Tips from the Session

- `git diff HEAD~3 HEAD` then `git show` on individual commits is your first move in any "something broke" scenario. Learn this sequence now — you'll use it in real incidents.
- `--graph` looks useless on a linear branch. Come back after Topic 6 — branching is where it earns its place.

---

> *Carry Forward: `--graph` flag revisit after branching (Topic 6)*