# Block 1 — Git & GitHub

**Target:** Get comfortable using Git daily without thinking about it.

---

## What This Block Is

Git is the foundation everything else gets built on. Before you write a script, configure a server, or touch a cloud resource — you need somewhere to track the work, version it, and push it somewhere safe. This block makes that automatic.

Not just the commands. The mental model. Why staging exists. What a commit actually is. How history works. What to do when you break something.

By the end of this block, Git is muscle memory — not something you reference notes for.

---

## Progress

| # | Topic | Status |
|---|-------|--------|
| 1 | What Git actually is — snapshots, not diffs | ✅ Done |
| 2 | `git add`, `git commit` — the core loop | ✅ Done |
| 3 | `.gitignore` — what to never commit | ✅ Done |
| 4 | `git log`, `git diff`, `git show` — reading history | ✅ Done |
| 5 | Remote repos — `git remote`, `git push`, `git pull`, `git clone` | 🔄 In Progress |
| 6 | Branching — `git branch`, `git switch`, `git merge` | ⏳ |
| 7 | Fixing mistakes — `git restore`, `git reset`, `git revert` | ⏳ |
| 8 | Commit messages — conventional commits format | ⏳ |
| 9 | GitHub-specific — README, repo structure, viewing diffs in UI | ⏳ |
| 10 | Real workflow — feature branch → commit → push → merge | ⏳ |

---

## Session Logs

| Log | Topic |
|-----|-------|
| [b1-01-git-mental-model.md](daily-logs/b1-01-git-mental-model.md) | Snapshots mental model, three zones, first commits |
| [b1-02-core-loop.md](daily-logs/b1-02-core-loop.md) | Staging intentionally, diff, show, unstaging |
| [b1-03-gitignore.md](daily-logs/b1-03-gitignore.md) | Ignore rules, global vs repo-level, secrets in history |
| [b1-04-reading-history.md](daily-logs/b1-04-reading-history.md) | git log, diff, show — investigation workflow |
| [b1-05-remote-repos.md](daily-logs/b1-05-remote-repos.md) | Remotes, push, pull, clone — in progress |

---

## Key Concepts From This Block

**The three zones:** Working directory → staging area → repository. Know which
zone your files are in at all times. Everything flows in one direction until
you commit.

**Snapshots, not diffs:** Git saves the state of your project, not just what
changed. Every commit is a complete picture with a unique hash. That hash is
permanent.

**`.gitignore` before first commit:** Once a file is in history it stays there.
Secrets in history mean rotate the credential — removing the file isn't enough.

**Reading history is an ops skill:** `git log`, `git diff`, `git show` are your
investigation tools. Orient → scope → isolate. This is how you find what broke
and when.

**Remotes are not automatic:** Nothing syncs without you telling Git to. `git push`
sends. `git pull` receives. `-u` on first push sets the tracking relationship
so you never have to specify the remote again.

---

## Exit Criteria

- [ ] Can init a repo, commit work, push to GitHub without referencing notes
- [ ] `zero-to-one-lm-growth-lab` is live with correct structure and commit history
- [ ] Every session ends with a commit — this is now muscle memory
- [ ] Can recover from a bad commit without panicking

---

## Honest Assessment

[Fill at end of block — what clicked, what didn't, what you'd do differently.]