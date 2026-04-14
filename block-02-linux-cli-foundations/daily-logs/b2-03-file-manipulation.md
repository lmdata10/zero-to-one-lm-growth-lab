# File Manipulation — touch, cp, mv, rm, mkdir, rmdir

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** File Manipulation — `touch`, `cp`, `mv`, `rm`, `mkdir`, `rmdir` 
**Filename:** `b2-03-file-manipulation.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-03-file-manipulation.md`

---

## The Big Picture

Knowing how to move around the filesystem is only half of it — I also need to actually do things to it. This topic is the daily mechanical layer of sysadmin work: creating files and directories, copying, moving, renaming, and deleting. Every script I write, every config I touch, every log I manage starts with these six commands. The flags are what make them safe and useful — especially `rm`, where the wrong flag combination with the wrong path is unrecoverable.

---

## Learning by Doing

### Drill 1 — Create files with touch and brace expansion

**What I ran:**

```bash
cd /tmp
mkdir drill-03
ls -l
touch drill-03/file1.txt drill-03/file2.txt drill-03/file3.txt
ls -l drill-03/
```

**Output:**

```
total 0
-rw-r--r--. 1 student student 0 Apr 13 21:25 file1.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file2.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file3.txt
```

**What I learned:** `touch` creates empty files — size is `0`, just an inode entry with a timestamp. I can pass multiple arguments and it processes each one in sequence. Brace expansion also works: `touch drill-03/file{1,2,3}.txt` expands to three separate arguments before the command even runs — the shell does the expansion, `touch` never sees the braces. I'll use that pattern constantly in Bash scripting.

---

### Drill 2 — Copy with and without metadata preservation

**What I ran:**

```bash
cp /tmp/drill-03/file1.txt /tmp/drill-03/file1-backup.txt
cp -p /tmp/drill-03/file2.txt /tmp/drill-03/file2-backup.txt
ls -l /tmp/drill-03/
```

**Output:**

```
total 0
-rw-r--r--. 1 student student 0 Apr 13 21:28 file1-backup.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file1.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file2-backup.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file2.txt
-rw-r--r--. 1 student student 0 Apr 13 21:25 file3.txt
```

**What I learned:** `file1-backup.txt` shows `21:28` — the time the copy was made. `file2-backup.txt` shows `21:25` — the original file's timestamp carried over because of `-p`. `-p` preserves permissions, ownership, and timestamps. That matters when copying configs where the original timestamp is meaningful — some services and backup tools use timestamps to detect changes. When in doubt copying configs, use `-p`.

---

### Drill 3 — Move as rename vs move as relocation

**What I ran:**

```bash
mv /tmp/drill-03/file3.txt /tmp/drill-03/file3-renamed.txt
ls -l /tmp/drill-03/
mv /tmp/drill-03/file3-renamed.txt /tmp/
ls -l /tmp/drill-03/
ls -l /tmp/file3-renamed.txt
```

**Output:**

```
# After first mv — renamed in place
-rw-r--r--. 1 student student 0 Apr 13 21:25 file3-renamed.txt

# After second mv — gone from drill-03
-rw-r--r--. 1 student student 0 Apr 13 21:25 /tmp/file3-renamed.txt
```

**What I learned:** Same command, two different behaviors. Destination is a new name in the same directory — that's a rename. Destination is a different path — that's a move. `mv` doesn't copy data, it just updates the directory entry. The inode stays the same. That's why `mv` within the same filesystem is instant regardless of file size — no data is actually copied.

---

### Drill 4 — mkdir -p and rm -r

**What I ran:**

```bash
rm /tmp/drill-03/file1-backup.txt
ls -l /tmp/drill-03/
mkdir -p /tmp/drill-03/a/b/c
ls -lR /tmp/drill-03/
rm -r /tmp/drill-03/a
ls -l /tmp/drill-03/
```

**Output:**

```
# rm prompted for confirmation — rm is aliased to rm -i on this system
rm: remove regular empty file '/tmp/drill-03/file1-backup.txt'? y

# After mkdir -p
/tmp/drill-03/:
drwxr-xr-x. 3 student student 15 Apr 13 21:49 a

/tmp/drill-03/a:
drwxr-xr-x. 3 student student 15 Apr 13 21:49 b

/tmp/drill-03/a/b:
drwxr-xr-x. 2 student student  6 Apr 13 21:49 c

# rm -r prompted for each level before deleting
rm: descend into directory '/tmp/drill-03/a'? y
rm: descend into directory '/tmp/drill-03/a/b'? y
rm: remove directory '/tmp/drill-03/a/b/c'? y
rm: remove directory '/tmp/drill-03/a/b'? y
rm: remove directory '/tmp/drill-03/a'? y
```

**What I learned:** `-p` on `mkdir` creates the full nested path in one shot — without it, `mkdir /tmp/drill-03/a/b/c` would fail if `a` or `b` didn't exist. `-p` also suppresses the error if the directory already exists, which makes it safe to use in scripts — idempotent, won't fail on re-runs. `-R` on `ls` is recursive — shows every subdirectory and its contents, labeled by path. `rm` prompted on every file because it's aliased to `rm -i` on this Rocky install — that's a safety net worth keeping. In scripts, use `-f` explicitly where prompts would break automation.

---

### Drill 5 — cp -r and rmdir vs rm -rf

**What I ran:**

```bash
cp -r /tmp/drill-03 /tmp/drill-03-backup
ls -l /tmp/
rmdir /tmp/drill-03-backup
rm -rf /tmp/drill-03-backup
ls -l /tmp/
```

**Output:**

```
# rmdir refused
rmdir: failed to remove '/tmp/drill-03-backup': Directory not empty

# rm -rf succeeded silently — no prompts
drwxr-xr-x. 2 student student 64 Apr 13 21:49 drill-03
-rw-r--r--. 1 student student  0 Apr 13 21:25 file3-renamed.txt
```

**What I learned:** `rmdir` only removes empty directories — that's intentional, it's a safe alternative when I want to be certain I'm not accidentally deleting content. `rm -rf` is the opposite: silent, unconditional, no prompts, no undo. `-f` forces deletion and ignores errors on non-existent files. Together `-rf` bypasses the `-i` alias safety net entirely. Always verify the path before running `rm -rf`. A misplaced space in `rm -rf /tmp /drill-03` deletes `/tmp` first — that's a real class of incident.

---

## Lab: Putting It Together

**Task:** Full file manipulation workflow — create, copy, rename, move, delete.

**What I did:**

```bash
# 1. Create directory structure in one command
mkdir -p /tmp/sysadmin-lab/{configs,backups}
ls sysadmin-lab/

# 2. Create three config files
touch sysadmin-lab/configs/{app.conf,db.conf,cache.conf}
ls sysadmin-lab/configs/

# 3. Copy app.conf to backups preserving metadata
cp -p sysadmin-lab/configs/app.conf sysadmin-lab/backups/
ls -l sysadmin-lab/backups/
ls -l sysadmin-lab/configs/

# 4. Rename db.conf to db.conf.bak
cd sysadmin-lab/configs/
mv db.conf db.conf.bak
ls -la

# 5. Move cache.conf to /tmp/
cd ..
mv configs/cache.conf /tmp/
ls /tmp/

# 6. Delete entire sysadmin-lab directory
cd /tmp
rm -rf /tmp/sysadmin-lab
ls -la
```

**Outcome:** Full workflow completed with zero errors. `sysadmin-lab` confirmed gone from `/tmp` after deletion.

**What went well:**

- Used brace expansion on both `mkdir` and `touch` without being prompted — `{configs,backups}` and `{app.conf,db.conf,cache.conf}`.
- Ran `cd ..` before `rm -rf` — never delete a directory you're currently inside.

**Errors hit:** None.

**Key distinction learned:** Brace expansion happens at the shell level before the command runs. `mkdir -p /tmp/sysadmin-lab/{configs,backups}` is expanded by the shell into two separate arguments — `mkdir` never sees the braces. Same pattern works with `touch`, `cp`, `mv`, and most other commands.

---

## What Stuck With Me

- **`touch` creates empty files or updates timestamps.** Size is `0` — just an inode entry. Brace expansion lets you create multiple files in one shot.
- **`cp -p` preserves metadata.** Permissions, ownership, timestamps all carry over. Reach for this when copying configs where the original timestamp matters.
- **`mv` is both rename and move.** Same command — behavior depends on whether the destination is a new name or a new path. No data copied, just the directory entry updates. Instant on the same filesystem.
- **`mkdir -p` is idempotent.** Creates nested paths in one shot, won't error if the directory already exists. Use this in every script that needs a directory.
- **`rm -rf` is silent and unconditional.** No prompts, no undo, no recovery. Always verify the path. Always `cd` out of a directory before deleting it.
- **`rmdir` is the safe alternative.** Refuses if anything is inside — use it when that guarantee matters.

---

## Tips from Session

- Never `rm -rf` a directory you're currently inside. `cd ..` first, every time.
- The `rm -i` alias on Rocky is a safety net — leave it in place. Use `-f` explicitly in scripts where prompts would break automation.

---

> **Carry Forward:** Brace expansion shows up again in Block 3 Bash scripting — it's a shell feature, not specific to any one command. Stderr redirection to suppress `rm` and `find` noise — Topic 6. Permissions on copied files (`-p` vs default behavior) ties directly into Topic 7.