# Remote Repos — git remote, git push, git pull, git clone

**Block:** Block 1 — Git & GitHub
**Topic:** Remote repos — git remote, git push, git pull, git clone
**Filename:** `b1-05-remote-repos.md`
**Path:** `block-01-git-github/daily-logs/b1-05-remote-repos.md`

---

## The Big Picture

Everything up to this point lived only on the local machine. A remote repo is the same history living on a server — GitHub in this case. Nothing syncs automatically. You control when and in which direction. `git push` sends your snapshots to the remote. `git pull` brings the remote's snapshots to you. `git clone` copies an entire remote repo to your machine for the first time, history and all.

The `-u` flag on first push sets the tracking relationship between your local branch and the remote branch — after that, `git push` and `git pull` work without arguments forever.

---

## Learning by Doing

### Drill 1 — Connect local repo to remote

**What I ran:**

```bash
cd ~/zero-to-one/zero-to-one-lm-growth-lab
git init
git remote add origin https://github.com/lmdata10/zero-to-one-lm-growth-lab.git
git remote -v
```

**Output:**

```
origin  https://github.com/lmdata10/zero-to-one-lm-growth-lab.git (fetch)
origin  https://github.com/lmdata10/zero-to-one-lm-growth-lab.git (push)
```

**What I learned:** `origin` is just an alias — a shorthand for the remote URL so you don't type the full URL every time. Convention, not a Git requirement. You could name it anything, but `origin` is universal. Every Git user knows what it means.

---

### Drill 2 — First commit and push, master to main rename

**What I ran:**

```bash
git add .
git commit -m "init: block 1 session logs and repo structure"
git push -u origin master
git branch -m master main
git push -u origin main
git push origin --delete master
git config --global init.defaultBranch main
```

**Output:**

```
branch 'main' set up to track 'origin/main'
To https://github.com/lmdata10/zero-to-one-lm-growth-lab.git
 - [deleted] master
```

**What I learned:** `-u` sets the upstream tracking relationship between local and remote branch. After one push with `-u`, Git knows where to send and receive — `git push` and `git pull` work without arguments from then on.

GitHub defaults to `main`, Git locally defaults to `master`. Set `init.defaultBranch main` globally to avoid the mismatch on every new repo. Can't delete the default branch on GitHub remotely — change default branch in GitHub Settings first, then delete.

```bash
git branch -vv
# * main d349cf4 [origin/main] init: block 1 session logs and repo structure
```

`[origin/main]` confirms the tracking relationship `-u` created.

---

### Drill 3 — Push without arguments

**What I ran:**

```bash
cd ~/zero-to-one/git-lab
echo "# remote drill note" >> readme.txt
git add readme.txt
git commit -m "docs: remote drill note"
git log --oneline
```

**What I learned:** Once `-u` sets the tracking relationship, `git push` alone is enough. No need to specify `origin main` on every push. Ran this in git-lab practice repo to avoid polluting the main repo README with drill content — good habit to protect real project files from throwaway exercises.

---

### Drill 4 — Clone a repo

**What I ran:**

```bash
cd ~/zero-to-one
git clone https://github.com/lmdata10/zero-to-one-lm-growth-lab.git clone-test
cd clone-test
git log --oneline
```

**Output:**

```
d349cf4 (HEAD -> main, origin/main, origin/HEAD) init: block 1 session logs
and repo structure
```

**What I learned:** `git clone` does everything in one command — init, remote add, fetch, and checkout. Brings the full history. `origin/HEAD` in the log shows Git knows the remote's default branch without you specifying it.

`git init` + `git remote add` = building the connection manually from a local starting point. `git clone` = starting from the remote and pulling everything down.

---

### Drill 5 — Simulate pull from a second location

**What I ran:**

```bash
# In real repo
cd ~/zero-to-one/zero-to-one-lm-growth-lab
echo "remote pull drill" >> README.md
git add README.md
git commit -m "docs: remote pull drill test"
git push

# In clone
cd ~/zero-to-one/clone-test
git pull
git log --oneline
```

**Output:**

```
Fast-forward
 README.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

5301333 (HEAD -> main, origin/main, origin/HEAD) docs: remote pull drill test
d349cf4 init: block 1 session logs and repo structure
```

**What I learned:** `git pull` fetched the new commit from the remote and applied it locally. `Fast-forward` means no conflicts — the clone just moved its pointer forward to match the remote. Clone went from one commit to two.

Cleaned up after: `rm -rf clone-test` — stale copies of repos cause confusion.

---

## Putting It Together: The Lab

**Task:** Add Block 1 README to the live repo, stage, commit, push, verify on GitHub, confirm commit chain.

**What I did:**

```bash
touch block-01-git-github/README.md
code block-01-git-github/README.md
git add block-01-git-github/README.md
git commit -m "organize: block 1 structure and readme"
git push
git log --oneline
```

**Output:**

```
6a8e826 (HEAD -> main, origin/main) organize: block 1 structure and readme
deea53d chore: readme clean up after remote pull drill
5301333 docs: remote pull drill test
d349cf4 init: block 1 session logs and repo structure
```

**Outcome:** Block 1 README live on GitHub at correct path. `git push` with no arguments confirmed tracking relationship working. Verified file in GitHub UI at correct location.

**Key distinction learned:** `git pull` — fetches remote changes and merges them into your local branch. You run it, it happens immediately. Used when a teammate pushed and you need their changes before starting your next piece of work.

Pull request — a GitHub concept. A proposal asking someone to review your branch and merge it into main. Requires human review and approval. Not the same as `git pull` despite the name.

---

## What Stuck With Me

- **`origin` is a convention, not a requirement.** It's an alias for the remote URL. Every Git user knows what it means — use it.
- **`-u` once, then forget it.** Sets the tracking relationship permanently. `git push` and `git pull` work without arguments after that.
- **Nothing syncs automatically.** You control when and in which direction. Push sends. Pull receives. Clone copies everything.
- **`git pull` ≠ pull request.** Two completely different things with confusingly similar names. Don't mix them up in an interview.
- **`master` vs `main` is a convention shift, not a Git change.** Set `init.defaultBranch main` globally and never think about it again.

---

## Tips from the Session

- `git pull` before you start work on a shared repo. Always. Avoids conflicts before they start.
- Protect your real project files from drill content. Use a practice repo for throwaway exercises — don't pollute your main repo history with test commits.

---

>***Carry Forward:** None — tracking relationship, push/pull distinction, clone vs init all clear. master/main rename resolved and configured globally.*