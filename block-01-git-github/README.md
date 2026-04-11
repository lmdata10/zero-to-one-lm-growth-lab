# Block 1 — Git & GitHub

**Status:** ✅ Complete 
**Target:** Comfortable using Git daily without thinking about it.

---

## What This Block Is

**Git** is the foundation everything else gets built on. Before you write a script, configure a server, or touch a cloud resource — you need somewhere to track the work, version it, and push it somewhere safe. This block makes that automatic.

Not just the commands. The mental model. Why staging exists. What a commit actually is. How history works. What to do when you break something. How history gets rewritten and when that's dangerous.

By the end of this block, Git is muscle memory — not something we reference notes for.

---

## Progress

|#|Topic|Status|
|---|---|---|
|1|What Git actually is — snapshots, not diffs|✅ Done|
|2|`git add`, `git commit` — the core loop|✅ Done|
|3|`.gitignore` — what to never commit|✅ Done|
|4|`git log`, `git diff`, `git show` — reading history|✅ Done|
|5|Remote repos — `git remote`, `git push`, `git pull`, `git clone`|✅ Done|
|6|Branching — `git branch`, `git switch`, `git merge`|✅ Done|
|7|Fixing mistakes — `git restore`, `git reset`, `git revert`, `git reflog`|✅ Done|
|8|Commit messages — conventional commits format|✅ Done|
|9|GitHub-specific — README, repo structure, viewing diffs in UI|✅ Done|
|10|Real workflow — feature branch → commit → push → merge|✅ Done|
|11|`git rebase` — when and why|✅ Done|

---

## Session Logs

|Log|Topic|
|---|---|
|[b1-01-git-mental-model.md](https://claude.ai/chat/daily-logs/b1-01-git-mental-model.md)|Snapshots mental model, three zones, first commits|
|[b1-02-core-loop.md](https://claude.ai/chat/daily-logs/b1-02-core-loop.md)|Staging intentionally, diff, show, unstaging|
|[b1-03-gitignore.md](https://claude.ai/chat/daily-logs/b1-03-gitignore.md)|Ignore rules, global vs repo-level, secrets in history|
|[b1-04-reading-history.md](https://claude.ai/chat/daily-logs/b1-04-reading-history.md)|git log, diff, show — investigation workflow|
|[b1-05-remote-repos.md](https://claude.ai/chat/daily-logs/b1-05-remote-repos.md)|Remotes, push, pull, clone|
|[b1-06-branching.md](https://claude.ai/chat/daily-logs/b1-06-branching.md)|Branching, switch, merge, fast-forward vs merge commit|
|[b1-07-fixing-mistakes.md](https://claude.ai/chat/daily-logs/b1-07-fixing-mistakes.md)|restore, reset, revert, reflog|
|[b1-08-commit-messages.md](https://claude.ai/chat/daily-logs/b1-08-commit-messages.md)|Conventional commits format|
|[b1-09-github-specific.md](https://claude.ai/chat/daily-logs/b1-09-github-specific.md)|README, repo structure, blame, diffs, issues in GitHub UI|
|[b1-10-real-workflow.md](https://claude.ai/chat/daily-logs/b1-10-real-workflow.md)|Real workflow — branching, merging, conflict resolution|
|[b1-11-git-rebase.md](https://claude.ai/chat/daily-logs/b1-11-git-rebase.md)|git rebase — when and why, rebase vs merge|

---

## Key Concepts From This Block

**The three zones:**
	- Working directory → staging area → repository. 
	- Know which zone your files are in at all times. 
	- Everything flows in one direction until you commit.

**Snapshots, not diffs:** Git saves the state of your project, not just what changed. Every commit is a complete picture with a unique hash. That hash is permanent.

**`.gitignore` before first commit:** Once a file is in history it stays there. Secrets in history mean rotate the credential — removing the file isn't enough.

**Reading history is an ops skill:** `git log`, `git diff`, `git show` are your investigation tools. Orient → scope → isolate. This is how you find what broke and when.

**Remotes are not automatic:** Nothing syncs without you telling Git to. `git push` sends. `git pull` receives. `-u` on first push sets the tracking relationship so you never have to specify the remote again.

**Four recovery tools, four stages:**
	- Working directory → `git restore`
	- Staged → `git restore --staged`
	- Committed not pushed → `git reset`
	- Pushed → `git revert`
	- Think work is lost → `git reflog`.

**Commit messages are permanent documentation:**
	- `type(scope): description`
	- Imperative, lowercase, under 72 characters. 
	- One commit, one purpose.

**Rebase vs merge:** **Rebase** rewrites history to look linear. **Merge** preserves honest divergence. Rebase locally before pushing. Merge to integrate into shared branches. *Never rebase pushed commits*.

**`git reflog` is the black box:** Every HEAD movement recorded. Your last resort when you think work is lost.

---

## Exit Criteria

- [x] Can init a repo, commit work, push to GitHub without referencing notes
- [x] `zero-to-one-lm-growth-lab` is live with correct structure and commit history
- [x] Every session ends with a commit — this is now muscle memory
- [x] Can recover from a bad commit without panicking

---

## Honest Assessment

Git clicked faster than expected because of the mental model first approach — snapshots, not diffs, and the three zones made every command make sense instead of being something to memorise.

The things that took more than one attempt: staging flow initially felt abstract until the drill where we tried to commit without staging and Git refused. The `master` vs `main` rename at the push stage was a real scenario that needed fixing, not a drill — that was better for it. Conflict resolution during rebase was messier than during merge because of the `--continue` vs `git commit` distinction.

Biggest mistake pattern: typos in commit messages. `tets`, `bracnhing`, `reabse` — all permanent. Slowing down on commit messages is the carry-forward habit from this block.

What would I do differently: set `git config --global pull.rebase false` and `git config --global init.defaultBranch main` at the very start of the block before any drills. Hitting those config issues mid-session added friction that could have been avoided.