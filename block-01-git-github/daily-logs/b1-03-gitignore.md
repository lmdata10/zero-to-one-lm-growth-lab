# **.gitignore** — What to Never Commit

**Block:** Block 1 — Git & GitHub
**Topic:** .gitignore — what to never commit
**Filename:** `b1-03-gitignore.md`
**Path:** `block-01-git-github/logs/b1-03-gitignore.md`

---

## The Big Picture

`.gitignore` is the list of things Git will never load into a commit, no matter what. Set it up before your first `git add` — not after. Once a file is in history, ignore rules have no effect on it. The secret is already there, permanently, visible to anyone with repo access.

The split between global and repo-level ignore rules matters: personal/machine noise goes global, project artifacts go in the repo-level `.gitignore` and get committed so every contributor gets the same rules.

---

## Learning by Doing

### Drill 1 — Create .gitignore and test it

**What I ran:**
```bash
cd ~/git-lab
touch .env secrets.key notes.tmp
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "*.tmp" >> .gitignore
git status
```

**Output:**

```
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore
nothing added to commit but untracked files present
```

**What I learned:** The three ignored files are completely invisible to Git. `.gitignore` is active the moment it exists — it doesn't need to be committed first to enforce rules locally. `*.key` beats listing filenames explicitly because the wildcard covers every file with that extension, including ones created later that you haven't thought of yet.

---

### Drill 2 — Commit .gitignore itself

**What I ran:**

```bash
git add .gitignore
git commit -m "chore: add gitignore for secrets and temp files"
git status
```

**Output:**

```
[master 4f0ea33] chore: add gitignore for secrets and temp files
 1 file changed, 3 insertions(+)
 create mode 100644 .gitignore

On branch master
nothing to commit, working tree clean
```

**What I learned:** `.gitignore` gets committed so the rules are portable. When someone clones the repo they get the same ignore rules automatically. If it wasn't committed, every contributor would have to recreate the rules manually — that's how secrets leak.

---

### Drill 3 — Try to ignore a file that's already tracked

**What I ran:**

```bash
touch another-secret.key
git add -f another-secret.key
git commit -m "chore: accidentally commit a secret"
echo "another-secret.key" >> .gitignore
git status
```

**Output:**

```
On branch master
Changes not staged for commit:
	modified: .gitignore
no changes added to commit
```

**What I learned:** Once a file is committed, `.gitignore` has no effect on it. Git keeps tracking it. The secret is in the history permanently.

---

### Drill 4 — See the secret in history, then remove from tracking

**What I ran:**

```bash
echo "API_KEY=supersecretvalue123" >> another-secret.key
git add -f another-secret.key
git commit -m "chore: demo secret in history"
git show HEAD
git rm --cached another-secret.key
git commit -m "chore: remove secret from tracking"
git log --oneline
```

**Output:**

```
4ffbc06 (HEAD -> master) chore: remove secret key from tracking
38f59ae chore: accidentally commit a secret
4f0ea33 chore: add gitignore for secrets and temp files
bc22609 docs: test commit flow note
...
```

**What I learned:** `git show <hash>` exposes file contents from any commit — including the API key value in the diff. Removing the file from tracking doesn't rewrite history. `38f59ae` still exists and the key is still visible in it. The only real fix is rotating the credential immediately. Assume it's compromised the moment it touches a remote repo.

`git rm --cached <file>` stops Git from tracking the file without deleting it from disk. Different from `git restore --staged` — this removes it from tracking entirely, not just unstages it.

---

### Drill 5 — Set up a global .gitignore

**What I ran:**

```bash
git config --global core.excludesfile ~/.gitignore_global
touch ~/.gitignore_global
echo ".DS_Store" >> ~/.gitignore_global
echo "*.tmp" >> ~/.gitignore_global
echo ".env" >> ~/.gitignore_global
cat ~/.gitignore_global
```

**Output:**

```
.DS_Store
*.tmp
.env
```

**What I learned:** Two layers of ignore rules serve different purposes. 
- Global `.gitignore_global` is for personal/machine noise — `.DS_Store` is a Mac artifact, `.idea/` is JetBrains, teammates on Linux don't generate these and shouldn't have to care. 
- Repo-level `.gitignore` is for project artifacts that every contributor needs to ignore regardless of their machine. 
- Personal noise → global. Project artifacts → repo-level.

---

## Putting It Together: The Lab

**Task:** Create secure-lab repo, create six files including sensitive ones, set up `.gitignore` before staging anything, use `git add .`to test whether ignored files stay out, verify only safe files land in the commit.

**What I did:**

```bash
mkdir secure-lab && cd secure-lab
git init
touch app.py config.py .env deploy.key notes.tmp README.md
echo "*.key" >> .gitignore
echo ".env" >> .gitignore
echo "*.tmp" >> .gitignore
git add .
git status
git commit -m "lab: gitignore lab task"
git status
git log --oneline
```

**Output:**

```
On branch master
No commits yet
Changes to be committed:
	new file: .gitignore
	new file: README.md
	new file: app.py
	new file: config.py

70ccb1e (HEAD -> master) lab: gitignore lab task
```

**Outcome:** `git add .` staged only the four safe files. `.env`, `deploy.key`, and `notes.tmp` never appeared. Intentionally used `git add .` to verify the ignore rules held under the default staging command — they did.

**Errors hit:** Typo in ignore rule — wrote `*tmp` instead of `*.tmp`. Missing the dot means the rule would match any filename ending in `tmp`, not just `.tmp` extensions. `logtmp`, `notetmp` would be caught incorrectly. Correct pattern is `*.tmp`.

**How I fixed it:** Noted for future — pattern rules need to be precise. Sloppy wildcards cause silent misfires.

**What a teammate sees in this commit:** `app.py`, `config.py`, `README.md`, `.gitignore` — the diff, the file list, the history. Clean. `.env`, `deploy.key`, `notes.tmp` are invisible. Never in the diff, never in the history, never exposed.

---

## What Stuck With Me

- **`.gitignore` before first `git add`. Always.** Once a file is committed it's in history permanently — ignore rules can't touch it.
- **Secrets in history = compromised secrets.** Rotate the credential. Don't just delete the file.
- **Pattern rules beat explicit filenames.** `*.key` covers files you haven't created yet.
- **Two ignore layers, two jobs.** Global for personal/machine noise. Repo-level for project artifacts.
- **`git rm --cached` removes from tracking without touching the file on disk.** Different from unstaging — this cuts the tracking relationship entirely.

---

## Tips from the Session

- `git show <hash>` exposes file contents from any point in history. Assume anything committed to a shared repo has been seen.
- Wildcard patterns need to be precise. `*tmp` and `*.tmp` are not the same rule. Test your ignore patterns with `git status`before committing.

---

## Carry Forward

None — credential rotation concept clear, global vs repo-level distinction clear, `git rm --cached` vs `git restore --staged` distinction clear.