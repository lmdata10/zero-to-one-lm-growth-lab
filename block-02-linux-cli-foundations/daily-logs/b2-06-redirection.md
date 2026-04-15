# Redirection — >, >>, <, 2>, /dev/null

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Redirection — `>`, `>>`, `<`, `2>`, `/dev/null` 
**Filename:** `b2-06-redirection.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-06-redirection.md`

---

## The Big Picture

Every process in Linux has three standard streams attached by default. stdin (`0`) is input — what the process reads from. stdout (`1`) is normal output — what the process writes on success. stderr (`2`) is error output — what the process writes when something goes wrong. By default all three connect to the terminal. Redirection disconnects them and points them elsewhere — to a file, to another command, or to `/dev/null` to discard them entirely.

The operators are simple once the stream model clicks. `>` and `>>` move stdout. `2>` moves stderr. `<` pulls a file into stdin. `2>&1` merges stderr into stdout so both go to the same destination. `/dev/null` is the discard device — write to it, data disappears.

### Quick Reference

|Operator|What it does|
|---|---|
|`>`|Redirect stdout to a file — **overwrites** with no warning|
|`>>`|Append stdout to a file — safe for logs|
|`<`|Feed a file into stdin|
|`2>`|Redirect stderr to a file|
|`2>/dev/null`|Discard stderr entirely|
|`2>&1`|Merge stderr into stdout — both go to the same destination|
|`&>`|Shorthand for redirecting both stdout and stderr|
|`<< 'EOF'`|Heredoc — feed multi-line input inline without a separate file|

---

## Learning by Doing

### Drill 1 — > overwrites, >> appends

**What I ran:**

```bash
echo "first line" > /tmp/redirect-test.txt
cat /tmp/redirect-test.txt
echo "second line" > /tmp/redirect-test.txt
cat /tmp/redirect-test.txt
echo "third line" >> /tmp/redirect-test.txt
cat /tmp/redirect-test.txt
```

**Output:**

```
first line

second line

second line
third line
```

**What I learned:** `>` overwrites with no warning — "first line" is gone the moment "second line" is written. `>>` appends — "second line" and "third line" both present. A logging script that uses `>` instead of `>>` silently destroys its own history every run. Default to `>>` when accumulating output.

---

### Drill 2 — Separating stdout and stderr

**What I ran:**

```bash
ls /fakedirectory
ls /fakedirectory 2>/dev/null
ls /fakedirectory > /tmp/out.txt
ls /fakedirectory 2> /tmp/err.txt
cat /tmp/out.txt
cat /tmp/err.txt
```

**Output:**

```
ls: cannot access '/fakedirectory': No such file or directory
[nothing — error discarded]
ls: cannot access '/fakedirectory': No such file or directory
[nothing printed to terminal]

[out.txt — empty]
ls: cannot access '/fakedirectory': No such file or directory
```

**What I learned:** The error message is stderr — stream 2. `>` only redirects stdout — stream 1. Since `ls /fakedirectory` produces no stdout, `out.txt` is empty. The error went to stderr, which `>` does not touch, so it still printed to terminal. `2>` redirects stderr specifically — that is why `err.txt` has the error and nothing printed to terminal. `2>/dev/null` discards stderr entirely — second command produced nothing at all.

---

### Drill 3 — Capturing both streams separately

**What I ran:**

```bash
ls /etc /fakedirectory > /tmp/both-out.txt 2> /tmp/both-err.txt
cat /tmp/both-out.txt
cat /tmp/both-err.txt
```

**Output:**

```
# both-out.txt
/etc:
adjtime
aliases
alsa
...

# both-err.txt
ls: cannot access '/fakedirectory': No such file or directory
```

**What I learned:** One command, two streams, two different destinations. stdout went to `both-out.txt`, stderr went to `both-err.txt`, nothing printed to terminal. This pattern is useful in scripts and cron jobs — clean output in one file, errors in another. I will use this in Block 3 when writing the system health check script.

---

### Drill 4 — Merging streams with 2>&1

**What I ran:**

```bash
ls /etc /fakedirectory > /tmp/combined.txt 2>&1
cat /tmp/combined.txt
```

**Output:**

```
ls: cannot access '/fakedirectory': No such file or directory
/etc:
adjtime
aliases
...
```

**What I learned:** `2>&1` means send stderr to wherever stdout is currently pointing. Since stdout was already redirected to `combined.txt`, stderr followed. Both streams, one file. The error line appears first even though `/etc` was listed first in the command — stderr and stdout are separate buffers and do not necessarily interleave in order. Worth knowing when reading combined logs and the sequence looks off.

Use separated streams when I want to process errors differently from output. Use merged when I just need a complete record of everything that happened.

---

### Drill 5 — stdin redirection and heredocs

**What I ran:**

```bash
wc -l < /etc/passwd
cat > /tmp/input-test.txt << 'EOF'
line one
line two
line three
EOF
cat /tmp/input-test.txt
```

**Output:**

```
47

line one
line two
line three
```

**What I learned:** `<` feeds the file into stdin — `wc -l` reads from stdin instead of opening the file itself. Useful when a command only reads from stdin and does not accept a filename argument.

`<< 'EOF'` is a heredoc — feeds multiple lines of text directly into stdin inline, without needing a separate file first. Everything between `<< 'EOF'` and the closing `EOF` is treated as input. The quotes around `'EOF'` prevent variable expansion inside the block — variables stay as literal text. Without quotes they would be evaluated. I will use this constantly in Block 3 to write config files and structured output inside scripts.

---

## Lab: Putting It Together

**Task:** Four redirection tasks combining the operators from this session.

**What I did:**

```bash
# 1. Find all .conf files, suppress errors, capture to file, count with wc -l
find /etc -name "*.conf" 2>/dev/null > /tmp/conf-files.txt
wc -l < /tmp/conf-files.txt

# 2. Append current date to the file, verify at the bottom
date +%F >> /tmp/conf-files.txt
tail -3 /tmp/conf-files.txt

# 3. Capture both stdout and stderr to one file, grep for the error
ls /home /error > /tmp/lab-combined.txt 2>&1; grep "cannot" /tmp/lab-combined.txt

# 4. Write a heredoc to a file, verify contents
cat > /tmp/lab-note.txt << 'EOF'
Block-02 - Topic-6: Redirection
Date: April 14, 2026
In today's session I learned how stdin, stdout, and stderr redirection works in Linux.
EOF
cat /tmp/lab-note.txt
```

**Output:**

```
# Task 1
348

# Task 2
/etc/locale.conf
/etc/vconsole.conf
2026-04-14

# Task 3
ls: cannot access '/error': No such file or directory

# Task 4
Block-02 - Topic-6: Redirection
Date: April 14, 2026
In today's session I learned how stdin, stdout, and stderr redirection works in Linux.
```

**Outcome:** All four tasks completed correctly.

**What each task revealed:**

- Task 1: 348 `.conf` files under `/etc` on a stock Rocky install. `2>/dev/null` suppressed permission errors cleanly, `>` captured only the valid results.
- Task 2: `date +%F` outputs ISO 8601 format — `2026-04-14`. Sorts correctly and is unambiguous across locales. The right format for log filenames and timestamps in scripts.
- Task 3: Hit a real wall here — tried `|` and `&&` before landing on `;`. After `> file 2>&1` the stream is exhausted into the file, nothing remains for a pipe to receive. `&&` runs the next command only if the previous succeeds — `ls` failed so grep never ran. `;` runs unconditionally regardless of exit code, and by then the file is written and grep can read it.
- Task 4: Heredoc written and verified. Quotes around `'EOF'` kept content literal — no variable expansion.

**Errors hit:** `|` and `&&` did not work after `2>&1` for chaining grep.

**How I resolved it:** Used `;` — runs the follow-up command unconditionally after the file is written.

**Key distinction learned:** After `> file 2>&1`, both streams are redirected to the file. Nothing is left in the stream for a pipe. To chain a command that reads the resulting file, use `;` not `|`.

---

## What Stuck With Me

- **`>` overwrites, `>>` appends.** No warning, no recovery on overwrite. Default to `>>` when accumulating output.
- **stderr and stdout are separate streams.** `>` only touches stdout. Errors still print to terminal unless stream 2 is explicitly redirected.
- **`2>&1` merges stderr into stdout.** Both go to the same destination. After that, the stream is exhausted — nothing left for a pipe.
- **`<` feeds a file into stdin.** Useful when a command does not accept a filename argument.
- **`<< 'EOF'` is a heredoc.** Multi-line input inline. Quotes prevent variable expansion inside the block.
- **`;` vs `&&` vs `|`.** Semicolon runs unconditionally. `&&` runs only on success. Pipe passes the stream — useless after it has been redirected to a file.

---

## Tips from Session

- In scripts and cron jobs, separate stdout and stderr — `> out.txt 2> err.txt`. Clean output in one place, failures in another.
- `/dev/null` is just a discard device. Write to it, data disappears. Read from it, nothing comes back.
- `date +%F` for timestamps in log filenames and output — ISO 8601 sorts correctly and is unambiguous across locales.

---

> **Carry Forward:** Redirection in real scripts — Block 3, especially the system health check (Topic 12) and log parser (Topic 14). `2>/dev/null` pattern already used in Topics 5 and 6 — now the mechanism is fully understood. Heredocs for writing config files inside scripts — Block 3 throughout. `;` vs `&&` vs `|` — operator behavior revisited in Block 3 conditionals and error handling.