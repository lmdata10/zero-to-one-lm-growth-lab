# Conditionals

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 4 - Conditionals
> **Skill area:** Bash

---

## What This Session Is About

**Conditionals** let a script make decisions - run this block if a condition is true, run a different block if it isn't. Without conditionals, a script runs identically regardless of what's passed in, what exists, or what failed.

**Why it matters:** Scripts that run silently on bad input cause incidents. Input validation, file existence checks, and environment guards are the difference between a script that's safe to run in production and one that isn't. Every real automation script on an SRE team starts with guards.

---

## Concept Anchor

**The one example that made it click:** Flipping the file check from branching on exists/not-found to failing fast with `! -f` and `exit 1`. Without `exit 1` on each failed guard, the script kept running downstream - printing a valid environment confirmation after reporting a missing file. Fail fast means nothing downstream runs on bad input.

```bash
if [[ ! -f "$path" ]]; then
    echo "Error: file not found: $path"
    exit 1
fi
```

---

## Syntax Reference

```bash
if [[ condition ]]; then
    # do this
elif [[ other condition ]]; then
    # do this instead
else
    # fallback
fi
```

**Use `[[ ]]` always** - bash-specific, safer than `[ ]`, handles empty variables and spaces without breaking.

| Operator | Tests |
|---|---|
| `-z "$var"` | Variable is empty |
| `-n "$var"` | Variable is not empty |
| `-f "$path"` | File exists and is a regular file |
| `-d "$path"` | Directory exists |
| `-eq` | Numeric equal |
| `-ne` | Numeric not equal |
| `-gt` | Numeric greater than |
| `-lt` | Numeric less than |
| `==` | String equal |
| `!=` | String not equal |
| `\|\|` | Or - each branch needs its own full condition |

---

## Practice Drills

### Drill 1 - Input validation on [report-header.sh](/block-03-bash/scripts/report-header.sh)

**What I did:** Added `$#` check before variable assignment. Tested with 0, 1, and 2 arguments.

**Key mistake caught:** Validation was placed after variables - `basename` and `dirname` were already running on an empty `$1` before the check fired. Validation must be first, variables after.

**Output:**

```
./report-header.sh
Usage: ./report-header.sh <log-file-path> <environment>

./report-header.sh /var/log/messages
Usage: ./report-header.sh <log-file-path> <environment>

./report-header.sh /var/log/messages prod
=============================
Report:    messages
Location:  /var/log
Generated: 2026-04-28
Environment: prod
Args passed: 2
=============================
```

**What I learned:** Variables must be assigned after validation - never touch `$1` before confirming it exists. `exit 1` stops execution immediately and signals failure to whatever called the script.

---

### Drill 2 - File existence check with -f

**What I did:** Created `check-file.sh` using `-f` to test whether a path is a regular file.

**Key mistake caught:** Missing space inside `[[ ]]` - `[[-f "$path"]]` throws a syntax error. Bash requires spaces inside the brackets: `[[ -f "$path" ]]`.

**Output:**

```
./check-file.sh
Usage: ./check-file.sh <log-file-path>

./check-file.sh /var/log/messages
File exists: /var/log/messages

./check-file.sh /var/log/fake.log
File not found: /var/log/fake.log
```

**What I learned:** `-f` checks for a regular file. Always space inside `[[ ]]` - no exceptions.

---

### Drill 3 - elif for directory check

**What I did:** Added `elif [[ -d "$path" ]]` to `check-file.sh` to handle directory paths.

**Output:**

```
./check-file.sh /var/log
Directory exists: /var/log

./check-file.sh /var/log/messages
File exists: /var/log/messages

./check-file.sh /var/log/fake.log
File not found: /var/log/fake.log
```

**What I learned:** `elif` chains conditions cleanly - bash evaluates top to bottom and stops at the first true condition.

---

### Drill 4 - String comparison with ||

**What I did:** Created `env-check.sh` - validates that the argument is one of `prod`, `staging`, or `dev`.

**Key mistake caught:** `[[ $env == "prod" || "staging" || "dev" ]]` - `|| "staging"` is always true because a non-empty string is truthy. Every `||` branch needs its own complete condition: `$env == "prod" || $env == "staging" || $env == "dev"`.

**Output:**

```
./env-check.sh prod
Valid environment: prod

./env-check.sh garbage
Error: unknown environment 'garbage'
```

**What I learned:** Each `||` branch is a full independent condition - `$env ==` must be repeated every time. Shortcutting it produces a condition that's always true.

---

### Drill 5 - Nested if and input validation

**What I did:** Added `$#` validation and a nested `if` inside `env-check.sh` to warn on prod.

**Output:**

```
./env-check.sh
Usage: ./env-check.sh <environment>

./env-check.sh prod
Valid environment: prod
Warning: you are targeting production

./env-check.sh dev
Valid environment: dev
```

**What I learned:** `if` blocks nest cleanly. Prod warning fires only inside the valid environment branch - no false positives.

---

## Lab Assignment

**Scenario:** Automated scripts on an SRE team run against log files across multiple environments. A script that runs silently on bad input - wrong argument count, missing file, unknown environment - causes incidents. Every input must be validated before any processing happens.

**Task:** `validate-inputs.sh` - accepts a log file path and environment name, validates all three conditions in sequence, fails fast on any failure, prints a clean summary only when all checks pass.

**Steps I took:** Built the validation sequence - `$#` first, file check second, environment check third. Initial version assigned variables before validation and didn't exit on file-not-found, letting downstream blocks run on bad input.

**Key mistakes corrected:**
- Variables assigned before validation - moved to after `$#` check
- File-not-found branch continued execution - flipped to `! -f` with `exit 1` to fail fast

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

## Tips and Takeaways

**Remember:**

- Validate input before touching it - `$#` check first, variables after, always
- Fail fast with `exit 1` on every guard - nothing downstream should run on bad input
- `[[ ]]` not `[ ]` - always, and always space inside the brackets

**Common failure modes:**

- Assigning variables before validation - `basename`/`dirname` run on empty strings before the check fires
- Missing `exit 1` on failed guards - script continues and runs downstream blocks on bad input
- `|| "value"` without a full condition - always evaluates true, validation never catches bad input

**Next session:** Topic 5 - Loops. `for`, `while`, `until`, `break`, `continue`. The `$@` pattern from Topic 3 finally gets its loop.

---

## Honest Notes

The fail-fast pattern took two attempts to land - the instinct to branch on both cases (exists/not-found) instead of guarding on the failure case and continuing only on success. Once the `! -f` flip clicked, the structure made sense. Variables-before-validation was a repeat mistake from Topic 3 - it's now wired in as a rule not a guideline.

---

