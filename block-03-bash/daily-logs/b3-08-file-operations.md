# Working with Files

> **Block:** Block 3 — Bash Scripting 
> **Topic:** Topic 8 — Working with Files 
> **Skill area:** Bash

---

## What This Is

**In plain language:** Working with files means reading content line by line, checking what exists and what doesn't, and writing output cleanly. Scripts that only work with hardcoded strings aren't useful in real operations — file I/O is what connects your script to the actual system.

**Why it matters:** In SRE and platform engineering, most automation is file-driven — reading log files to find errors, checking config files before applying them, writing reports after a health check runs. If you can't read and write files reliably inside a script, you can't automate anything meaningful.

---

## Core Concept

**Reading a file line by line — the correct pattern**

```bash
while IFS= read -r line; do    # IFS= preserves leading/trailing whitespace
    echo "$line"               # -r prevents backslash interpretation
done < "$filepath"             # < feeds the file into the while loop
```

`IFS=` sets the Internal Field Separator to nothing for this `read` — leading and trailing whitespace on each line is preserved. Without it, indented lines lose their indentation.

`-r` is raw mode — backslash sequences like `\n` in the file are not interpreted. Without it, a line containing `\n` gets mangled silently.

The loop variable (`line`, `service`, `path`) is declared by `read` itself — you don't declare it before the loop. Each iteration, `read`assigns the current line's value to it. Counters you're accumulating across iterations (`total`, `running`) must be declared before the loop — variables declared inside reset on every iteration.

**Checking file properties**

```bash
[[ -f "$path" ]]    # exists and is a regular file
[[ -r "$path" ]]    # exists and is readable — covers -f implicitly
[[ -s "$path" ]]    # exists and has content (size > 0) — use ! -s for empty check
[[ -w "$path" ]]    # exists and is writable
```

Always check before operating. A script that tries to read an unreadable file fails with a confusing system error. A script that checks first fails with a clear message you wrote.

**Writing output**

```bash
echo "output" > "$file"     # overwrite — file starts fresh each run
echo "output" >> "$file"    # append — adds to existing content

> "$file"                   # truncate — empties the file without writing anything
                            # use this at the start of a run to clear previous output
```

Know which one you're reaching for before you write it. `>>` accumulating across runs is one of the most common bugs in reporting scripts.

**Heredoc — writing multi-line output cleanly**

```bash
cat > "$output" << EOF
Report generated: $(date)       # variables and command substitution expand inside
Host: $(hostname)
EOF
```

Cleaner than chaining multiple `echo` lines. Everything between the `EOF` markers is written to the file exactly as written, with expansions applied.

**Checking if output was written**

```bash
if [[ -s "$tmpfile" ]]; then
    cat "$tmpfile"      # file has content — show it
else
    echo "Nothing found"
fi
```

Use `-s` after a grep or any operation that may or may not write output. Don't assume something was written — check first.

**Watch out for:**

- Reading a file with `for line in $(cat file)` — splits on spaces, not lines. Always use `while IFS= read -r line`
- Using `>>` when you meant `>` — report accumulates across runs, output grows silently every time the script runs
- Forgetting to truncate the output file before the loop — use `> "$output_path"` before the loop starts so the report is always fresh

---

## Drills

### Drill 1 — Read a file line by line with counter

**What I did:**

```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

count=1
filepath="$1"

while IFS= read -r line; do
    echo "$count: $line"
    count=$((count + 1))
done < "$filepath"
```

```bash
./file-demo.sh services.txt
```

**Output:**

```
1: nginx
2: docker
3: ssh
```

**What this taught me:** `while IFS= read -r line` is the correct pattern — not `for line in $(cat file)`. The loop variable `line` is declared by `read` itself, not manually. Each iteration, `read` assigns the current line and the loop body runs. When no more lines, the loop exits.

---

### Drill 2 — File existence and readable check

**What I did:**

```bash
if [[ ! -f "$filepath" || ! -r "$filepath" ]]; then
    echo "Error: file not found or not readable: $filepath"
    exit 1
fi

# Tested with:
./file-demo.sh fake.txt           # doesn't exist
./file-demo.sh services.txt       # exists and readable
./file-demo.sh empty.md           # exists but chmod -r applied
```

**Output:**

```
Error: file not found or not readable: fake.txt
1: nginx
2: docker
3: ssh
Error: file not found or not readable: empty.md
```

**What this taught me:** `-r` (readable) covers existence implicitly — a file that doesn't exist isn't readable either. Combining `! -f || ! -r` covers both cases explicitly and makes the intent clear. Tested with `chmod -r` to verify the readable check actually fires.

---

### Drill 3 — Empty file check with -s

**What I did:**

```bash
if [[ ! -s "$filepath" ]]; then
    echo "Warning: file is empty: $filepath"
    exit 0
fi
```

**Output:**

```
./file-demo.sh empty.md
Warning: file is empty: empty.md

./file-demo.sh services.txt
1: nginx
2: docker
3: ssh
```

**What this taught me:** `-s` returns true when the file has content. `! -s` catches the empty case. The logic is easy to flip — always read `-s` as "has size" and negate it for the empty check. Exit 0 here because an empty file is not an error — it's a valid state that just has nothing to process.

---

### Drill 4 — Heredoc for multi-line output

**What I did:**

```bash
filepath="$1"

cat > "$filepath" << EOF
Report generated: $(date)
Host: $(hostname)
Summary: heredoc redirection
EOF

cat "$filepath"
```

**Output:**

```
Report generated: Fri 01 May 2026 12:43:29 AM ADT
Host: rocky-vm
Summary: heredoc redirection
```

**What this taught me:** Heredoc writes a clean multi-line block to a file without chaining multiple `echo` lines. Variables and command substitution (`$(date)`, `$(hostname)`) expand inside the block. Cleaner and more readable than `echo "line1" > file; echo "line2" >> file`.

---

### Drill 5 — Parameterised output path

**What I did:**

```bash
#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <output-file-path>"
    exit 1
fi

filepath="$1"

cat > "$filepath" << EOF
Report generated: $(date)
Host: $(hostname)
Summary: heredoc redirection
EOF
```

**Output:**

```
./write-report.sh
Usage: ./write-report.sh <output-file-path>

./write-report.sh /tmp/drill5-check.txt
# cat drill5-check.txt
Report generated: Fri 01 May 2026 12:43:29 AM ADT
Host: rocky-vm
Summary: heredoc redirection
```

**What this taught me:** Same pattern as every other script — accept path as argument, validate, then use `"$filepath"`throughout. Always quote the variable in redirections — `cat > "$filepath"` not `cat > $filepath`.

---

## Lab

**Scenario:** An SRE team checks service status across systems manually by running `systemctl status` one at a time. A script that reads a services list, checks each one, and writes a status report replaces that manual work and makes it schedulable.

**Task:** `service-check.sh` — reads a services file line by line, checks each service with `systemctl is-active`, writes `RUNNING` or `STOPPED` per service to an output report, prints a summary at the end.

**What I built:**

```bash
#!/bin/bash

# ─── Input Validation ───────────────────────────────────────────────
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <service-file> <output-file-path>"
    exit 1
fi

service_file="$1"
output_path="$2"

if [[ ! -f "$service_file" || ! -r "$service_file" ]]; then
    echo "Error: file not found or not readable: $service_file"
    exit 1
fi

if [[ ! -s "$service_file" ]]; then
    echo "Warning: file is empty: $service_file"
    exit 0
fi

# ─── Counters ───────────────────────────────────────────────────────
running=0
stopped=0
total=0

# ─── Service Check Loop ─────────────────────────────────────────────
while IFS= read -r service; do
    total=$((total + 1))

    if systemctl is-active --quiet "$service"; then
        echo "$service: RUNNING" >> "$output_path"
        running=$((running + 1))
    else
        echo "$service: STOPPED" >> "$output_path"
        stopped=$((stopped + 1))
    fi
done < "$service_file"

# ─── Summary — > overwrites, then >> appends ────────────────────────
echo "--- Summary ---" > "$output_path"
echo "Total:   $total" >> "$output_path"
echo "Running: $running" >> "$output_path"
echo "Stopped: $stopped" >> "$output_path"

cat "$output_path"
exit 0
```

**What actually happened:** Built the validation and loop structure cleanly from previous topics. The two things that needed working through — `systemctl is-active --quiet` as the check command (suppresses output, just returns exit code), and counter placement inside vs outside the loop. Also caught `ssh` vs `sshd` on Rocky Linux — RHEL-based systems use `sshd` as the service name.

**The result:**

```
./service-check.sh services.txt report.txt
nginx: STOPPED
docker: STOPPED
sshd: RUNNING
fake-service: STOPPED
--- Summary ---
Total:   4
Running: 1
Stopped: 3
```

---

## Key Takeaways

- `while IFS= read -r line; do ... done < "$file"` — the only correct pattern for reading a file line by line. Not `for line in $(cat file)`
- Initialise accumulator counters before the loop. Loop variables (`service`, `line`) are declared by `read` — you don't declare them manually
- `>` overwrites, `>>` appends — know which one before you write it. Use `> "$output_path"` to truncate at the start of a run so reports don't accumulate

## Tips

- `systemctl is-active --quiet` is the right tool for scripted service checks — no output, just exit code. `systemctl status` is for human reading, not scripting
- On RHEL-based systems (Rocky, CentOS, RHEL), SSH service is `sshd` not `ssh`. Small differences like this only surface when you actually run the script — not from tutorials
- In production reporting scripts, always truncate the output file before the loop with `> "$output_path"`. A report that silently grows across runs is harder to debug than one that's always fresh

---

#### Retain This

- [ ] Add `set -euo pipefail` to `service-check.sh` and run it — fix whatever breaks
- [ ] Rewrite the `while IFS= read -r` loop from memory — if you have to look it up, practice it until you don't
- [ ] Search "bash read line by line IFS" — find one short post that explains what IFS and -r actually do under the hood