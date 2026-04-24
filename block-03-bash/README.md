# Block 3 - Bash Scripting

**Target:** Write real scripts that solve actual problems - system health check, user provisioning, log parser - with error handling, comments, and security scan passed.

---

## Purpose

CLI fluency is tools. Bash scripting is automation. This is the jump from "I can run commands" to "I can make the system do things repeatedly without me typing." In every real Cloud, SRE, or Platform Engineering role, the person who writes scripts scales their impact. The person who doesn't - doesn't. Block 2 taught navigation and command syntax. Block 3 turns that into actual work product.

---

## What We're Doing Here

- Pre-Topic: Vim basics - `i`, `o`, `dd`, `:wq`, navigation, enough to write scripts without friction
- Topic 1: What a shell script is - shebang, executable permissions, redirecting output, the health check script
- Topic 2: Variables - declaring, referencing, quoting rules (single vs double vs no quotes)
- Topic 3: User input - positional parameters `$1 $2`, `$@`, `$#`, the `read` command
- Topic 4: Conditionals - `if/elif/else`, test operators (`-f`, `-d`, `-z`, `-eq`), `[[ ]]` vs `[ ]`
- Topic 5: Loops - `for`, `while`, `until`, `break`, `continue`
- Topic 6: Functions - defining, calling, returning values, local variables
- Topic 7: Exit codes and error handling - `$?`, `set -e`, `set -u`, `set -o pipefail`, traps
- Topic 8: Working with files - reading line by line, checking existence, writing output
- Topic 9: Scheduling - `crontab -e`, cron syntax, logging cron output
- Topic 10: Debugging - `bash -x`, `set -x`/`set +x`, reading error output
- Lab 1: System health check script - disk, memory, running services, output to dated log
- Lab 2: User provisioning script - create user, set password policy, add to group, log action
- Lab 3: Log parser - grep errors from `/var/log`, count occurrences, write report

---

## Outcomes

By the end of this block, I can:

- Write a shell script from scratch without referencing notes - shebang, variables, conditionals, error handling
- Read an unfamiliar bash script and explain what it does line by line
- Use vim to open, edit, and save files confidently (not blazingly fast, but confidently)
- Build a script that accepts command-line arguments and validates them
- Debug a broken script using `bash -x` and reading error messages systematically
- Schedule a script to run via cron and verify it's actually running

And I have produced:

- `first.sh` - health check script with dated log output (session log included)
- `system-health-check.sh` - full version with error handling and comments
- `user-provisioning.sh` - create user, set policies, log the action
- `log-parser.sh` - parse auth/syslog, output summary report
- 10 session logs documenting each topic with drills and labs

---

## Resources Used

| Resource                            | URL                                                  | Type    |
| ----------------------------------- | ---------------------------------------------------- | ------- |
| Introduction to Bash Scripting      | https://ebook.bobby.sh                               | eBook   |
| TechWorld with Nana -Bash Scripting | https://youtu.be/PNhq_4d-5ek?si=pKC8-WZcGIAa5moS     | YouTube |
| YSAP                                | https://www.youtube.com/watch?v=Sx9zG7wa4FA&t=25989s | YouTube |

---

## Session Log Index

|Log|Topic|
|---|---|
|[b3-01-what-a-shell-script-is.md](daily-logs/b3-01-what-a-shell-script-is.md)|Pre-Topic: Vim basics + Topic 1: Shell scripts, shebang, redirection|
|[b3-02-variables-and-quoting.md](daily-logs/b3-02-variables-and-quoting.md)|Topic 2: Variable declaration, referencing, quoting rules|
|[b3-03-user-input-parameters.md](daily-logs/)|Topic 3: Positional parameters, `$@`, `$#`, `read` command|
|[b3-04-conditionals.md](daily-logs/)|Topic 4: `if/elif/else`, test operators, `[[ ]]` vs `[ ]`|
|[b3-05-loops.md](daily-logs/)|Topic 5: `for`, `while`, `until`, `break`, `continue`|
|[b3-06-functions.md](daily-logs/)|Topic 6: Functions, return values, local variables|
|[b3-07-exit-codes-and-errors.md](daily-logs/)|Topic 7: Exit codes, `set -e`, `set -u`, error handling|
|[b3-08-file-operations.md](daily-logs/)|Topic 8: Reading files, checking existence, writing output|
|[b3-09-cron-scheduling.md](daily-logs/)|Topic 9: `crontab`, cron syntax, logging|
|[b3-10-debugging.md](daily-logs/)|Topic 10: `bash -x`, debugging techniques|

---

## Progress

**Status:** In progress - Topic 1 complete

- [x]  Pre-Topic: Vim basics
- [x]  Topic 1: Shell scripts + health check lab
- [x]  Topic 2: Variables + quoting
- [ ]  Topic 3: User input
- [ ]  Topic 4: Conditionals
- [ ]  Topic 5: Loops
- [ ]  Topic 6: Functions
- [ ]  Topic 7: Exit codes and error handling
- [ ]  Topic 8: File operations
- [ ]  Topic 9: Cron scheduling
- [ ]  Topic 10: Debugging
- [ ]  Lab 1: System health check (complete version)
- [ ]  Lab 2: User provisioning
- [ ]  Lab 3: Log parser
- [ ]  Substack post: "From CLI Fluency to Automation 2 My First Real Bash Script"

---

## Honest Notes

_To be filled after block completion._