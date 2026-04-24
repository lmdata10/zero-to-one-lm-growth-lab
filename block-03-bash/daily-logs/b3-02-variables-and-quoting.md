# Variables and Quoting Rules

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 2 - Variables
> **Skill area:** Bash

---

## What This Session Is About

A **variable** is a named container for a value. Declare it once, reference it anywhere. The bugs come from quoting - single quotes are literal, double quotes expand variables, and no quotes breaks the moment a value contains a space.

**Why it matters in real platform/cloud/SRE work:** Every real script uses variables - log paths, dates, usernames, report filenames. Getting quoting wrong in production has deleted wrong files and broken pipelines. Quote your variables by default.

---

## Concept Anchor

**The one example that made it click:** The `rm` example - unquoted variable with a space in the value splits into two arguments and operates on the wrong targets.

```bash
file="my report.txt"
rm $file      # tries to delete 'my' and 'report.txt' - two args, wrong behaviour
rm "$file"    # correctly deletes 'my report.txt' - one arg, correct behaviour
```

And the arithmetic vs command substitution distinction - trying `$(5 + 1)` and getting `bash: 5: command not found` made it immediately clear that `$()` runs commands, `$(())` does math. They are not interchangeable.

---

## Practice Drills

### Drill 1 - Declare and reference variables

**What I did:**

```bash
#!/bin/bash

name="lm"
filename="variables.sh"
date=$(date +"%Y-%m-%d")

echo "$name"
echo "$filename"
echo "$date"
```

```bash
./variables.sh
```

**Output:**

```
lm
variables.sh
2026-04-24
```

**What I learned:** Declare without `$`, reference with `$`. No quotes needed around command substitution on assignment - quote the reference instead. Always double-quote references.

---

### Drill 2 - Single vs double quotes

**What I did:**

```bash
greeting="hello $name"
literal='hello $name'

echo "$greeting"
echo "$literal"
```

**Output:**

```
hello lm
hello $name
```

**What I learned:** Double quotes expand variables - `$name` becomes its value. Single quotes are fully literal - `$name` prints exactly as written. The declaration style controls whether expansion happens.

---

### Drill 3 - Command substitution inside a string

**What I did:**

```bash
first="platform"
second="engineering"
combined="$first $second"

echo "$combined"
echo "I am learning $combined and it is $(date +"%Y")"
```

**Output:**

```
platform engineering
I am learning platform engineering and it is 2026
```

**What I learned:** `$()` is command substitution - runs a command and drops the output inline wherever it appears. Works the same whether used on assignment or inside a string.

---

### Drill 4 - Arithmetic expansion

**What I did:**

```bash
count=5
echo "There are $count items"
echo "Next count is $((count + 1))"
echo "Double is $((count * 2))"
```

**Output:**

```
There are 5 items
Next count is 6
Double is 10
```

**What I learned:** `$(( ))` is arithmetic expansion - does math on numbers. `$( )` is command substitution - runs a command. Running `$(5 + 1)` throws `bash: 5: command not found` because bash tries to execute `5` as a command. They are not interchangeable.

---

### Drill 5 - basename and dirname

**What I did:**

```bash
path="/var/log/messages"
filename=$(basename "$path")
directory=$(dirname "$path")

echo "Full path: $path"
echo "File: $filename"
echo "Directory: $directory"
```

**Output:**

```
Full path: /var/log/messages
File: messages
Directory: /var/log
```

**What I learned:** `basename` extracts the filename from a full path. `dirname` extracts the directory. Together they let you construct new paths dynamically without hardcoding - essential for log parsers and backup scripts.

---

## Lab Assignment

**Scenario:** A sysadmin needs a reusable report header that shows the file being processed, its location, and the date the report was generated. This header will be used across multiple scripts in Block 3.

**Task:** Script called `report-header.sh` - accepts a hardcoded path, prints a formatted header block using variables only.

**Steps I took:**

```bash
#!/bin/bash

# Declare Variables
# ---------------------
path="/var/log/messages"
report=$(basename "$path")
location=$(dirname "$path")
date=$(date +"%Y-%m-%d")

echo "============================="
echo "Report: $report"
echo "Location: $location"
echo "Generated: $date"
echo "============================="
```

```bash
./report-header.sh
```

**What actually happened:** Straightforward after the drills - `basename`, `dirname`, and command substitution all applied directly. Comments added to mark the variable declaration block cleanly.

**The result:**

```
=============================
Report: messages
Location: /var/log
Generated: 2026-04-24
=============================
```

---

## Tips and Takeaways

**Remember:**

- Declare without `$`, reference with `$` - always, no exceptions
- Always double-quote variable references - `"$var"` not `$var` - spaces in values break unquoted references silently and dangerously
- `$()` runs a command, `$(())` does math - not interchangeable

**Common failure modes:**

- `name = "value"` with spaces around `=` - bash reads `name` as a command and throws an error. No spaces around `=`, ever.
- Reaching for single quotes when you need expansion - `'$var'` prints literally. If your variable isn't expanding, check your quote style first.

**Next session:** Topic 3 - User input. Positional parameters `$1 $2`, `$@`, `$#`, and `read`. The hardcoded path in `report-header.sh` becomes a real argument.

---

## Honest Notes

The quoting rules landed cleanly - the `rm "$file"` vs `rm $file` example made the risk concrete. The `$()` vs `$(())` distinction didn't click from explanation alone - running `$(5 + 1)` and getting `command not found` made it stick immediately. Breaking things on purpose is faster than reading about them.
