# Functions

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 6 - Functions
> **Skill area:** Bash

---

## What This Session Is About

A **function** is a named block of code you define once and call anywhere in the script. Instead of copy-pasting the same validation logic into three places, you write it once and call it three times. Functions also keep variables contained with `local` - without it, variables leak into the rest of the script and cause hard-to-find bugs.

**Why it matters:** Validation logic, file checks, and environment guards get reused across multiple scripts on a real platform team. Functions make that reuse clean - change the logic once, it updates everywhere it's called. A script whose main body reads as a sequence of function calls is also much easier for a teammate to understand and maintain.

---

## Concept Anchor

**The one example that made it click:** The `local` variable scope drill - declaring `local count=0` inside a function, incrementing it to 3, then trying to print it outside. The variable was empty outside the function. The analogy: a function is a room with a door - `local` variables only exist inside the room. Without `local`, variables leak out and silently change values the rest of the script depends on.

```bash
counter() {
    local count=0
    while [[ $count -lt 3 ]]; do
        count=$((count + 1))
        echo "$count"
    done
}

counter
echo "Outside function: $count"    # prints nothing - count is local
```

---

## Key Patterns

```bash
# Define
my_function() {
    local var="$1"    # always local inside functions
    echo "$var"
}

# Call - no parentheses
my_function "argument"

# Capture output
result=$(my_function "argument")

# Check return code directly
if my_function "argument"; then
    echo "success"
fi
```

---

## Practice Drills

### Drill 1 - Basic function with argument

**What I did:**

```bash
print_header() {
    echo "============================="
    echo "$1"
    echo "============================="
}

print_header "System Health Check"
print_header "Log Report"
```

**Output:**

```
=============================
System Health Check
=============================
=============================
Log Report
=============================
```

**What I learned:** One function, two calls, different output each time - reusability in practice. No parentheses when calling a function.

---

### Drill 2 - Return codes and $?

**What I did:**

```bash
check_file() {
    if [[ -f "$1" ]]; then
        return 0
    fi
    return 1
}

check_file "/var/log/messages"
if [[ $? -eq 0 ]]; then
    echo "file found"
else
    echo "file not found"
fi
```

**Output:**

```
file found
file not found
```

**What I learned:** Bash functions return exit codes only - 0 for success, non-zero for failure. `$?` holds the exit code of the last command. The cleaner pattern is `if check_file "/path"; then` - evaluates the exit code directly without capturing `$?` separately.

---

### Drill 3 - Capturing function output

**What I did:**

```bash
get_filename() {
    echo $(basename "$1")
}

name=$(get_filename "/var/log/messages")
echo "$name"
```

**Output:**

```
messages
```

**What I learned:** To get actual output from a function, `echo` inside and capture with command substitution outside. Return codes are for success/failure signalling only.

---

### Drill 4 - validate_env with direct if pattern

**What I did:**

```bash
validate_env() {
    if [[ "$1" == "prod" || "$1" == "staging" || "$1" == "dev" ]]; then
        return 0
    else
        return 1
    fi
}

if validate_env "prod"; then
    echo "valid env: prod"
else
    echo "invalid env: prod"
fi

if validate_env "garbage"; then
    echo "valid env: garbage"
else
    echo "invalid env: garbage"
fi
```

**Output:**

```
valid env: prod
invalid env: garbage
```

**What I learned:** `if function_name "arg"; then` evaluates the return code directly - cleaner than capturing `$?`. The `else` branch handles the failure case - a function that returns a code with nothing acting on the failure is only half the logic.

---

### Drill 5 - local variable scope

**What I did:**

```bash
counter() {
    local count=0
    while [[ $count -lt 3 ]]; do
        count=$((count + 1))
        echo "$count"
    done
}

counter
echo "Outside function: $count"
```

**Output:**

```
1
2
3
Outside function:
```

**What I learned:** `local` keeps variables inside the function - they don't exist outside it. Without `local`, variables are global by default and leak into the rest of the script, silently changing values other parts of the script depend on. Always use `local` for variables inside functions.

---

## Lab Assignment

**Scenario:** The `validate-inputs.sh` from Topic 4 has all validation logic written inline. On a real platform team, validation logic gets reused across multiple scripts. Refactor it into functions so the logic is portable and the main script body reads as a clear sequence of steps.

**Task:** Rewrite `validate-inputs.sh` with four functions - `validate_args`, `validate_file`, `validate_env`, `print_summary`. Main script body is four function calls in sequence. No inline logic outside functions except variable assignment.

**Steps I took:** Extracted each validation block into its own function with `local` variables. Passed `"$@"` to `validate_args` so `$#` inside the function counts the script's arguments correctly. Assigned `path` and `env` from `$1` and `$2` after argument validation, then passed them explicitly to each subsequent function.

**What actually happened:** Clean first attempt. Structure was correct - main body reads as a sequence of steps with no inline logic.

**The result:**

```
./validate-inputs-functions.sh /var/log/messages prod
Warning: you are targeting production
=============================
File:        /var/log/messages
Environment: prod
Status:      all checks passed
=============================

./validate-inputs-functions.sh /var/log/messages garbage
Error: unknown environment 'garbage'
```

---

## Tips and Takeaways

**Remember:**

- Always `local` for variables inside functions - global by default in bash, leaks cause bugs
- Return codes only - 0 success, non-zero failure. Use `echo` + command substitution to get actual output out
- `if my_function "arg"; then` - evaluate return code directly, cleaner than checking `$?` separately

**Common failure modes:**

- Forgetting `local` - function variable silently overwrites a same-named variable in the main script
- Checking `$?` after another command has already run - `$?` always reflects the last command, not the one you think
- Calling a function before defining it - bash reads top to bottom, define functions before the main script body calls them

**Next session:** Topic 7 - Exit codes and error handling. `set -e`, `set -u`, `set -o pipefail`, and traps. The scripts you've built become genuinely safe to run in production.

---

## Honest Notes

The `local` scope concept needed a plain-language breakdown before it clicked - the room analogy landed immediately after. Lab was a clean first attempt once the function structure from the drills was clear. The main body reading as four function calls is a meaningful shift from how the script looked in Topic 4.
