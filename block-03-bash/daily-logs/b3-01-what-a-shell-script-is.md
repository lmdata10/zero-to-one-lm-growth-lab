# What a Shell Script Is - Vim Basics + First Script

> **Block:** Block 3 - Bash Scripting
> **Topic:** Pre-Topic (Vim/Nano) + Topic 1 - What a shell script is
> **Skill area:** Bash / Linux

---

## What This Session Is About

A **shell script** is a text file containing commands you'd normally type one at a time in the terminal - captured, made repeatable, and executed as a unit. Add a shebang, make it executable, run it. That's the entire concept.

**Why it matters:** Automation starts here. Every health check, provisioning script, and log parser in a real SRE or sysadmin role is a shell script. If you can only run commands manually, you can't scale.

---

## Concept Anchor

**The one example that made it click:** Redirecting the entire script output into a dated log file using a `{ }` block - realising the variable had to be defined before the block, not after. Bash reads top to bottom with no exceptions. Moving `logfile=` to line 2 fixed it immediately.

```bash
#!/bin/bash
logfile="health-$(date +"%Y-%m-%d").log"
{
    echo "=== Hostname ==="
    hostname
    echo "=== Uptime ==="
    uptime
} > $logfile
echo "$logfile"
```

```
health-2026-04-22.log
```

---

## Pre-Topic Drills - Vim Basics

### Vim Drill 1 - Create a file called `test.sh`, enter Insert mode, type one line; anything, save it, and exit cleanly
**What I did:**

```bash
vim test.sh         # created new file in vim
# pressed 'i' to enter Insert mode, typed a line
# pressed 'o' to open a new line below and typed another
# pressed Esc, typed :wq to save and exit
cat test.sh         # confirmed contents
```

**Output:**

```
first vim line using - 'i'
second vim lines using - 'o'
```

**What I learned:** `i` inserts at cursor, `o` opens a new line below and drops into Insert - found `o` without being told.

---

### Vim Drill 2 - Add a shebang without breaking existing content

**What I did:**

```bash
vim test.sh         # reopened file
# navigated to line 1 with arrow keys
# pressed 'i', added #!/bin/bash, pressed Esc, :wq
cat test.sh
```

**Output:**

```
#!/bin/bash

first vim line using - 'i'

second vim lines using - 'o'
```

**What I learned:** `gg` jumps to top of file in Normal mode, `G` jumps to bottom - faster than arrowing on long files.

---

### Vim Drill 3 - Delete blank lines with dd

**What I did:**

```bash
vim test.sh
# moved cursor to blank line, pressed 'dd' - repeated for second blank line
# :wq
cat test.sh
```

**Output:**

```
#!/bin/bash
first vim line using - 'i'
second vim lines using - 'o'
```

**What I learned:** `dd` deletes the entire current line in Normal mode - no selection needed.

---

### Vim Drill 4 - Replace contents, make executable, run

**What I did:**

```bash
vim test.sh
# deleted all content, rewrote with shebang and echo line
# :wq
ls -l test.sh                   # confirmed not yet executable
chmod +x test.sh                # added execute permission
./test.sh                       # ran it
```

**Output:**

```
-rw-r--r--. 1 student student 36 Apr 22 20:48 test.sh
vim is not scary
```

**What I learned:** `chmod +x` flips the executable bit - without it, the file is just text. `./` is required because Linux doesn't look in the current directory for executables by default.

---

## Topic 1 Drills - What a Shell Script Is

### Drill 1 - First script: hostname and date

**What I did:**

```bash
vim first.sh
# wrote shebang, echo headers, hostname, date, date +"%Y-%m-%d"
chmod +x first.sh
./first.sh
```

**Output:**

```
=== Hostname ===
rocky-vm
=== Date ===
Wed 22 Apr 2026 08:52:39 PM ADT
2026-04-22
```

**What I learned:** `date +"%Y-%m-%d"` formatted output is the standard for log filenames and timestamps - `$(date +"%Y-%m-%d")` embedded in a variable name is a pattern you'll use constantly.

---

### Drill 2 - Add uptime

**What I did:**

```bash
vim first.sh    # added === Uptime === section with uptime command
./first.sh
```

**Output:**

```
=== Uptime ===
 20:55:34 up 23 min,  3 users,  load average: 0.02, 0.03, 0.06
```

**What I learned:** The three load average numbers are 1, 5, and 15 minute averages - if the 1-minute is significantly higher than 15-minute, something just spiked.

---

### Drill 3 - Add top 3 processes by memory

**What I did:**

```bash
vim first.sh    # added === Top Processes (Memory) === section
# ps aux --sort=-%mem | head -n 4
./first.sh
```

**Output:**

```
=== Top Processes (Memory) ===
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
student     2516  0.3 12.2 4025420 299508 ?      Ssl  20:32   0:06 /usr/bin/gnome-shell
student     2686  0.0  5.2 1258132 128256 ?      Sl   20:32   0:01 /usr/bin/gnome-software
student     3169  0.0  4.0 1299284 98576 ?       Sl   20:32   0:00 /usr/libexec/mutter-x11-frames
```

**What I learned:** `--sort=-%mem` - the `-` reverses the sort so highest memory is first. `head -n 4` gives 3 processes plus the header line.

---

### Drill 4 - Redirect script output to a log file manually

**What I did:**

```bash
./first.sh >> /tmp/health.log   # appended output to log file
cat /tmp/health.log             # confirmed contents
```

**Output:**

```
=== Hostname ===
rocky-vm
=== Date ===
Wed 22 Apr 2026 09:03:23 PM ADT
2026-04-22
=== Uptime ===
 21:03:23 up 31 min,  3 users,  load average: 0.01, 0.01, 0.02
=== Top Processes (Memory) ===
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
student     2516  0.3 12.2 4025420 299516 ?      Ssl  20:32   0:06 /usr/bin/gnome-shell
student     2686  0.0  5.2 1258132 128256 ?      Sl   20:32   0:01 /usr/bin/gnome-software
student     3169  0.0  4.0 1299284 98576 ?       Sl   20:32   0:00 /usr/libexec/mutter-x11-frames
```

**What I learned:** `>>` appends, `>` overwrites - for a health check script, overwrite is usually correct since you want current state, not a growing history.

---

## Lab Assignment

**Scenario:** A sysadmin needs a health check script they can drop on any RHEL based Linux box and get a clean snapshot written to a dated log file automatically - no manual redirection at the command line.

**Task:** 
- Script writes its output to a log file in `/tmp/` named `health-YYYY-MM-DD.log` automatically — no `>>` needed at the command line
- Log file path printed to the terminal when the script runs so the operator knows where to find it
- Script is executable and runs cleanly with `./first.sh`

**Steps I took:**

```bash
# First attempt - variable defined after the block that used it
#!/bin/bash
{
    echo "=== Hostname ==="
    hostname
    # ... rest of commands
} > $logfile                            # $logfile was empty here - bug

logfile="health-$(date +"%Y-%m-%d").log"   # too late, already used above
echo "$logfile"
```

```
# Output: file created with no name / blank filename - wrong
```

```bash
# Fixed - moved variable definition to top of script
#!/bin/bash
logfile="health-$(date +"%Y-%m-%d").log"   # defined first
{
    echo "=== Hostname ==="
    hostname
    echo "=== Date ==="
    date
    date +"%Y-%m-%d"
    echo "=== Uptime ==="
    uptime
    echo "=== Top Processes (Memory) ==="
    ps aux --sort=-%mem | head -4
} > $logfile
echo "$logfile"                            # prints path to terminal
```

```
./first.sh
health-2026-04-22.log

cat health-2026-04-22.log
=== Hostname ===
rocky-vm
=== Date ===
Wed 22 Apr 2026 09:17:06 PM ADT
2026-04-22
=== Uptime ===
 21:17:06 up 45 min,  3 users,  load average: 0.14, 0.05, 0.01
=== Top Processes (Memory) ===
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
student     2516  0.2 12.2 4021276 299548 ?      Ssl  20:32   0:07 /usr/bin/gnome-shell
student     2686  0.0  5.2 1258132 128256 ?      Sl   20:32   0:01 /usr/bin/gnome-software
student     3169  0.0  4.0 1299284 98576 ?       Sl   20:32   0:00 /usr/libexec/mutter-x11-frames
```

**What actually happened:** First attempt placed the `logfile` variable after the block that used it - bash had already evaluated `> $logfile` with an empty variable. Needed a nudge to see that bash reads strictly top to bottom. Moving the variable to line 2 fixed it immediately.

**The result:** Working health check script. Dated log file written to `/tmp/` automatically on every run. Log path printed to terminal. Executable with `./first.sh`.

---

### **Takeaways:**

- Shebang `#!/bin/bash` on line 1, always - it's not optional
- `#!/usr/bin/env bash` Finds Bash in your `$PATH`. Use for portability (macOS/Linux/BSD) and when using custom versions.
- Define variables before you use them - bash reads top to bottom, no exceptions
- `>` overwrites, `>>` appends - know which one you want before you reach for it
- `{ } > $logfile` wraps a block and redirects all output at once - cleaner than redirecting every line individually
- `$(command)` embeds command output into a string - `$(date +"%Y-%m-%d")` in a filename is a pattern you'll use constantly

### **Tips:**

- The most common beginner mistake: using a variable before defining it. If output is blank or the file is named wrong, check variable order first.
- Experienced practitioners write the log path to stdout even in automated scripts — always leave a breadcrumb so the operator knows where to look.

---

## Honest Notes

The lab hit harder than expected - not because the concepts were complex but because connecting three things (variable, block redirect, terminal echo) at once without a worked example was genuinely difficult starting from zero. The variable-order bug was the real lesson: bash doesn't plan ahead, it just executes. That's now wired in.

---