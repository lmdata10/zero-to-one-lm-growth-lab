# Loops

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 5 - Loops
> **Skill area:** Bash

---

## What This Is

**In plain language:** Loops run the same block of code repeatedly - over a list of items, while a condition is true, or until a condition is met. They turn a script that handles one thing into a script that handles any number of things without duplicating code.

**Why it matters:** No real automation script operates on a single hardcoded target. Log checks, service health checks, deployment scripts - all run against multiple targets. A script without loops either works on one thing or has the same code copy-pasted ten times. Neither is acceptable on a platform team.

---

## Core Concept

**`for` - iterate over a known list**

```bash
for item in one two three; do   # 'item' takes each value in turn
    echo "$item"                # runs once per item in the list
done                            # marks end of loop body
```

Use `for` when you know what you're iterating over - a list of values, file paths, `$@`.

**`for` with `$@` - the pattern you'll use constantly**

```bash
for path in "$@"; do        # "$@" - all script arguments, one at a time
    echo "Processing: $path"
done
```

`"$@"` quoted handles arguments with spaces correctly. Unquoted `$@` breaks silently when any argument contains a space - always quote it.

**`while` - run while a condition is true**

```bash
count=1
while [[ $count -le 5 ]]; do   # keeps running as long as count is 5 or less
    echo "Count: $count"
    count=$((count + 1))        # increment - without this, infinite loop
done
```

Use `while` when you don't know how many iterations upfront - waiting for a service to come up, reading a file line by line, retrying until success.

**`until` - run until a condition becomes true**

Opposite of `while`. Less common - usually clearer to write `while` with a negated condition instead. Mentioned here so you recognise it.

**`break` and `continue` - control mid-loop**

```bash
for num in 1 2 3 4 5 6; do
    if [[ $num -eq 3 ]]; then
        continue    # skip the rest of this iteration - jump to next num
    fi
    if [[ $num -eq 5 ]]; then
        break       # exit the loop entirely - 6 never runs
    fi
    echo "$num"
done
# output: 1 2 4
```

Both require an `if` check inside the loop to trigger conditionally. `break` and `continue` without a condition would always fire on the first iteration.

**Counters inside loops**

```bash
count=1                         # initialise BEFORE the loop - not inside it
for item in "$@"; do
    echo "$count: $item"
    count=$((count + 1))        # or: ((count++)) - same thing, less typing
done
```

Initialise counters before the loop. A variable declared inside the loop body resets on every iteration.

**Watch out for:**

- Forgetting `done` - the loop never closes and the script throws a syntax error or hangs
- Not incrementing the counter in a `while` loop - produces an infinite loop that you have to kill with Ctrl+C
- Unquoted `"$@"` - breaks silently on arguments with spaces, one of the most common subtle bugs in shell scripts

---

## Drills

### Drill 1 - for loop over a list with counter

**What I did:**
```bash
count=1
for env in prod staging dev; do
    echo "$count: $env"
    ((count++))             # shorthand for count=$((count + 1))
done
```

**Output:**
```
1: prod
2: staging
3: dev
```

**What this taught me:** `do` opens the loop body, `done` closes it - everything between runs once per item. `((count++))` and `count=$((count + 1))` are equivalent - `((count++))` is shorter and common in real scripts.

---

### Drill 2 - while loop counting to 5

**What I did:**
```bash
count=1
while [[ $count -le 5 ]]; do   # -le 5 reads as "less than or equal to 5"
    echo "Count: $count"
    count=$((count + 1))
done
```

**Output:**
```
Count: 1
Count: 2
Count: 3
Count: 4
Count: 5
```

**What this taught me:** `-le 5` reads more naturally than `-lt 6` for "count to 5" - both work but the intent is clearer with `-le`. Also: if you forget `count=$((count + 1))` the loop runs forever. Always check that your `while` condition will eventually become false.

---

### Drill 3 - for loop over $@

**What I did:**
```bash
count=1
for path in "$@"; do        # "$@" - each argument passed to the script
    echo "$count: $path"
    count=$((count + 1))
done

./loop-demo.sh /var/log/messages /var/log/secure /var/log/dnf.log
```

**Output:**
```
1: /var/log/messages
2: /var/log/secure
3: /var/log/dnf.log
```

**What this taught me:** This is the drill that couldn't be completed in Topic 3 - `$@` needs a loop to be useful. The variable is named `path` not `env` because it holds file paths - variable names should always reflect what they contain. Anyone reading the script should understand what the loop variable represents without having to trace it back.

---

### Drill 4 - break and continue

**What I did:**
```bash
for num in 1 2 3 4 5 6; do
    if [[ $num -eq 3 ]]; then
        continue    # skip 3 - jump straight to 4
    fi
    if [[ $num -eq 5 ]]; then
        break       # stop the loop - 6 never runs
    fi
    echo "$num"
done
```

**Output:**
```
1
2
4
```

**What this taught me:** Walking through manually made it click - 1 and 2 print normally, 3 hits `continue` and jumps to 4, 4 prints, 5 hits `break` and the loop stops entirely, 6 is never reached. Both `break` and `continue` need an `if` check - without one, the first iteration would always trigger them.

---

## Lab

**Scenario:** An SRE team checks multiple log files every shift. Running one script per file doesn't scale. One script should accept any number of log file paths, check each one exists, report status per file, and print a summary at the end. Missing files get flagged - processing continues on the rest.

**Task:** Create `multi-log-check.sh` that accepts any number of log file paths as arguments, validates at least one was passed, loops over all of them, prints `OK` or `MISSING` per file, and prints a summary showing total checked and total missing.

**What I built:**
```bash
#!/bin/bash
# multi-log-check.sh
# Usage: ./multi-log-check.sh <log_file1> <log_file2> ...

# ─── Input Validation ───────────────────────────────────────────────
if [[ $# -lt 1 ]]; then                     # at least one argument required
    echo "Usage: $0 <log_file1> <log_file2> ..."
    exit 1
fi

# ─── Variables ──────────────────────────────────────────────────────
total=0      # initialised before the loop - resets would break the count
missing=0

# ─── File Check Loop ────────────────────────────────────────────────
for path in "$@"; do
    if [[ -f "$path" ]]; then
        echo "OK: $path"
    else
        echo "MISSING: $path"
        missing=$((missing + 1))     # only increments on failure
    fi
    total=$((total + 1))             # increments on every iteration
done

# ─── Summary ────────────────────────────────────────────────────────
echo "============================="
echo "Total Files Checked: $total"
echo "Total Files Missing: $missing"
echo "============================="
exit 0
```

**What actually happened:** Clean first attempt. The key structural decision was where to increment the counters - `total` goes inside the loop body after both branches so it counts every file regardless of outcome. `missing` goes only inside the `else` branch so it counts only failures.

**The result:**
```
./multi-log-check.sh /var/log/messages /var/log/fake.log /var/log/secure
OK: /var/log/messages
MISSING: /var/log/fake.log
OK: /var/log/secure
=============================
Total Files Checked: 3
Total Files Missing: 1
=============================
```

---

## Key Takeaways

- `for` when you know the list, `while` when you're waiting for a condition - pick the right tool for the job
- Always initialise counters before the loop, not inside it - variables inside the loop body reset on every iteration
- `"$@"` quoted - always. This is not a style preference, it's correctness. Unquoted breaks on arguments with spaces

## Tips

- The `for path in "$@"` pattern is one of the most reused patterns in real ops scripts. Any time you need to process multiple targets - files, servers, services - this is the structure. Learn it until it's automatic
- In production scripts, continue processing after a failure when the task is reporting or checking - like this log checker. Exit immediately on failure when the task is modifying or deploying - you don't want to apply a broken config to 10 servers because the first one failed silently
- Counter placement inside loops is a common source of off-by-one errors. Always ask: should this increment on every iteration, or only on specific ones?

---

#### Retain This

- [ ] Add a `-r` readable check to `multi-log-check.sh` alongside the existing `-f` check - test with a `chmod -r` file
- [ ] Rewrite the `while` loop from Drill 2 as a `for` loop and the `for` loop from Drill 3 as a `while` loop
- [ ] Search "bash for loop vs while loop" - read one short post that explains when each is the right choice