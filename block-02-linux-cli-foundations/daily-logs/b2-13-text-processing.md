# Text Processing — cut, awk, sed

**Block:** Block 2 - Linux CLI Foundations
**Topic:** Text Processing - `cut`, `awk`, `sed`
**Filename:** `b2-13-text-processing.md`
**Path:** `block-02-linux-cli/daily-logs/b2-13-text-processing.md`

---

## The Big Picture

`grep` finds text. These three tools reshape it. In real admin work you're constantly pulling structured output — logs, `/etc/passwd`, command output — and need specific fields, transformed values, or substitutions. All three read from stdin or a file, write to stdout, and chain with pipes. They don't modify source files unless explicitly told to.

`cut` — extracts columns from structured text. Fast, single purpose. Use when the delimiter and field number are fixed.

`awk` — pattern-action language. Reads line by line, splits into fields, filters and reformats. Use when you need conditions, math, or multiple fields in custom order.

`sed` — stream editor. Applies edits line by line — substitutions, deletions, insertions. The substitute command `s/old/new/g` covers 90% of real use.

### Quick Reference

| Command | What it does |
|---|---|
| `cut -d: -f1,3 file` | extract fields 1 and 3, colon delimited |
| `cut -d' ' -f3-` | extract field 3 to end of line |
| `awk -F: '{print $1, $3}' file` | print fields 1 and 3, colon delimited |
| `awk -F: '$3 >= 1000 {print $1}' file` | filter by field value, print matching |
| `$NF` | last field in awk — NF = number of fields |
| `sed 's/old/new/' file` | substitute first match per line |
| `sed 's/old/new/g' file` | substitute all matches per line |
| `sed -i 's/old/new/' file` | in-place edit — modifies file on disk |
| `sed -i.bak 's/old/new/' file` | in-place edit with backup |
| `sed '2d' file` | delete line 2 |
| `sed '/pattern/d' file` | delete all lines matching pattern |
| Use `\|#` as delimiter | avoid escaping `/` in paths: `sed 's\|/old/\|/new/\|g'` |

---

## Learning by Doing

### Drill 1 — Extract fields with cut

**What I ran:**

```bash
cut -d: -f1,3 /etc/passwd | head -10
echo "2026-04-20 ERROR disk full on /dev/sda" | cut -d' ' -f3-
```

**Output:**

```
root:0
bin:1
daemon:2
...
disk full on /dev/sda
```

**What I learned:** `-d` sets the delimiter, `-f` specifies fields. `-f1,3` pulls fields 1 and 3 specifically. `-f3-` means field 3 to end of line — the trailing `-` means "everything from here to end." Useful when the message portion is variable length and you just want the tail. `-f1-3` is a range (fields 1 through 3). `-f1,3` is specific fields (1 and 3 only).

---

### Drill 2 — Filter and reformat with awk

**What I ran:**

```bash
awk -F: '{print $1, $3}' /etc/passwd | head -10
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd
echo "2026-04-20 ERROR disk full on /dev/sda" | awk '{print $2, $NF}'
```

**Output:**

```
root 0
bin 1
...
nobody 65534
student 1000
test2 1002

ERROR /dev/sda
```

**What I learned:** `-F` sets the field separator — same concept as `-d` in cut. Default separator is whitespace. `$1`, `$2`, `$3` reference fields by position. `$NF` is the last field — `NF` is a built-in awk variable for the total number of fields, so `$NF` always resolves to the last one regardless of line width. The condition `$3 >= 1000` before `{print}` filters — only lines where field 3 meets the condition execute the action block. UIDs below 1000 are system accounts, 1000+ are human users.

---

### Drill 3 — Substitute and delete with sed

**What I ran:**

```bash
echo "server=localhost" | sed 's/localhost/prod-db-01/'
sed 's/\/sbin\/nologin/\/bin\/bash/g' /etc/passwd | grep -v "^#" | cut -d: -f1,7 | head -5
echo -e "line1\nline2\nline3" | sed '2d'
```

**Output:**

```
server=prod-db-01
root:/bin/bash
bin:/bin/bash
...
line1
line3
```

**What I learned:** `s/old/new/g` — `s` is substitute, first `/` opens pattern, `old` is what to match, second `/` separates pattern from replacement, `new` is replacement, third `/` closes, `g` is global flag (all matches per line, not just first). Without `g`, sed stops at the first match per line. Forward slash inside the pattern needs escaping with `\` because `/` is the sed delimiter — or use an alternate delimiter: `sed 's|/sbin/nologin|/bin/bash|g'` is cleaner. `2d` deletes line 2. `/pattern/d` deletes all lines matching pattern.

---

### Drill 4 — In-place edit with sed -i

**What I ran:**

```bash
echo "server=localhost" > /tmp/sed-test.conf
sed -i 's/prod/staging/' /tmp/sed-test.conf
cat /tmp/sed-test.conf
```

**Output:**

```
server=staging
port=8080
```

**What I learned:** `-i` writes changes directly back to the file on disk — every other sed command prints to stdout and leaves the source untouched. `-i` is the exception. It's silent — no confirmation, no warning if the pattern matches nothing. Safe habit: `sed -i.bak 's/old/new/' file` creates a `.bak` backup before editing. Without `g`, only the first match per line changes — `prod-db prod-app` on one line would only change `prod-db`.

---

## Lab: Putting It Together

**Task:** Extract bash users from passwd with cut. Print username, UID, home dir for UID >= 1000 with awk. Create a config file, edit in-place with sed, delete lines by pattern. Build a one-liner to count shell usage across the system.

**What I did:**

```bash
# username and shell, filtered to /bin/bash only
cut -d: -f1,7 /etc/passwd | grep '/bin/bash'

# username, UID, home dir for UID >= 1000
awk -F: '$3 >= 1000 {print $1, $3, $6}' /etc/passwd

# create config file
cat <<EOF > /tmp/lab-config.conf
HOST=web01.example.com
PORT=8080
ENV=staging
DB_HOST=db01.example.com
DB_PORT=5432
EOF

# replace hostname in-place
sed -i 's/web01/mail/' /tmp/lab-config.conf
cat /tmp/lab-config.conf

# delete lines containing "example"
sed '/example/d' /tmp/lab-config.conf

# count shells in use — two approaches
awk -F: '{print $7}' /etc/passwd | grep '/' | sed 's#.*/##' | sort | uniq -c

# cleaner version without grep
awk -F/ '{print $NF}' /etc/passwd | sort | uniq -c
```

**Output (key lines):**

```
root:/bin/bash
student:/bin/bash

nobody 65534 /
student 1000 /home/student
test2 1002 /home/test2

HOST=mail.example.com
PORT=8080
ENV=staging
DB_HOST=db01.example.com
DB_PORT=5432

PORT=8080
ENV=staging
DB_PORT=5432

3 bash
1 halt
32 nologin
1 shutdown
1 sync
```

**Outcome:** All tasks completed.

**Errors hit:** None.

**Key distinction learned:** First task required filtering with `grep '/bin/bash'` after `cut` — `cut` extracts fields, it doesn't filter. Two tools for two jobs, piped together.

On the shell count one-liner — `sed 's#.*/##'` uses `#` as the sed delimiter to avoid escaping forward slashes, matches everything up to the last `/` and removes it, leaving just the binary name. `awk -F/ '{print $NF}'` does the same more cleanly by splitting on `/` and printing the last field. When two approaches work, reach for the more readable one.

`sort` before `uniq -c` is required — `uniq` only counts consecutive identical lines, so unsorted input gives wrong counts.

---

## What Stuck With Me

- **`cut` extracts, `awk` filters and reformats, `sed` edits.** Different tools, different jobs — chain them when needed.
- **`$NF` in awk is always the last field.** Doesn't matter how many fields there are — `$NF` adapts to line width.
- **`sed -i` modifies the file on disk.** Every other sed invocation is read-only. `-i.bak` to create a backup before editing.
- **`g` flag in sed — all matches per line, not just first.** Without it, sed stops after the first match.
- **Use alternate delimiters in sed to avoid escaping paths.** `s|/old/path|/new/path|g` is cleaner than `s/\/old\/path/\/new\/path/g`.
- **`sort` before `uniq -c`.** `uniq` only counts consecutive identical lines — unsorted input gives wrong counts.

---

## Tips from Session

- When sed substitution produces no change, check that the pattern actually exists in the file — sed runs silently with no matches. No error, no warning, no output difference.
- Alternate sed delimiters (`|`, `#`, `,`) are not special syntax — any character after `s` becomes the delimiter. Use whichever avoids escaping in your specific pattern.

---

> **Carry Forward:** `awk` for log parsing used directly in Block 3 log parser script. `sed -i` for config file manipulation in Block 3 user provisioning script and Block 4 SSH hardening. `cut` and `awk` pipelines reused throughout Block 4 when processing command output.