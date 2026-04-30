# Variables and Quoting Rules

> **Block:** Block 3 - Bash Scripting
> **Topic:** Topic 2 - Variables
> **Skill area:** Bash

---

## Concept: The Big Picture -[or a better header maybe]

A **variable** is a named container for a value. You store something once, reference it many times. Change it in one place, it updates everywhere it's used.

**Why it matters:** Every real script uses variables - log paths, dates, usernames, report filenames. Getting quoting wrong in production has deleted wrong files and broken pipelines. Quote your variables by default.

```bash
name="rocky"
echo $name        # rocky
```

Three things that trip everyone up immediately:

**1. No spaces around `=`**

```bash
name="rocky"      # correct
name = "rocky"    # wrong - bash reads this as a command called 'name'
```


**2. Referencing vs declaring**

Declare without `$`. Reference with `$`.

```bash
logfile="health.log"    # declaring - no $
echo $logfile           # referencing - needs $
```

**3. Quoting - this is where real bugs live**

| Style | Behaviour |
|---|---|
| `"double"` | Variables expand inside - `"$name"` gives the value |
| `'single'` | Everything literal - `'$name'` prints `$name` |
| No quotes | Works until it doesn't - breaks on spaces and special characters |

The rule: **always double-quote variable references.** `"$variable"` not `$variable`. The difference is invisible until a value contains a space - then unquoted variables break in ways that are hard to debug.

```bash
file="my report.txt"
rm $file          # tries to delete 'my' and 'report.txt' - two args
rm "$file"        # correctly deletes 'my report.txt' - one arg
```

That bug has deleted wrong files in production. Quote your variables.


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

**Task:**
- Script called `report-header.sh`
- Accepts a full file path as a variable inside the script (hardcode `/var/log/messages` for now -**    ** Topic 3 covers arguments)
- Prints a formatted header block using only variables and what you've covered today
- Output looks something like this:

```
=============================
Report: messages
Location: /var/log
Generated: 2026-04-24
=============================
```

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

Clean. Comments, correct quoting, right output. Nothing to fix.

That header is a reusable component - you'll drop it into the log parser in a few topics when it matters.

---

### Key Takeaways

- Declare without `$`, reference with `$` - always
- Always double-quote variable references - `"$var"` not `$var` - spaces in values will break unquoted variables in ways that are hard to debug
- Single quotes are literal, double quotes expand - know which one you're reaching for
- `$()` is command substitution - runs a command. `$(())` is arithmetic - does math. They are not interchangeable
- `basename` and `dirname` let you pull apart file paths without hardcoding - use them any time you're building paths dynamically

### Tips

- The most common beginner bug: `name = "value"` with spaces around `=`. Bash reads `name` as a command. No spaces, ever.
- Experienced practitioners quote everything by default and only drop quotes when they have a specific reason. Unquoted variables are a liability in production scripts.

---

> Homework: Practice mnore learn about his [ ] to get a hold of concept in your memory - mental model - practice makes things stick for longer run, develop hands on skills and knoweledge - don't just watch - apply for a few minutes then forget
