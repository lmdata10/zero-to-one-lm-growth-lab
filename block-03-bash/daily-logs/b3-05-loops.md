# Loops

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 5 - Loops
> **Skill area:** Bash

---

## What This Session Is About

**Loops** run the same block of code repeatedly - over a list of items, while a condition is true, or until a condition is met. They're what turns a script that handles one thing into a script that handles any number of things.

**Why it matters:** No real automation script operates on a single hardcoded target. Log checks, service health checks, deployment scripts - all run against multiple targets. Loops are how you write one script that scales to any number of inputs without rewriting it.

---

## Concept Anchor

**The one example that made it click:** The `$@` loop pattern - finally completing the Drill 5 that couldn't be done in Topic 3 without loops. Any number of arguments, processed one at a time, with a counter tracking position.

```bash
count=1
for path in "$@"; do
    echo "$count: $path"
    count=$((count + 1))
done
```

```bash
./loop-demo.sh /var/log/messages /var/log/secure /var/log/dnf.log
1: /var/log/messages
2: /var/log/secure
3: /var/log/dnf.log
```

---

## Loop Types

| Loop | Use when |
|---|---|
| `for` | You know what you're iterating over - a list, `$@`, a range |
| `while` | You don't know how many iterations - waiting for a condition, reading a file |
| `until` | Opposite of while - runs until condition becomes true. Use `while` with negation instead if it reads cleaner |

---

## Practice Drills

### Drill 1 - for loop over a list

**What I did:**

```bash
for env in prod staging dev; do
    echo "$env"
done
```

**Output:**

```
prod
staging
dev
```

**What I learned:** `do` opens the loop body, `done` closes it - everything between runs on each iteration.

---

### Drill 2 - for loop with counter

**What I did:**

```bash
count=1
for env in prod staging dev; do
    echo "$count: $env"
    ((count++))
done
```

**Output:**

```
1: prod
2: staging
3: dev
```

**What I learned:** `((count++))` is shorthand for `count=$((count + 1))` - both valid, less typing.

---

### Drill 3 - while loop

**What I did:**

```bash
count=1
while [[ $count -lt 6 ]]; do
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

**What I learned:** `-lt 6` works but `-le 5` reads more naturally for "count to 5" - variable names and operators should reflect intent clearly for whoever reads the script next.

---

### Drill 4 - for loop over $@

**What I did:**

```bash
count=1
for path in "$@"; do
    echo "$count: $path"
    count=$((count + 1))
done
```

```bash
./loop-demo.sh /var/log/messages /var/log/secure /var/log/dnf.log
```

**Output:**

```
1: /var/log/messages
2: /var/log/secure
3: /var/log/dnf.log
```

**What I learned:** `"$@"` quoted handles arguments with spaces correctly. Loop variable named `path` not `env` - variable names should reflect what they contain.

---

### Drill 5 - break and continue

**What I did:**

```bash
for num in 1 2 3 4 5 6; do
    if [[ $num -eq 3 ]]; then
        continue    # skip 3, jump to next iteration
    fi
    if [[ $num -eq 5 ]]; then
        break       # stop loop entirely at 5
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

**What I learned:** `continue` skips the rest of the current iteration and moves to the next. `break` exits the loop entirely - nothing after it in the loop runs. Both require an `if` check inside the loop to trigger conditionally.

---

## Lab Assignment

**Scenario:** An SRE team checks multiple log files every shift. Instead of running a script once per file, one script accepts any number of paths, validates each exists, and prints a status line per file. Missing files are flagged and skipped - processing continues on the rest.

**Task:** `multi-log-check.sh` - accepts any number of log file paths, validates at least one was passed, loops over all of them, prints OK or MISSING per file, prints a summary at the end.

**Steps I took:** Input validation with `-eq 0` to catch no arguments. Initialised `total` and `missing` counters before the loop. Incremented `total` on every iteration, `missing` only on file-not-found. Summary printed after the loop with `exit 0`.

**What actually happened:** Clean first attempt - structure was correct, counters in the right place, output matched expected.

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

## Tips and Takeaways

**Remember:**

- `"$@"` quoted - always. Unquoted breaks on arguments with spaces
- Initialise counters before the loop, not inside it - variables reset on every iteration if declared inside
- `continue` skips the current iteration, `break` exits the loop - both need an `if` check to trigger

**Common failure modes:**

- Forgetting `done` - loop never closes, script hangs or throws a syntax error
- Incrementing the wrong counter inside the loop - `total` goes inside the loop body for every path, `missing` only inside the else branch
- Using `[ ]` instead of `[[ ]]` - works but inconsistent with the rest of the block

**Next session:** Topic 6 - Functions. Defining reusable blocks of logic, calling them, passing arguments, returning values. The validation patterns from Topics 3 and 4 become reusable functions.

---

## Honest Notes

Loops landed cleanly - the `$@` pattern made immediate sense after Topic 3 set up the need for it. `break` and `continue` needed an explanation before the drill but clicked immediately once the walk-through showed what each iteration does. Lab was a clean first attempt - Topics 3 and 4 patterns combined directly.