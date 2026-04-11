# Block 1 — Git & GitHub Cheatsheet

Condensed reference from all 11 sessions. Commands, logic, tips, mistakes to avoid. Not a tutorial — assumes you've done the work.

---

## Mental Model

Git saves **snapshots** of your project, not diffs. Every commit is a complete picture of the repo at that moment, identified by a unique hash.

**Three zones:**

```
Working directory → (git add) → Staging area → (git commit) → Repository
```

Nothing moves without you explicitly telling Git to move it.

---

## Setup — Run Once

```bash
git config --global user.name "Your Name"
git config --global user.email "you@email.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.excludesfile ~/.gitignore_global
```

---

## Core Loop

```bash
git init                          # initialise repo in current directory
git status                        # always know your state — run constantly
git add <file>                    # stage specific file
git add .                         # stage everything (use deliberately)
git commit -m "type(scope): msg"  # snapshot with message
git log --oneline                 # compact history
git log --oneline --graph --all   # full branch graph
```

---

## .gitignore

```bash
echo ".env" >> .gitignore         # ignore specific file
echo "*.key" >> .gitignore        # ignore by pattern
echo ".DS_Store" >> ~/.gitignore_global  # global — machine-specific noise
git rm --cached <file>            # stop tracking already-committed file
```

**Rules:**

- Set up `.gitignore` before first `git add` — not after
- Once a file is committed it's in history permanently — ignore rules have no effect
- Secrets in history = rotate the credential immediately

---

## Reading History

```bash
git log --oneline                 # compact commit chain
git log --oneline --graph --all   # visual branch graph
git log --since="2 hours ago"     # filter by time
git log --author="name"           # filter by author
git diff                          # working directory vs staging
git diff --staged                 # staging vs last commit
git diff HEAD~3 HEAD              # compare two commits
git show HEAD                     # open current commit — hash + diff
git show <hash>                   # open specific commit
```

**Investigation order:** orient (`git log`) → scope (`git diff HEAD~N HEAD`) → isolate (`git show <hash>`)

---

## Remote Repos

```bash
git remote add origin <url>       # connect local to remote
git remote -v                     # verify remote connection
git push -u origin main           # first push — sets tracking relationship
git push                          # all subsequent pushes
git pull                          # fetch + merge remote changes
git clone <url>                   # copy remote repo including full history
git branch -vv                    # show tracking relationships
```

**Key points:**

- `origin` is just an alias — convention, not requirement
- `-u` on first push only — sets tracking, then `git push` works alone
- `git pull` before starting work — always, on shared repos
- `git pull` ≠ pull request — completely different things

---

## Branching

```bash
git branch                        # list branches
git branch <name>                 # create branch
git switch <name>                 # switch to branch
git switch -c <name>              # create and switch in one command
git merge <branch>                # merge branch into current
git branch -d <name>              # safe delete — refuses if unmerged
git branch -D <name>              # force delete — no check
git log --oneline --graph --all   # see all branches visually
```

**Fast-forward vs merge commit:**

- Fast-forward: no diverging commits, pointer moves, graph stays linear
- Merge commit: branches diverged, Git reconciles, two-parent commit created

**Branch workflow:** create → work → commit → merge → delete. Keep main clean.

---

## Fixing Mistakes

|Situation|Command|
|---|---|
|Unstaged change — discard|`git restore <file>`|
|Staged change — unstage|`git restore --staged <file>`|
|No HEAD yet — unstage|`git rm --cached <file>`|
|Committed, not pushed — undo|`git reset --soft HEAD~1`|
|Committed, not pushed — wipe|`git reset --hard HEAD~1`|
|Committed and pushed — undo safely|`git revert <hash>`|
|Think work is lost|`git reflog`|

**Reset modes:**

- `--soft` — HEAD moves back, changes stay staged
- `--mixed` — HEAD moves back, changes unstaged (default)
- `--hard` — HEAD moves back, changes wiped permanently

**Reflog rescue:**

```bash
git reflog                        # find lost commit hash
git checkout <hash>               # go to it (detached HEAD)
git branch recovered <hash>       # attach a branch to save it
git switch main                   # get back to main
```

---

## Commit Messages — Conventional Commits

```
type(scope): short description

optional body — explains why, not what
```

**Types:**

|Type|Use|
|---|---|
|`feat`|New feature|
|`fix`|Bug fix|
|`docs`|Documentation|
|`chore`|Maintenance, config, tooling|
|`refactor`|Restructure without changing behaviour|
|`test`|Tests|
|`ci`|CI/CD pipeline|
|`style`|Formatting only|

**Rules:**

- Imperative mood — `add` not `added`
- Lowercase after the colon
- Under 72 characters
- No period at the end
- Body explains _why_ — subject explains _what_
- One commit, one purpose

---

## GitHub-Specific

```bash
# Reference an issue in a commit body
Closes #1      # auto-closes issue when commit lands on main
Fixes #1       # same
Resolves #1    # same
#1             # reference only — doesn't close
```

**UI navigation:**

- Commit history: clock icon on repo main page
- Diff view: click any commit — red = removed, green = added
- `@@` hunk headers: line coordinates in old and new file
- Blame view: line-by-line attribution — who changed this line, which commit, when
- Raw view: file → Raw button top right

---

## Rebase

```bash
git rebase main                   # replay current branch commits on top of main
git rebase --continue             # after resolving a conflict
git rebase --skip                 # skip current commit (change already exists)
git rebase --abort                # abandon rebase, return to pre-rebase state
```

**Rebase vs merge:**

|                     | Rebase                         | Merge                            |
| ------------------- | ------------------------------ | -------------------------------- |
| **History**             | Linear — rewrites commits      | Honest — preserves divergence    |
| **When**                | Local feature branch before PR | Integrating into shared branches |
| **Safe after push?**    | Never                          | Always                           |
| **Conflict resolution** | `git add` → `--continue`       | `git add` → `git commit`         |

**Golden rule:** Never rebase commits already pushed to a shared branch. Rewrites history, breaks everyone else's local copy.

**Practical workflow:** Rebase locally → merge fast-forwards cleanly → linear history, no merge commit noise.

---

## Global Config Reference

```bash
# Set defaults once, applies to all repos
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global user.name "Your Name"
git config --global user.email "you@email.com"
git config --global core.excludesfile ~/.gitignore_global

# Verify
git config --list --global
```

---

## Mistakes to Never Make Again

- Committing secrets — `.env`, `*.key`, credentials. Set `.gitignore` first.
- `git add .` without checking `git status` first
- Typos in commit messages — they're permanent
- Editing on GitHub and locally without pulling first
- `git reset` on pushed commits — use `git revert` instead
- Force pushing to a shared branch
- Deleting branches with `-D` without checking if work is saved
- `git restore` on changes you actually needed — it's permanent

---

## Quick Reference — What to Run When

**Starting work:**

```bash
git pull
git switch -c feature/your-task
```

**During work:**

```bash
git status                        # constantly
git diff --staged                 # before every commit
git commit -m "type(scope): msg"
```

**Before merging:**

```bash
git switch feature/your-task
git rebase main                   # catch up to main
git switch main
git merge feature/your-task       # fast-forward
git branch -d feature/your-task
git push
```

**Something broke:**

```bash
git log --oneline                 # orient
git diff HEAD~3 HEAD              # scope
git show <hash>                   # isolate
git revert <hash>                 # fix safely if pushed
git reflog                        # last resort
```