# User Input and Positional Parameters

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 3 - User Input
> **Skill area:** Bash

---

## What This Is

**In plain language:** Hardcoded scripts are single-use tools. User input - via positional parameters or `read` - makes scripts reusable. Instead of editing the script every time the input changes, you pass values in at runtime and the script handles them.

**Why it matters:** On a real SRE or platform team, health checks, log parsers, and deployment scripts run against different services, environments, and targets every time. A script that only works on one hardcoded path is not automation - it's a glorified note. Parameterised scripts are the baseline expectation.

---

## Core Concept

When you run a script with arguments, bash automatically assigns them to numbered variables called positional parameters:

```bash
./script.sh /var/log/messages prod

# Inside the script:
$0    # the script name itself - ./script.sh
$1    # first argument - /var/log/messages
$2    # second argument - prod
$@    # all arguments as separate items - "/var/log/messages" "prod"
$#    # count of arguments passed - 2
```

These are available anywhere in the script without declaring them. You just reference them.

**`read` - interactive input while the script runs**

Sometimes you want the script to prompt the user instead of requiring arguments upfront:

```bash
read -p "Enter service name: " service_name
# -p prints the prompt on the same line as the cursor
# without -p the cursor just sits there with no context - always use -p
echo "Service: $service_name"
```

**`$@` - the pattern you'll use constantly**

`$@` gives you all arguments as separate items. Combined with a loop (Topic 5), it's how you write one script that processes any number of targets:

```bash
for path in "$@"; do        # "$@" quoted - handles spaces in filenames correctly
    echo "Processing: $path"
done
```

Always quote `"$@"`. Unquoted, it breaks when any argument contains a space.

**`$#` - validate before you process**

`$#` is how you catch missing input before the script does anything:

```bash
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <log-file-path> <environment>"
    exit 1
fi
```

Check argument count first. If wrong - print usage showing exactly what's expected, exit with code 1. This pattern appears in every real script.

**Watch out for:**

- Using `$1` before checking `$#` - if no argument was passed, `$1` is empty and commands like `basename "$1"` produce silent garbage output, not an error
- `read` always executes when reached - it has no awareness of whether `$1` was already set. Combining them requires a conditional - that's Topic 4
- Forgetting `-p` on `read` - the script hangs with no prompt and the user has no idea what's expected

---

## Drills

### Drill 1 - Replace hardcoded path with $1

**What I did:**
```bash
# Changed the hardcoded variable in report-header.sh
path="/var/log/messages"    # before - hardcoded, single use
path="$1"                   # after - takes whatever is passed at runtime

./report-header.sh /var/log/messages
./report-header.sh /var/log/secure
```

**Output:**
```
=============================
Report:    messages
Location:  /var/log
Generated: 2026-04-25
=============================

=============================
Report:    secure
Location:  /var/log
Generated: 2026-04-25
=============================
```

**What this taught me:** Same script, different input, different output - that's what parameterisation means in practice. Running it with no argument produced blank `Report:` and `.` for location - silent garbage. That's what input validation is for, and exactly why `$#` gets checked before anything touches `$1`.

---

### Drill 2 - `$0`, `$1`, `$#`

**What I did:**
```bash
# Added debug lines to report-header.sh temporarily
echo "Script name: $0"
echo "First argument: $1"
echo "Total arguments: $#"

./report-header.sh /var/log/messages /var/log/secure
```

**Output:**
```
Script name: ./report-header.sh
First argument: /var/log/messages
Total arguments: 2
```

**What this taught me:** `$0` is the script name - not counted in `$#`. `$#` counts only the arguments passed after the script name. This matters when writing validation - if your script needs 2 arguments, check `$# -ne 2`, not `$# -ne 3`.

---

### Drill 3 - read for interactive input

**What I did:**
```bash
#!/bin/bash

read -p "Enter service name: " service_name      # prompts inline, stores input
read -p "Enter the related environment: " env    # same pattern

echo "Service: $service_name | Environment: $env"

./input-demo.sh
# Enter service name: splunk-forwarder
# Enter the related environment: prod
```

**Output:**
```
Service: splunk-forwarder | Environment: prod
```

**What this taught me:** `-p` is not optional in practice - without it the script just hangs silently and the user has no idea what to type. Always write prompts that tell the user exactly what's expected.

---

### Drill 4 - `$1` vs `read` - the wall that conditionals fix

**What I did:**
```bash
# Attempted to combine $1 with a read fallback
service_name="${1:-}"                          # use $1 if set, empty if not
read -p "Enter service name: " service_name   # always runs - overwrites $1
```

**Output:**
```
# read always prompted even when $1 was passed - $1 was overwritten every time
```

**What this taught me:** `read` executes unconditionally when bash reaches it. It doesn't check whether `$1` was already set. The correct fallback pattern - use the argument if passed, otherwise prompt - requires an `if` check. This is exactly why Topic 4 exists.

---

## Lab

**Scenario:** SRE engineers run report headers against different log files across different environments every shift. A hardcoded script means editing code every time the target changes. The script needs to accept both the log path and the environment as runtime arguments.

**Task:** Update `report-header.sh` to accept a log file path as `$1` and an environment name as `$2`. Include both in the header output. Add argument count for debugging.

**What I built:**
```bash
#!/bin/bash
# report-header.sh
# Usage: ./report-header.sh <log-file-path> <environment>

# ─── Variables ──────────────────────────────────────────────────────
path="$1"
report=$(basename "$path")       # filename only from full path
location=$(dirname "$path")      # directory only from full path
date=$(date +"%Y-%m-%d")         # current date - YYYY-MM-DD format
environment="$2"                 # prod / staging / dev
arg=$#                           # total args passed - feeds validation in Topic 4

# ─── Output ─────────────────────────────────────────────────────────
echo "============================="
echo "Report:      $report"
echo "Location:    $location"
echo "Generated:   $date"
echo "Environment: $environment"
echo "Args passed: $arg"
echo "============================="
```

**What actually happened:** Straightforward application of `$1` and `$2` to existing variables. The `arg=$#` line was added knowing it would feed the validation check coming in Topic 4. No errors.

**The result:**
```
./report-header.sh /var/log/messages prod
=============================
Report:      messages
Location:    /var/log
Generated:   2026-04-25
Environment: prod
Args passed: 2
=============================
```

---

## Key Takeaways

- `$1`, `$2` are the arguments. `$#` is the count. `$@` is all of them. Know all four without thinking.
- Always validate `$#` before touching `$1` - using `$1` before confirming it exists produces silent garbage, not an error
- `read` always runs when reached - combining it with a `$1` fallback requires a conditional

## Tips

- Usage messages are the first thing an engineer reads when a script fails. Write them to show exactly what's expected: `Usage: $0 <log-file-path> <environment>` - not just `Usage: $0 <args>`
- `"$@"` quoted is the correct pattern for passing all arguments forward - to a function, a loop, another script. Unquoted `$@` breaks silently on arguments with spaces and is one of the most common sources of subtle bugs in shell scripts
- Scripts that are self-documenting - clear usage messages, descriptive variable names, inline comments - are the ones that get reused by the team instead of rewritten every time

---

> **Now do something with this.** Run `report-header.sh` with no arguments, one argument, and three arguments. Watch what happens each time. Then go manually add a `$#` check before Topic 4 covers it - try to make the script fail loudly with a usage message instead of silently. You won't write it perfectly yet but the attempt will make Topic 4 click faster when it arrives.