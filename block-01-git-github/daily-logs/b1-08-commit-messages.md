# Writing Useful Commit Messages — Conventional Commits Format

**Block:** Block 1 — Git & GitHub
**Topic:** Writing useful commit messages — conventional commits format
**Filename:** `b1-08-commit-messages.md`
**Path:** `block-01-git-github/daily-logs/b1-08-commit-messages.md`

---

## The Big Picture

Commit messages are permanent documentation. They're the only explanation future-you or a teammate has for why a change was made. A bad message makes the history useless. A good one makes debugging, reverting, and code review targeted and fast.

Conventional commits gives you a consistent format that's readable by humans and parseable by tools: `type(scope): description`. The type tells you what kind of change. The scope narrows it to where. The description is imperative, lowercase, specific, under 72 characters.

---

## The Format

```
<type>(<scope>): <short description>

[optional body — explains why, not what]

[optional footer — breaking changes, issue references]
```

### Core Types

| Type | When to use it |
|------|---------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance — deps, config, tooling |
| `refactor` | Code restructure — not a fix or feature |
| `test` | Adding or fixing tests |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, whitespace — no logic change |

### The Rules
- Imperative mood — `add readme` not `added readme`
- Lowercase after the colon
- Under 72 characters for the subject line
- No period at the end
- Body separated from subject by a blank line
- Body explains *why* — subject covers *what*
- Never use `update`, `fix stuff`, `changes`, `misc` as the full message

---

## Learning by Doing

### Drill 1 — Spot and fix bad messages

**Original → Problem → Fix:**

`"fixed the bug"`
Problem: past tense, no type, no description of what bug or where.
Fix: `fix(auth): resolve null pointer on failed login attempt`

`"Updated readme and also changed some config stuff and fixed login"`
Problem: three separate changes in one commit — should never be bundled.
Fix: split into three commits:
- `docs: update readme with installation steps`
- `chore: update config for production environment`
- `fix(auth): resolve login failure on empty password`

`"WIP"`
Problem: meaningless in history. WIP commits shouldn't be pushed.
Fix: `feat(health-check): add initial disk usage monitoring`

`"Changes to user script"`
Problem: vague, no type, tells you nothing about what changed.
Fix: `refactor(user-provisioning): extract group assignment into function`

`"added logging to the health check script because it wasn't logging errors before"`
Problem: past tense, over 72 characters, explanation belongs in body.
Fix:
```
feat(health-check): add error logging to disk check

Previously silent on failures — errors now written to /var/log/health.log for easier debugging and alerting.
```

**What I learned:** Slapping a type prefix on a bad message doesn't fix it.
The description itself has to be specific, imperative, and concise. The type prefix is the easy part.

---

### Drill 2 — Write messages for real scenarios

**Scenario → Commit message:**

Add .gitignore before first commit:
`chore: add gitignore for secrets and temp files`
Note: `.gitignore` is repo configuration, not documentation — type is `chore` not `docs`.

Bash script that checks disk usage and emails an alert:
```
feat(monitoring): add disk usage alert script

Checks disk usage on all mounted volumes and sends email alert when usage exceeds 80%. Designed to run via cron on Rocky Linux.
```

Fix typo in session log:
`docs(b1-03-gitignore): fix typo in drill 3 output`
Note: typo fix in markdown is `docs` not `chore`.

Add SSH key and disable password auth:
```
chore(sshd): configure key-based auth and disable password login

Hardens SSH access per security baseline. Password auth disabled in sshd_config. Public key added to authorized_keys for admin user.
```

Hotfix merged into main:
`fix(firewall): close port 8080 left open after deploy`
Note: the merge itself doesn't get a message — describe the hotfix content,
not the merge action.

**What I learned:** Type selection needs precision. `refactor` means restructuring existing code without changing behaviour. `docs` is for documentation files. `chore` is for maintenance and config. Don't use them loosely.

---

### Drill 3 — Audit existing history

**Three worst commit messages from git-lab:**

```
102cd27 docs: remote drill note 
cf45d78 lab: commit 1 
42418f9 lab: bracnhing and adding line in readme
```

Rewrites:
- `docs: remote drill note` → `docs: add drill note to readme`
- `lab: commit 1` → `chore(git-lab): test core loop commit flow`
- `lab: bracnhing and adding line in readme` → `docs(git-lab): add branching lab line to readme`

**What I learned:** `lab:` is a non-standard type — fine for a learning repo, not for a real team codebase. Pick the closest real type. Typos in commit messages are permanent — slow down and read before committing.

---

### Drill 4 — Write the commit message before committing

**Scenario:** Commit session log for Topic 8 and update Block 1 README.

First attempt: `docs: add topic 8 log` — too vague, doesn't say what topic 8 covers or what changed in the README.

Second attempt: `docs: add b1-08-commit-messages.md log to block 01` — better, specific filename, specific block.

Final version — split into two commits:
```
docs(block-01): add b1-08-commit-messages session log 
docs(block-01): mark topic 8 complete in block 01 readme
````

**What I learned:** If a commit touches two separate concerns, split it. One
commit, one purpose. Each commit becomes a clean revert target. Bundling
unrelated changes makes `git revert` blunt instead of surgical.

---

## Putting It Together: The Lab

**Task:** Commit session log and README update as two separate commits with
proper conventional commit messages. Push both.

**What I did:**
```bash
touch block-01-git-github/daily-logs/b1-08-commit-messages.md
code block-01-git-github/daily-logs/b1-08-commit-messages.md
git add block-01-git-github/daily-logs/b1-08-commit-messages.md
git commit -m "docs(block-01): add b1-08-commit-messages session log"
# update README progress table
git add block-01-git-github/README.md
git commit -m "docs(block-01): mark topic 8 complete in block 01 readme"
git push
````

**Outcome:** Two clean commits, one purpose each. Session log and README update are separate revert targets if needed.

**Why separate commits matter:** One commit, one purpose creates clean tracking. If someone needs to revert the README update without touching the log, or vice versa, they have a clean target. Bundling related-but-separate changes removes that option and makes history harder to read at a glance.

---

## What Stuck With Me

- **Type selection is specific.** `refactor`, `docs`, `chore`, `feat`, `fix` each have a definition. Use them precisely or the format loses its value.
- **Description is imperative, lowercase, under 72 chars.** Write it like a command: `add`, `fix`, `remove` — not `added`, `fixed`, `removed`.
- **Body explains why. Subject explains what.** If context matters, use the body — don't cram it into the subject line.
- **One commit, one purpose.** If you can't write a clear subject, the commit is doing too many things. Split it.
- **`lab:` is non-standard.** Fine for learning, not for real repos.

---

## Tips from the Session

- Read your commit message out loud before committing. If it sounds vague, it is vague.
- If you can't write a clear one-line subject, the commit is probably doing too many things. That's a signal to split, not to write a longer message.

---