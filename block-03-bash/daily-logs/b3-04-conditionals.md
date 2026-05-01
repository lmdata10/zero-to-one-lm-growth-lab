# Conditionals

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 4 - Conditionals
> **Skill area:** Bash

---

## What This Is

**In plain language:** Conditionals let a script make decisions - run this block if a condition is true, run a different block if it isn't. Without them, a script runs identically regardless of what's passed in, what exists on disk, or what failed upstream.

**Why it matters:** Scripts that run silently on bad input cause incidents. A deployment script that continues after a missing config file, or a log parser that runs against a path that doesn't exist, will produce wrong results with no error. Input validation, file existence checks, and environment guards are what separate scripts safe to run in production from scripts that aren't.

---

## Core Concept

The basic structure:

```bash
if [[ condition ]]; then
    # runs if condition is true
elif [[ other condition ]]; then
    # runs if first was false and this is true
else
    # runs if nothing above matched
fi
```

**`[[ ]]` vs `[ ]` - always use `[[ ]]`**

`[ ]` is the old POSIX test syntax. `[[ ]]` is bash-specific and safer - it handles empty variables, spaces in values, and complex expressions without breaking. On any system running bash, `[[ ]]` is correct. The only reason to use `[ ]` is portability to non-bash shells, which you're not targeting.

```bash
if [[ -f "$path" ]]; then     # correct - bash double bracket
if [ -f "$path" ]; then       # works but inconsistent - avoid
```

**Test operators - the ones you'll use repeatedly**

```bash
-f "$path"          # path exists and is a regular file
-d "$path"          # path exists and is a directory
-z "$var"           # variable is empty (zero length)
-n "$var"           # variable is not empty
$# -eq 2            # numeric equal - arg count is exactly 2
$# -ne 2            # numeric not equal
$count -gt 5        # numeric greater than
$count -lt 5        # numeric less than
$env == "prod"      # string equal
$env != "prod"      # string not equal
! -f "$path"        # negation - file does NOT exist
```

**The fail-fast pattern - every guard exits immediately on failure**

```bash
# Wrong - continues on failure, downstream runs on bad input
if [[ ! -f "$path" ]]; then
    echo "File not found"
    # no exit - script keeps running
fi

# Correct - fails fast, nothing downstream runs on bad input
if [[ ! -f "$path" ]]; then
    echo "Error: file not found: $path"
    exit 1
fi
```

The fail-fast pattern shows up in every real script. Each guard checks one thing and exits immediately on failure. The actual work only runs when every guard has passed.

**Input validation - the standard opening block**

```bash
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <log-file-path> <environment>"
    exit 1
fi
```

This goes before variables are assigned. You don't touch `$1` until you've confirmed it exists.

**Watch out for:**

- Assigning variables before validation - `basename "$1"` on an empty `$1` produces silent garbage, not an error. Validation first, variables after, always
- Missing `exit 1` on failed guards - the script continues and runs downstream blocks on bad input. Every failed guard must exit
- `|| "value"` without a full condition - `[[ $env == "prod" || "staging" ]]` is always true because `"staging"` is a non-empty string. Every `||` branch needs its own complete comparison: `$env == "prod" || $env == "staging"`

---

## Drills

### Drill 1 - Input validation on `report-header.sh`

**What I did:**
```bash
# Added $# check before variable assignment
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <log-file-path> <environment>"
    exit 1
fi

# Variables come after - not before
path="$1"
environment="$2"

./report-header.sh                          # no args
./report-header.sh /var/log/messages        # one arg
./report-header.sh /var/log/messages prod   # two args - correct
```

**Output:**
```
Usage: ./report-header.sh <log-file-path> <environment>
Usage: ./report-header.sh <log-file-path> <environment>
=============================
Report:    messages
Location:  /var/log
Generated: 2026-04-28
Environment: prod
Args passed: 2
=============================
```

**What this taught me:** The order matters - variables were initially assigned before the validation block, which meant `basename` and `dirname` were already running on an empty `$1` before the check fired. Moving validation to the top fixed it. The rule is now wired in: validate first, assign variables after.

---

### Drill 2 - File existence check with `-f`

**What I did:**
```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

path="$1"

if [[ -f "$path" ]]; then
    echo "File exists: $path"
else
    echo "File not found: $path"
fi

./check-file.sh /var/log/messages
./check-file.sh /var/log/fake.log
```

**Output:**
```
File exists: /var/log/messages
File not found: /var/log/fake.log
```

**What this taught me:** `-f` tests for a regular file specifically - not a directory, not a symlink target. A missing space inside `[[ ]]` throws a syntax error - `[[-f "$path"]]` fails, `[[ -f "$path" ]]` works. Spaces inside the brackets are not optional.

---

### Drill 3 - `elif` for directory check

**What I did:**
```bash
if [[ -f "$path" ]]; then
    echo "File exists: $path"
elif [[ -d "$path" ]]; then
    echo "Directory exists: $path"
else
    echo "Not found: $path"
fi

./check-file.sh /var/log           # directory
./check-file.sh /var/log/messages  # file
./check-file.sh /var/log/fake.log  # neither
```

**Output:**
```
Directory exists: /var/log
File exists: /var/log/messages
Not found: /var/log/fake.log
```

**What this taught me:** `elif` chains conditions - bash evaluates top to bottom and stops at the first true condition. The order matters: if you put `-d` before `-f`, a file that's also accessible as a path could match the wrong branch on some systems. File check first, then directory.

---

### Drill 4 - String comparison with `||`

**What I did:**
```bash
env="$1"

# Wrong - "staging" alone is always true (non-empty string)
if [[ $env == "prod" || "staging" || "dev" ]]; then

# Correct - each branch is a full comparison
if [[ $env == "prod" || $env == "staging" || $env == "dev" ]]; then
    echo "Valid environment: $env"
else
    echo "Error: unknown environment '$env'"
fi

./env-check.sh prod
./env-check.sh garbage
```

**Output:**
```
Valid environment: prod
Error: unknown environment 'garbage'
```

**What this taught me:** `|| "staging"` is not a comparison - it's just a non-empty string, which bash evaluates as true. Every `||` branch must be a complete condition with its own `$env ==`. Shortcutting it produces a condition that always passes, which means the validation never actually validates anything.

---

### Drill 5 - Nested `if` and prod warning

**What I did:**
```bash
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

env="$1"

if [[ $env == "prod" || $env == "staging" || $env == "dev" ]]; then
    echo "Valid environment: $env"
    if [[ $env == "prod" ]]; then         # nested if - only fires inside the valid branch
        echo "Warning: you are targeting production"
    fi
else
    echo "Error: unknown environment '$env'"
    exit 1
fi

./env-check.sh prod
./env-check.sh dev
./env-check.sh garbage
```

**Output:**
```
Valid environment: prod
Warning: you are targeting production

Valid environment: dev

Error: unknown environment 'garbage'
```

**What this taught me:** `if` blocks nest cleanly inside other `if` blocks. The prod warning only fires inside the valid environment branch - it can't produce a false positive because it only runs when the outer condition already passed.

---

## Lab

**Scenario:** Automated scripts run log checks across multiple environments on an SRE team. A script that runs silently on bad input - wrong argument count, missing file, unknown environment - produces incorrect results and potentially causes incidents. Every input must be validated before any processing begins.

**Task:** Create `validate-inputs.sh` that accepts a log file path and environment name, validates all three conditions in sequence, fails fast on any failure, and prints a clean summary only when all checks pass.

**What I built:**
```bash
#!/bin/bash
# validate-inputs.sh
# Usage: ./validate-inputs.sh <file-path> <environment>

# ─── Input Validation ───────────────────────────────────────────────
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <file-path> <environment>"
    exit 1
fi

# ─── Variables ──────────────────────────────────────────────────────
path="$1"     # assigned after validation - not before
env="$2"

# ─── File Check ─────────────────────────────────────────────────────
if [[ ! -f "$path" ]]; then           # guard on failure - not branch on success
    echo "Error: file not found: $path"
    exit 1                            # fail fast - nothing downstream runs
fi

# ─── Environment Check ──────────────────────────────────────────────
if [[ $env == "prod" || $env == "staging" || $env == "dev" ]]; then
    if [[ $env == "prod" ]]; then
        echo "Warning: you are targeting production"
    fi
else
    echo "Error: unknown environment '$env'"
    exit 1
fi

# ─── Summary - only runs if all guards passed ────────────────────────
echo "============================="
echo "File:        $path"
echo "Environment: $env"
echo "Status:      all checks passed"
echo "============================="
exit 0
```

**What actually happened:** First attempt had variables assigned before validation - same mistake as Drill 1. The file check also branched on both cases (exists/not-found) without exiting on failure, so the environment check ran even when the file was missing. Flipping to `! -f` with `exit 1` fixed it - guard on failure, continue only on success.

**The result:**
```
./validate-inputs.sh
Usage: ./validate-inputs.sh <file-path> <environment>

./validate-inputs.sh /var/log/fake.log prod
Error: file not found: /var/log/fake.log

./validate-inputs.sh /var/log/messages garbage
Error: unknown environment 'garbage'

./validate-inputs.sh /var/log/messages prod
Warning: you are targeting production
=============================
File:        /var/log/messages
Environment: prod
Status:      all checks passed
=============================
```

---

## Key Takeaways

- Validate input before touching it - `$#` check first, variables after, every time without exception
- Fail fast with `exit 1` on every guard - nothing downstream should run on bad input. The summary block only prints when everything passed
- Every `||` branch is a full independent condition - `$env ==` repeated every time, no shortcuts

## Tips

- The fail-fast pattern is how production scripts are written on real SRE teams. Each guard is a single responsibility check. If it fails, the script stops. If it passes, the next guard runs. The actual work is at the bottom - it only runs when every guard above it has cleared
- `! -f` (guard on failure) is cleaner than branching on both cases. You write one `exit 1` and move on - the script continues only on the happy path
- In production, a script that runs silently on bad input and produces wrong output is worse than a script that crashes loudly. Loud failures are debuggable. Silent wrong output causes incidents

---

#### Retain This

- [ ] Add a fourth guard to `validate-inputs.sh` - check the file is readable with `-r` - without breaking the existing guards
- [ ] Pass a directory instead of a file, an empty string as environment, and three arguments - watch exactly where each fails
- [ ] Search "bash test operators cheat sheet" - bookmark one you can reference until the operators are automatic