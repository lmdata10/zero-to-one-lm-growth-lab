# GitHub-Specific — README, Repo Structure, Viewing Diffs in UI

**Block:** Block 1 — Git & GitHub
**Topic:** GitHub-specific — README.md, repo structure, viewing diffs in UI
**Filename:** `b1-09-github-specific.md`
**Path:** `block-01-git-github/daily-logs/b1-09-github-specific.md`

---

## The Big Picture

Git is the engine. GitHub is the dashboard. Everything done in the terminal has a visual representation on GitHub — commit history, diffs, branches, file structure, blame. Knowing how to read that dashboard is a separate skill from knowing Git itself.

Your GitHub profile is your public-facing evidence trail. A repo with a good README, clean structure, and readable commit history signals competence before anyone reads a single line of code. Consistent commits with meaningful messages over months says more than any resume bullet point.

---

## Learning by Doing

### Drill 1 — Navigate the GitHub UI

**What I found:**

**Commit count and history:** Top header area — clock/stopwatch icon shows commit count. Click it to see full commit history with messages, hashes, and timestamps.

**Diff view:** Click any commit to see additions (green) and deletions (red) for every file changed in that commit.

**Branch selector:** Dropdown top-left with branch symbol — shows all branches, confirms `main` is the only one.

**Raw view:** Open any file → three tabs: Preview, Code, Blame. Raw button top-right opens plain text content in browser. Useful for copying content or seeing exactly what's in a file without markdown rendering.

**Blame view:** Shows every line in the file annotated with the commit that last touched it — who changed it, in which commit, and when. Not just "what changed in recent commits" — it's line-by-line attribution. Use it to find exactly which commit introduced a specific line and who to talk to about it.

---

### Drill 2 — GitHub profile setup

**Profile README:** Exists at `lmdata10/lmdata10` repo. Confirmed visible on profile page.

**Pinned repos:** `zero-to-one-lm-growth-lab` pinned during this session.

**Contribution graph:** Active — every commit shows as a green box. Consistent commits build a visible public record of sustained effort.

**What I learned:** Profile README is a hiring signal. Updated it during this session to add `zero-to-one-lm-growth-lab` as a featured project with current status, stack, and cert targets. A stale profile with "coming soon" sections that never materialise is worse than no section at all.

---

### Drill 3 — Read the diff view properly

**Four elements in a GitHub diff:**

**Red lines:** Lines removed from the file in this commit.

**Green lines:** Lines added to the file in this commit.

**`@@` hunk headers:** `@@ -3,3 +3,4 @@` means — in the old file (`-`), starting at line 3, show 3 lines context. In the new file (`+`), starting at line 3, show 4 lines. Tells you exactly where in the file the change happened. In a large file with a change on line 847, the hunk header jumps you straight there without scrolling.

**File header:** Shows old filename (`a/readme.txt`) and new filename (`b/readme.txt`). If a file was renamed you see two different names. If deleted you see `/dev/null` as the new file. Tells you what happened to the file itself, not just its contents.

---

### Drill 4 — Issues and commit references

**What I did:**
Created Issue #1 — "Add templates directory to repo"

**Commit message format to close it:**

`chore(templates): add templates directory with session log template`
`Closes #1`

**What I learned:** `Closes #1` in the commit body automatically closes the linked issue when the commit lands on main. GitHub links the commit to the issue and marks it resolved. `Fixes #1` and `Resolves #1` do the same thing. Just `#1` without a keyword creates a reference link but doesn't close the issue.

This is how real teams track work — every commit that resolves something references the issue. History becomes navigable: bug report to fix commit in one click.

Issue #1 closed during this session via test commit with `Closes #1` in the body — GitHub auto-closed it as expected.

---

### Drill 5 — Profile README review and update

**Current state:** Strong profile. Honest, specific, signals operational depth without overclaiming. Current role table shows real work context.

**Updates made this session:**
- Added `zero-to-one-lm-growth-lab` as featured project above AD lab
- Included current block status, full stack, and cert targets
- Committed to profile repo

**Commit message used:** `docs: add 'Zero to One' project details to README`

**Correction noted:** Should have been: `docs(profile): add zero-to-one-lm-growth-lab to featured projects` Past tense framing and unnecessary quotes. Topic 8 rules apply even when Topic 8 isn't the active session. Consistency is the point.

---

## What Stuck With Me

- **Blame view is surgical.** Line-by-line attribution — who changed this line, in which commit, when. Not a general history view. Use it when you need to find exactly what introduced a specific problem.
- **`@@` hunk headers are coordinates.** They tell you where in the file the change is — old file line number, new file line number. Essential for reading diffs in large files.
- **`Closes #1` auto-closes issues.** Reference alone (`#1`) links without closing. Keywords (`Closes`, `Fixes`, `Resolves`) trigger auto-close when the commit lands on main.
- **GitHub profile is a hiring signal.** Commit frequency, message quality, and whether the history tells a coherent story are all visible to anyone who knows Git.
- **Consistent small commits beat occasional large ones.** The contribution graph is public. Gaps are visible.

---

## Tips from the Session

- Keep your profile README current. Stale "coming soon" sections that never materialise signal exactly the opposite of what you want.
- Commit convention doesn't get to slip when it's not the active topic. Topic 8 applies to every commit from here on — not just the session where it was taught.

---

> Carry Forward: None — GitHub UI navigation clear, diff reading clear, issue references
clear, profile updated.