# Functions

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 6 - Functions
> **Skill area:** Bash

---

## What This Is

**In plain language:** A function is a named block of code you define once and call anywhere in the script. Instead of copy-pasting the same validation logic into three places, you write it once and call it three times. Change the logic once - it updates everywhere it's called.

**Why it matters:** On a real platform team, validation logic, file checks, and environment guards get reused across multiple scripts. Functions make that reuse clean and maintainable. A script whose main body reads as a sequence of function calls is also dramatically easier for a teammate to understand, debug, and modify than a 200-line wall of inline logic.

---

## Core Concept

**Defining and calling a function**

```bash
print_header() {            # define - function name followed by ()
    echo "============================="
    echo "$1"               # $1 inside the function is the function's first argument
    echo "============================="
}

print_header "System Check"    # call - no parentheses when calling
```

Functions have their own `$1`, `$2`, `$@`, `$#` - separate from the script's positional parameters. What you pass to the function is what it sees.

**Return codes - not return values**

Bash functions don't return values like Python or other languages. They return an exit code - 0 for success, non-zero for failure.

```bash
check_file() {
    if [[ -f "$1" ]]; then
        return 0    # success
    fi
    return 1        # failure
}

# Check the return code directly in an if statement
if check_file "/var/log/messages"; then
    echo "file found"
else
    echo "file not found"
fi
```

The `if function_name "arg"; then` pattern evaluates the return code directly - cleaner than capturing `$?` separately. Use `$?` only when you need to check the code outside of an `if` block.

**Getting actual output out of a function**

Return codes are for success/failure only. To get a value out of a function, `echo` inside and capture with command substitution outside:

```bash
get_filename() {
    echo $(basename "$1")    # echo the result - don't return it
}

name=$(get_filename "/var/log/messages")    # capture with $()
echo "$name"    # messages
```

**`local` variables - always use them inside functions**

Variables in bash are global by default. Without `local`, a variable set inside a function leaks into the rest of the script and can silently overwrite something the main script depends on.

```bash
counter() {
    local count=0       # local - only exists inside this function
    count=$((count + 1))
    echo "$count"
}

counter
echo "$count"    # empty - count never existed in the main script's scope
```

Think of a function as a room with a door. `local` variables only exist inside the room. When the function returns, they're gone. Without `local`, the variable escapes and lives in the main script - where it can quietly cause bugs that are very hard to trace.

**Define before you call**

Bash reads top to bottom. If you call a function before defining it, bash throws an error. Define all functions at the top of the script, main logic at the bottom.

**Watch out for:**

- Forgetting `local` - function variable silently overwrites a same-named variable in the main script. This causes bugs where a value changes unexpectedly and you can't figure out why
- Checking `$?` after another command has already run - `$?` always reflects the last command executed, not the one you intended. Use `if function_name; then` instead
- Calling a function before defining it - bash reads top to bottom, define first, call after

---

## Drills

### Drill 1 - Basic function with argument

**What I did:**
```bash
print_header() {
    echo "============================="
    echo "$1"               # $1 is whatever is passed when the function is called
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

**What this taught me:** One function definition, two calls with different arguments, different output each time. That's the reusability point - write once, use anywhere. No parentheses when calling.

---

### Drill 2 - Return codes and direct if pattern

**What I did:**
```bash
check_file() {
    if [[ -f "$1" ]]; then
        return 0    # success - file exists
    fi
    return 1        # failure - file not found
}

# Direct if pattern - evaluates return code without capturing $?
if check_file "/var/log/messages"; then
    echo "file found"
else
    echo "file not found"
fi

if check_file "/var/log/fake"; then
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

**What this taught me:** Functions return exit codes - 0 for success, non-zero for failure. `if check_file "/path"; then` evaluates the return code directly and is cleaner than storing it in `$?` first. The `else` branch is not optional - a function that signals failure with no code acting on it is only half the logic.

---

### Drill 3 - Getting output out of a function

**What I did:**
```bash
get_filename() {
    echo $(basename "$1")   # echo the result - $() captures it outside
}

name=$(get_filename "/var/log/messages")    # command substitution captures the echo
echo "$name"
```

**Output:**
```
messages
```

**What this taught me:** Return codes are for success/failure only - they can't carry a string value. To get a string out of a function, `echo` it inside and capture with `$()` outside. This is the standard pattern in bash and shows up everywhere once you start writing reusable function libraries.

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

**What this taught me:** The validation logic from Topic 4 packaged as a reusable function - now any script can call `validate_env "$env"` instead of repeating the `if [[ ]]` block inline. This is why functions exist: write the logic once, call it from anywhere.

---

### Drill 5 - local variable scope

**What I did:**
```bash
counter() {
    local count=0           # local - stays inside this function
    while [[ $count -lt 3 ]]; do
        count=$((count + 1))
        echo "$count"
    done
}

counter
echo "Outside function: $count"    # $count doesn't exist here
```

**Output:**
```
1
2
3
Outside function:
```

**What this taught me:** `local` keeps variables inside the function - they don't exist in the main script's scope. Without `local`, `count` would leak out and potentially overwrite a variable of the same name in the main script. Always use `local` for variables inside functions. The empty line after "Outside function:" confirms `count` was never set in the main scope.

---

## Lab

**Scenario:** The `validate-inputs.sh` from Topic 4 has all validation logic written inline. On a real platform team, that logic needs to be reusable across multiple scripts. Refactor it into functions so the validation is portable and the main script body reads as a clear sequence of steps.

**Task:** Rewrite `validate-inputs.sh` using four functions - `validate_args`, `validate_file`, `validate_env`, `print_summary`. Main script body is four function calls in sequence. No inline logic outside functions except variable assignment.

**What I built:**
```bash
#!/bin/bash
# validate-inputs-functions.sh
# Usage: ./validate-inputs-functions.sh <file-path> <environment>

# ─── validate_args ──────────────────────────────────────────────────
validate_args() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <file-path> <environment>"
        exit 1
    fi
}

# ─── validate_file ──────────────────────────────────────────────────
validate_file() {
    local path="$1"             # local - doesn't leak into main script
    if [[ ! -f "$path" ]]; then
        echo "Error: file not found: $path"
        exit 1
    fi
}

# ─── validate_env ───────────────────────────────────────────────────
validate_env() {
    local env="$1"
    if [[ "$env" == "prod" || "$env" == "staging" || "$env" == "dev" ]]; then
        if [[ "$env" == "prod" ]]; then
            echo "Warning: you are targeting production"
        fi
    else
        echo "Error: unknown environment '$env'"
        exit 1
    fi
}

# ─── print_summary ──────────────────────────────────────────────────
print_summary() {
    local path="$1"
    local env="$2"
    echo "============================="
    echo "File:        $path"
    echo "Environment: $env"
    echo "Status:      all checks passed"
    echo "============================="
}

# ─── Main - four function calls, no inline logic ─────────────────────
validate_args "$@"      # pass all script args so $# inside the function is correct

path="$1"
env="$2"

validate_file "$path"
validate_env "$env"
print_summary "$path" "$env"
```

**What actually happened:** Clean first attempt. The key decision was `validate_args "$@"` - passing `"$@"` forwards the script's arguments into the function so `$#` inside the function sees the same count the script received. Without that, `$#` inside the function would be 0.

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

## Key Takeaways

- Always `local` for variables inside functions - global by default in bash, leaks cause bugs that are very hard to trace
- Return codes only - 0 success, non-zero failure. Use `echo` + `$()` to get actual string output out of a function
- Define functions before the main script body - bash reads top to bottom, calling before defining throws an error

## Tips

- A script whose main body is a sequence of clearly named function calls is self-documenting. `validate_args`, `validate_file`, `validate_env`, `print_summary` - anyone reading that main block understands what the script does before reading a single function body
- On a real team, common validation functions live in a shared library file that gets sourced by other scripts: `source /opt/scripts/lib/validation.sh`. The functions you write here are the foundation of that pattern
- `if function_name "arg"; then` is the idiomatic bash pattern. Avoid capturing `$?` separately unless you specifically need to check it outside an `if` block - it's easy to accidentally overwrite `$?` with an intermediate command

---

> **Now do something with this.** Take `validate_file` and add a second check inside it - verify the file is also readable with `-r`. Then create a new script that sources a shared function file instead of defining the functions inline: write the four functions into a file called `lib.sh` and use `source ./lib.sh` at the top of a new script to load them. That's the pattern used in real ops script libraries.