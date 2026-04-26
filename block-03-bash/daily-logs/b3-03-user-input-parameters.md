# User Input and Positional Parameters

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 3 - User Input
> **Skill area:** Bash

---

## The Big Picture

Hardcoded scripts are single-use tools. User input - via positional parameters or `read` - makes scripts reusable. Pass values at runtime instead of rewriting the script every time the input changes.

**Why it matters:** Health checks, log parsers, and deployment scripts all run against different services, environments, and targets. A script that only works on one hardcoded path is not a script - it's a one-time command. Parameterised scripts are the baseline expectation on any SRE or platform team.

### Anchor

**The one example that made it click:** Running `report-header.sh` with no argument - `Report:` printed blank and `Location:` printed `.` (current directory). The script ran silently with garbage output instead of failing loudly. That's worse than a crash. Input validation via `$#` is how you catch this - that lands properly in Topic 4 with conditionals.

```bash
./report-header.sh          # no argument passed
=============================
Report:
Location:  .
Generated: 2026-04-25
=============================
```

---

## Key Variables

| Variable | Value |
|---|---|
| `$0` | Script name |
| `$1`, `$2` | First and second arguments |
| `$@` | All arguments as separate words |
| `$#` | Total count of arguments passed |

---

## Practice Drills

### Drill 1 - Replace hardcoded path with $1

**What I did:**

```bash
# Changed this:
path="/var/log/messages"

# To this:
path="$1"
```

```bash
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

**What I learned:** Same script, different input, different output. Running with no argument produces blank `Report:` and `.` for location - silent garbage output. Input validation fixes this in Topic 4.

---

### Drill 2 - `$0`, `$1`, `$#`

**What I did:**

```bash
echo "Script name: $0"
echo "First argument: $1"
echo "Total arguments: $#"
```

```bash
./report-header.sh /var/log/messages /var/log/secure
```

**Output:**

```
Script name: ./report-header.sh
First argument: /var/log/messages
Total arguments: 2
```

**What I learned:** `$#` is how you validate input before the script does anything meaningful - if your script requires one argument and `$#` is 0 or 2, you exit early with a usage message. That pattern comes in Topic 4.

---

### Drill 3 - read for interactive input

**What I did:**

```bash
#!/bin/bash

read -p "Enter service name: " service_name
read -p "Enter the related environment: " env

echo "Service: $service_name | Environment: $env"
```

```bash
./input-demo.sh
Enter service name: splunk-forwarder
Enter the related environment: prod
```

**Output:**

```
Service: splunk-forwarder | Environment: prod
```

**What I learned:** `-p` prints the prompt on the same line as the cursor. Without it the script just hangs with no context. Always use `-p` with `read`.

---

### Drill 4 - $1 vs read - where conditionals become necessary

**What I did:**

Tested two clean versions separately:

```bash
# Version 1 - argument only
service_name="$1"

# Version 2 - read only
read -p "Enter service name: " service_name
```

Attempted to combine them - `read` always overwrote `$1` regardless of whether an argument was passed. Combining both correctly requires an `if` check - Topic 4.

**What I learned:** `read` always executes when reached - it has no awareness of whether `$1` was already set. Conditional fallback (`use $1 if passed, otherwise prompt`) requires `if`. That's the natural boundary between this topic and the next.

---

## Lab Assignment

**Scenario:** SRE engineers run health checks against different services across different environments. A script that only works against one hardcoded log path is useless on a real team - service and environment change every run.

**Task:** Update `report-header.sh` to accept a log file path as `$1` and an environment name as `$2`. Include both in the header output along with a total argument count for debugging.

**Steps I took:**

```bash
path="$1"
environment="$2"
arg=$#
```

Added `$environment` and `$arg` to the output block.

**What actually happened:** Straightforward application of the drill patterns. Caught a typo in the output label (`Environemnt`) before committing - fixed.

**The result:**

```bash
./report-header.sh /var/log/messages prod
=============================
Report:    messages
Location:  /var/log
Generated: 2026-04-25
Environment: prod
Args passed: 2
=============================
```

---

## Tips and Takeaways

**Remember:**

- `$1`, `$2` - positional parameters. `$#` - argument count. `$@` - all arguments. Know all four cold.
- Always use `-p` with `read` - a prompt with no context is bad UX in any script
- A script that runs silently with missing input and produces garbage output is worse than one that crashes - input validation via `$#` fixes this in Topic 4

**Common failure modes:**

- Trying to combine `$1` fallback with `read` without a conditional - `read` always overwrites. You need `if` for that pattern.
- Forgetting `$#` counts arguments only, not the script name - `$0` is the script, not counted in `$#`

**Next session:** Topic 4 - Conditionals. `if/elif/else`, test operators, and the input validation pattern that makes every script from this block production-worthy.

---

## Honest Notes

Hit the natural wall between input and conditionals exactly where expected - the `$1` fallback with `read` can't be done cleanly without `if`. Good place to stop. The silent garbage output on missing arguments was a more useful lesson than any explanation would have been.
