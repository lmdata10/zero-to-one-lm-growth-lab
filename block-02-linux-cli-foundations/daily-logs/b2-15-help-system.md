# Help System - man, --help, apropos, tldr

**Block:** Block 2 - Linux CLI Foundations
**Topic:** Help System - `man`, `--help`, `apropos`, `tldr`
**Filename:** `b2-15-help-system.md`
**Path:** `block-02-linux-cli/daily-logs/b2-15-help-system.md`

---

## The Big Picture

The best admins aren't the ones who memorize everything - they're the ones who find answers fast without leaving the terminal. Every command on a Linux system is documented. Four tools, four use cases:

- `--help` - quick flag summary, one screen, no pager. First stop when you need a flag reminder.
- `tldr` - practical examples for common use cases. Fastest path when you want a working command, not a manual.
- `man` - full authoritative reference. Use when you need to understand a command fully or find an obscure option.
- `apropos` - searches man page descriptions by keyword. Use when you don't know the command name.

### Quick Reference

| Command | When to use |
|---|---|
| `command --help` | need a flag reminder fast |
| `command --help 2>&1 \| grep pattern` | find a specific flag without reading everything |
| `tldr command` | need a working example immediately |
| `man command` | need full reference or an obscure option |
| `man N command` | read a specific section - `man 5 passwd` for file format |
| `man -k keyword` | same as `apropos` - search by keyword |
| `apropos keyword` | find commands when you don't know the name |
| `whatis command` | one-line description and section numbers |

### Man page sections

| Section | Contents |
|---|---|
| 1 | User commands - things you run in the shell |
| 2 | System calls - kernel interface (C programming) |
| 3 | Library functions (C programming) |
| 5 | File formats and configuration files |
| 8 | System administration commands |

Sections 1, 5, and 8 cover everything in this curriculum.

### Man page navigation

| Key | Action |
|---|---|
| `g` | jump to top |
| `G` | jump to bottom |
| `/pattern` | search forward |
| `n` | next match |
| `q` | quit |

---

## Learning by Doing

### Drill 1 - Navigate a man page

**What I ran:**

```bash
man ls
man ls | grep -A2 "human"
```

**Output:**

```
       -h, --human-readable
              with -l and -s, print sizes like 1K 234M 2G etc.
```

**What I learned:** Man pages follow a standard structure - NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, FILES, SEE ALSO. OPTIONS is where you spend most time. SYNOPSIS shows command syntax at a glance. SEE ALSO surfaces related commands worth knowing. `-A2` in grep shows 2 lines after each match - essential for reading flag descriptions that span multiple lines below the flag name.

---

### Drill 2 - Use --help and compare to man

**What I ran:**

```bash
ls --help | head -20
tar --help 2>&1 | head -20
```

**Output:**

```
Usage: ls [OPTION]... [FILE]...
  -a, --all     do not ignore entries starting with .
  -h, --human-readable  ...

Usage: tar [OPTION...] [FILE]...
Examples:
  tar -cf archive.tar foo bar
  tar -tvf archive.tar
  tar -xf archive.tar
```

**What I learned:** `--help` prints to stdout and exits immediately - no pager, easy to pipe and grep: `tar --help 2>&1 | grep compress`. `man` opens in a pager - better for reading, harder to grep inline. Some commands like `tar` include examples at the top of `--help` output - faster than `man` or `tldr` when they do. `2>&1` redirects stderr to stdout - some commands print help to stderr, this ensures it's capturable.

---

### Drill 3 - Search for commands with apropos

**What I ran:**

```bash
apropos "disk usage"
apropos "compress"
apropos "user" | grep -i "add\|create"
```

**Output:**

```
quota (1)       - display disk usage and limits
quotacheck (8)  - scan a filesystem for disk usage...
bunzip2 (1)     - a block-sorting file compressor
gzip (1)        - compress or expand files
...
useradd (8)     - create a new user or update default new user information
adduser (8)     - create a new user or update default new user information
```

**What I learned:** `apropos` searches man page NAME and DESCRIPTION sections and returns everything matching the keyword. Use it when you know what you want to do but not the command name. The numbers in parentheses are man page section numbers - `(1)` is a user command, `(8)` is a system admin command, `(5)` is a file format. When a name appears in multiple sections like `passwd (1)` and `passwd (5)`, they are different manual pages - the command vs the file format.

---

### Drill 4 - Install and use tldr

**What I ran:**

```bash
tldr tar
tldr find
```

**Output:**

```
tar
  - [c]reate a g[z]ipped archive and write it to a [f]ile:
    tar czf path/to/target.tar.gz path/to/file1 path/to/file2 ...
  - E[x]tract a (compressed) archive [f]ile into the current directory:
    tar xvf path/to/source.tar[.gz|.bz2|.xz]

find
  - Find files by extension:
    find path/to/directory -name '*.ext'
  - Find files matching a given size range:
    find path/to/directory -maxdepth 1 -size +500k -size -10M
```

**What I learned:** `tldr` cuts straight to common use cases with real command examples - no paging, no dense prose. The help workflow in order: need a flag reminder → `--help`, need a working example → `tldr`, need full reference → `man`, don't know the command → `apropos`.

---

### Drill 5 - Man sections and whatis

**What I ran:**

```bash
whatis passwd
man 5 passwd | head -20
whatis ls
whatis crontab
```

**Output:**

```
passwd (1)    - change user password
passwd (5)    - password file

passwd(5) - File Formats Manual
The /etc/passwd file is a text file that describes user login accounts...

ls (1)        - list directory contents

crontab (1)   - maintains crontab files for individual users
crontab (5)   - files used to schedule the execution of programs
```

**What I learned:** `whatis` searches only the NAME section of man pages and returns a one-line description - exact match only. `apropos` searches full descriptions and casts a wider net. `man 5 passwd` gets the file format documentation specifically - when a name exists in multiple sections, specify the section number to get the right page. `crontab (1)` is the command, `crontab (5)` is the file syntax - both useful, different purposes.

---

## Lab: Putting It Together

**Task:** Find network interface commands with apropos. Run whatis on three Block 2 commands with multiple sections. Find tar verbose flag using only man or --help. Use tldr to find find command for .log files modified in last 7 days. Read man 5 fstab to find what the fifth field controls. Count archive-related man pages with a one-liner.

**What I did:**

```bash
# network interface commands
apropos "network interface"

# whatis on multiple-section commands
whatis kill
whatis mount
whatis hostname

# tar verbose flag
man tar | grep verbose
tar --help | grep verbose

# find .log files modified in last 7 days
tldr find | grep -A2 "modified"
find / -type f -name "*.log" -mtime -7 2>/dev/null

# fstab fifth field
man 5 fstab | grep -A4 -i "fifth field"

# count archive-related commands
apropos "archive" | wc -l
```

**Output (key lines):**

```
ifconfig (8)  - configure a network interface
nameif (8)    - name network interfaces based on MAC addresses

kill (1)      - terminate a process
kill (2)      - send signal to a process
mount (2)     - mount filesystem
mount (8)     - mount a filesystem
hostname (1)  - show or set the system's host name
hostname (5)  - Local hostname configuration file
hostname (7)  - hostname resolution description

-v, --verbose   verbosely list files processed

The fifth field (fs_freq).
    This field is used by dump(8) to determine which
    filesystems need to be dumped. Defaults to zero (don't dump).

25
```

**Outcome:** All tasks completed.

**Errors hit:** `find` task asked for `.log` files specifically - ran `find . -type f -mtime -7` without `-name "*.log"`. Concept correct, filter missing.

**How I resolved it:** Full correct command:
```bash
find / -type f -name "*.log" -mtime -7 2>/dev/null
```

**Key distinction learned:** `whatis` is exact match, one-line result. `apropos` is keyword search across descriptions, returns everything related. Use `whatis` to confirm a command exists and see its sections. Use `apropos` when you're exploring and don't know what you're looking for yet.

`grep -A2` and `grep -A4` for context lines around matches - the practical way to read man pages without paging through everything.

---

## What Stuck With Me

- **Four tools, four use cases.** `--help` for flags, `tldr` for examples, `man` for full reference, `apropos` for discovery.
- **Man page sections 1, 5, 8.** Commands, file formats, admin commands. Specify section when a name has multiple pages.
- **`whatis` vs `apropos`.** Exact name match vs keyword search across descriptions.
- **`grep -A N` for context.** Flag descriptions span multiple lines - grep alone misses them without `-A`.
- **`2>&1` to capture help output.** Some commands write `--help` to stderr - redirect to capture and pipe it.
- **`man 5` for config file syntax.** `man 5 fstab`, `man 5 passwd`, `man 5 crontab` - file format documentation lives in section 5.

---

## Tips from Session

- When grepping man pages for a flag, use `-A2` or `-A4` to get the description lines below the match - the flag name alone is useless without the explanation.
- `apropos` returns a lot of noise on broad keywords - pipe to `grep` to narrow it down: `apropos "user" | grep -i "add\|create"`.

---

> **Carry Forward:** `man` and `--help` used as first reference throughout all remaining blocks - never Google a flag when the answer is one command away. `man 5 crontab` referenced in Block 3 Topic 11 scheduling. `apropos` useful when exploring unfamiliar territory in Block 4 and beyond.