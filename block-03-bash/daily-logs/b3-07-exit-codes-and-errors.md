# Exit Codes and Error Handling

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 7 - Exit Codes and Error Handling
> **Skill area:** Bash

---

## What This Is

**In plain language:** Every command in Linux returns a number when it finishes - the exit code. `0` means success, anything else means failure. Right now our scripts use `exit 1` manually. This topic makes error handling systematic - scripts fail loudly and predictably instead of silently continuing through failures.

**Why it matters:** Pipelines, cron jobs, and CI/CD systems all rely on exit codes to know whether a step succeeded. A script that swallows failures and returns exit code 0 tells the scheduler everything is fine when it isn't. That's how bad data propagates silently through automated systems until something breaks much later and nobody knows why.

---

## Core Concept

**Exit codes**

```bash
ls /var/log/messages
echo $?    # 0 - success

ls /fake/path
echo $?    # 2 - no such file or directory
```

`$?` holds the exit code of the last command. Every command sets it. Use `exit 0` to signal success, `exit 1` to signal failure. Any non-zero number means failure - the specific number can indicate what kind of failure, but `1` covers most cases.

**`set -euo pipefail` - the standard safety header**

Three options combined into one line. Put this at the top of every script from now on:

```bash
#!/bin/bash
set -euo pipefail
```

What each flag does:

```bash
set -e          # exit immediately when any command returns non-zero
set -u          # exit when an undefined variable is referenced
set -o pipefail # pipeline exit code reflects the worst failure, not just the last command
```

Without these, bash runs every line regardless of what failed - silently substitutes empty strings for undefined variables, and lets pipeline failures disappear behind a succeeding last command.

**`set -e` and `if` - the gotcha you will hit**

`if` suppresses `set -e` for the command it's testing. This is intentional - `if` needs to evaluate the exit code itself. But it means a failing command inside `if` won't stop the script:

```bash
set -e

# This will NOT stop the script on failure - if suppresses set -e
if grep "error" /fake/file; then
    echo "found"
else
    echo "not found"    # prints even if /fake/file doesn't exist
fi
```

Fix: validate the file exists before putting it inside an `if`:

```bash
if [[ ! -f "$logfile" ]]; then
    echo "Error: file not found: $logfile"
    exit 1
fi

if grep "error" "$logfile"; then    # now grep only runs on a confirmed real file
    echo "found"
fi
```

**`|| true` - allow a command to fail without stopping the script**

```bash
cp /fake/file /tmp/ || true    # cp fails, || true returns 0, script continues
```

Use this when a command's failure is expected and acceptable. Without it, `set -e` would exit the script.

**`set -o pipefail` - why it matters**

Without `pipefail`, a pipeline's exit code is only the last command's code:

```bash
# Without pipefail - upstream failure is invisible
bash -c 'ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'
# Exit: 0  - cat succeeded, ls failure disappeared

# With pipefail - upstream failure is caught
bash -c 'set -o pipefail; ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'
# Exit: 2  - ls failure surfaces correctly
```

The `2>/dev/null` redirects stderr to nowhere - used here to isolate exit code behaviour. In real scripts, log that error somewhere instead of discarding it.

**Traps - guaranteed cleanup on exit**

A trap registers a command to run when the script exits - for any reason including errors, signals, and normal completion:

```bash
tmpfile=$(mktemp)                                           # create temp file
trap 'rm -f "$tmpfile"' EXIT                               # guaranteed cleanup on any exit
trap 'echo "Interrupted"; exit 1' INT                      # handle Ctrl+C
```

`EXIT` always fires last - it's the right place for cleanup. `INT` fires on Ctrl+C. If your `INT` trap calls `exit`, the `EXIT` trap then fires too - both run in sequence.

**Watch out for:**

- `set -e` combined with `if` - the `if` suppresses `set -e` for its tested command. Always validate file existence separately before using a file inside an `if` block
- `grep` returns exit code 1 when it finds no matches - with `set -e` this stops your script. Use `grep ... || true` when no matches is an acceptable outcome
- `$?` reflects the last command executed - if you run anything between the command you care about and the `echo $?`, you'll read the wrong code

---

## Drills

### Drill 1 - set -u catches undefined variables

**What I did:**
```bash
#!/bin/bash
set -euo pipefail
echo "variable: $undefined"     # referencing a variable that was never declared

./error-handling.sh             # with set -u
# comment out set -euo pipefail
./error-handling.sh             # without set -u
```

**Output:**
```
# With set -u
./error-handling.sh: line 5: undefined: unbound variable

# Without set -u
variable:
```

**What this taught me:** With `set -u` - loud failure, line number, variable name. Without it - silent empty string, script continues, no indication anything went wrong. That silent empty string is how misconfigured scripts make it to production. `set -u` makes the error visible at the exact line it occurs.

---

### Drill 2 - trap for temp file cleanup

**What I did:**
```bash
tmpfile=$(mktemp)
echo "Created temp file: $tmpfile"
trap "rm -f $tmpfile && echo 'Trap fired - temp file cleaned up'" EXIT

echo "Doing work..."
echo "results" > "$tmpfile"
cat "$tmpfile"
```

**Output:**
```
Created temp file: /tmp/tmp.Gy16LZNGAE
Doing work...
results
Trap fired - temp file cleaned up
```

**What this taught me:** The trap is registered early but fires late - on exit, not when the temp file is created. The script runs fully first, then the trap fires on the way out. The trap is a deferred cleanup guarantee, not an event listener. `cat` showed "results" correctly because the file existed at that point - deletion happened after, during exit.

---

### Drill 3 - set -e stops execution on failure

**What I did:**
```bash
set -euo pipefail

echo "Before failure"
cp /fake/nonexistent/file /tmp/     # this will fail
echo "After failure"                # this should never run
```

**Output:**
```
Before failure
cp: cannot stat '/fake/nonexistent/file': No such file or directory
```

**What this taught me:** `set -e` turns every failed command into an implicit `exit 1`. The script stops the moment `cp` returns non-zero - "After failure" never runs. Without `set -e`, bash would print the error and keep going. Tested `|| true` as a way to allow expected failures - `cp /fake/file /tmp/ || true` continues past the failure without stopping the script.

---

### Drill 4 - set -o pipefail catches upstream pipeline failures

**What I did:**
```bash
# Without pipefail - upstream failure disappears behind cat's success
bash -c 'ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'

# With pipefail - upstream failure surfaces
bash -c 'set -o pipefail; ls /fake/path 2>/dev/null | cat; echo "Exit: $?"'
```

**Output:**
```
--- Without pipefail ---
Exit: 0

--- With pipefail ---
Exit: 2
```

**What this taught me:** Without `pipefail`, the pipeline exit code is just the last command's code - `cat` succeeded so exit code is 0, `ls` failure is completely invisible. With `pipefail`, the pipeline fails if any command in it fails. The key was using `cat` as the last command (exits 0 on empty input) so it stopped masking the upstream failure. `2>/dev/null` suppresses stderr to isolate the exit code behaviour.

---

### Drill 5 - Traps for EXIT and INT

**What I did:**
```bash
tmpfile=$(mktemp)
echo "Temp file: $tmpfile"

trap 'echo "[$(date +%H:%M:%S)] $0 exiting - cleanup complete"; rm -f "$tmpfile"' EXIT
trap 'echo "[$(date +%H:%M:%S)] $0 interrupted"; exit 1' INT

echo "Working... (press Ctrl+C to interrupt)"
sleep 5
echo "done" > "$tmpfile"
cat "$tmpfile"
```

**Output:**
```
# Normal run
Temp file: /tmp/tmp.vG0oqPFugb
Working... (press Ctrl+C to interrupt)
done
[22:51:08] ./error-handling.sh exiting - cleanup complete

# Ctrl+C run
Temp file: /tmp/tmp.EjeuC1Q3Gz
Working... (press Ctrl+C to interrupt)
^C[22:51:14] ./error-handling.sh interrupted
[22:51:14] ./error-handling.sh exiting - cleanup complete
```

**What this taught me:** On the Ctrl+C run, both traps fired - `INT` first because of the interrupt, then `EXIT` because `exit 1` inside the `INT` trap triggered a script exit. `EXIT` always fires last regardless of how the script ended. This is why `EXIT` is the right place for temp file cleanup - it runs whether the script succeeds, fails, or gets killed.

---

## Lab

**Scenario:** An SRE team runs automated log checks on a schedule. The script processes log files, writes matches to a temp file, and reports results. If anything fails mid-run - bad input, missing file, pipeline failure - the script must fail loudly, clean up after itself, and return a non-zero exit code so the scheduler knows it failed.

**Task:** Create `safe-log-check.sh` using `set -euo pipefail`, input validation, a temp file with trap cleanup, grep for errors in the log, and correct exit codes throughout.

**What I built:**
```bash
#!/bin/bash
set -euo pipefail

# ─── Input Validation ───────────────────────────────────────────────
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

# ─── Variables ──────────────────────────────────────────────────────
logfilepath="$1"
tmpfile=$(mktemp)
echo "Temp file: $tmpfile"

# ─── Trap - cleanup on any exit ─────────────────────────────────────
trap 'echo "[$(date +%H:%M:%S)] $0 exiting - cleanup complete"; rm -f "$tmpfile"' EXIT

# ─── File Check ─────────────────────────────────────────────────────
# Required because if suppresses set -e - grep inside if won't stop the script
if [[ ! -f "$logfilepath" ]]; then
    echo "Error: file not found: $logfilepath"
    exit 1
fi

# ─── Grep and Report ────────────────────────────────────────────────
if grep -i "error" "$logfilepath" > "$tmpfile"; then
    echo "Errors found:"
    cat "$tmpfile"
else
    echo "No errors found"
fi

exit 0
```

**What actually happened:** First version worked for valid files and clean logs but printed "No errors found" on a fake path - wrong behaviour. `grep` was failing inside the `if` block, which suppresses `set -e`, so the script continued and treated the grep failure as "no matches". Adding an explicit file existence check before the grep block fixed it - fake path now fails loudly with a clear error message.

**The result:**
```
./safe-log-check.sh
Usage: ./safe-log-check.sh <log-file-path>

./safe-log-check.sh fake.log
Temp file: /tmp/tmp.qKJWXxAyBb
Error: file not found: fake.log
[23:17:04] ./safe-log-check.sh exiting - cleanup complete

./safe-log-check.sh test.log
Temp file: /tmp/tmp.ZJniRuaowY
Errors found:
ERROR something failed
[23:17:10] ./safe-log-check.sh exiting - cleanup complete

./safe-log-check.sh clean.log
Temp file: /tmp/tmp.pdtrM4mAki
No errors found
[23:17:20] ./safe-log-check.sh exiting - cleanup complete
```

---

## Key Takeaways

- `set -euo pipefail` goes at the top of every script from this point forward - no exceptions. It's one line that catches three categories of silent failure
- `if` suppresses `set -e` for the command it tests - always validate file existence separately before using a file inside an `if` block
- `EXIT` trap fires on every exit - success, failure, or signal. It's the correct and only place for cleanup code

## Tips

- On real SRE teams, scripts that run in cron or CI/CD pipelines must return correct exit codes - the scheduler makes decisions based on them. A script that always exits 0 is worse than useless in an automated pipeline because it masks failures
- `grep` returns exit code 1 on no matches - with `set -e` this stops your script even when finding nothing is a valid outcome. The standard fix is `grep "pattern" file || true` when no matches is acceptable
- Trap cleanup is not just good practice - it's defensive infrastructure. A script that crashes mid-run and leaves temp files, lock files, or partial writes behind can break the next run of the same script

---

#### Retain This

- [ ] Add a `TERM` trap to `safe-log-check.sh` - run it in the background with `&` and kill it with `kill $!` - confirm cleanup fires
- [ ] Search "bash set -e pitfalls" - read one post about edge cases with `set -e` and `if` blocks, there are more gotchas beyond what we hit
- [ ] Re-read the pipefail drill - run the two `bash -c` commands again until the exit code difference is automatic