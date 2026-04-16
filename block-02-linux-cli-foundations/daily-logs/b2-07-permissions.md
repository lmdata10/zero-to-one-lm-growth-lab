# Permissions — chmod, chown, chgrp, octal vs symbolic, umask

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Permissions — `chmod`, `chown`, `chgrp`, octal vs symbolic, `umask` 
**Filename:** `b2-07-permissions.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-07-permissions.md`

---

## The Big Picture

Permissions are how Linux decides who can do what to a file. Every file and directory has an owner, a group, and a permission set. Get this wrong and services can not read their configs, scripts won't execute, and users can access things they shouldn't. This is one of the most common sources of real-world breakage.

Every file has three permission sets — owner, group, and others. Each set has three bits — **read (`r`), write (`w`), execute (`x`)**. The permission string in `ls -l` output maps directly to this:

```
-rwxr-xr--  1  root  wheel  1234  Apr 14  script.sh
```

First character is file type (`-` = file, `d` = directory, `l` = symlink). Then three characters for **owner**, three for **group**, three for **others**.

Two ways to set permissions — symbolic (human readable, adds or removes individual bits) and octal (numeric, sets the full permission set at once). Both do the same thing. Octal is faster in scripts and documentation once it clicks.

### Quick Reference

|Concept|Detail|
|---|---|
|Octal values|`r=4`, `w=2`, `x=1` — add per set|
|Common octals|`755` = rwxr-xr-x, `644` = rw-r--r--, `600` = rw-------, `750` = rwxr-x---|
|Symbolic operators|`+` adds, `-` removes, `=` sets exactly|
|Symbolic targets|`u` = owner, `g` = group, `o` = others, `a` = all|
|umask default|`022` → files get `644`, dirs get `755`|
|umask hardened|`027` → files get `640`, dirs get `750`|

---

## Learning by Doing

### Drill 1 — Read a permission string

**What I ran:**

```bash
cd /tmp
touch permissions-test.txt
ls -l permissions-test.txt
```

**Output:**

```
-rw-r--r--. 1 student student 0 Apr 15 22:25 permissions-test.txt
```

**What I learned:** Reading the string left to right — `-` is a regular file, `rw-` is owner gets read and write, `r--` is group gets read only, `r--` is others get read only. Owner is `student`, group is `student`. The `1` is the hard link count — how many directory entries point to this inode. Usually 1 for regular files. Octal translation: `rw-`=6, `r--`=4, `r--`=4 → `644`. That is the default for new files created by a regular user.

---

### Drill 2 — Set permissions with octal

**What I ran:**

```bash
chmod 755 /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
chmod 600 /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
```

**Output:**

```
-rwxr-xr-x. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
-rw-------. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
```

**What I learned:** `755` — owner gets rwx=7, group gets r-x=5, others get r-x=5. `600` — owner gets rw-=6, group gets nothing=0, others get nothing=0. `600` is the required permission for SSH private keys — only the owner can read or write it, nobody else can do anything with it at all. If a private key is readable by others, `ssh` refuses to use it and throws a `permissions are too open` error. The risk is not just accidental changes — anyone with read access to a private key can copy it and impersonate the owner to any server that trusts it.

---

### Drill 3 — Set permissions with symbolic mode

**What I ran:**

```bash
chmod u+x /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
chmod g+rw /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
chmod o-r /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
```

**Output:**

```
-rwx------. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
-rwxrw----. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
-rwxrw----. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
```

**What I learned:** `u+x` adds execute to owner while keeping existing bits. `g+rw` adds read and write to group while keeping existing bits. `o-r` removes read from others — no visible change here because others already had no permissions. Removing a bit that is already absent runs without error. Symbolic mode only touches the specified bit, it does not care about the current state. Final octal: `rwx`=7, `rw-`=6, `---`=0 → `760`.

---

### Drill 4 — Change owner and group with chown

**What I ran:**

```bash
sudo chown root /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
sudo chown root:root /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
sudo chown student:student /tmp/permissions-test.txt
ls -l /tmp/permissions-test.txt
```

**Output:**

```
-rwxrw----. 1 root    student 0 Apr 15 22:25 /tmp/permissions-test.txt
-rwxrw----. 1 root    root    0 Apr 15 22:25 /tmp/permissions-test.txt
-rwxrw----. 1 student student 0 Apr 15 22:25 /tmp/permissions-test.txt
```

**What I learned:** `chown user` changes owner only — group stays as-is. `chown user:group` changes both in one shot. `chown :group` changes only the group — same as `chgrp group file`. In practice `chown user:group` is the one to reach for most since owner and group usually need to be set together. Permissions bits stay unchanged through all three — `chown` only touches ownership, not the permission mask.

---

### Drill 5 — umask and default permissions

**What I ran:**

```bash
umask
umask 027
touch /tmp/umask-test.txt
mkdir /tmp/umask-test-dir
ls -l /tmp/umask-test.txt
ls -ld /tmp/umask-test-dir
umask 022
```

**Output:**

```
0022

-rw-r-----. 1 student student 0 Apr 15 22:44 /tmp/umask-test.txt
drwxr-x---. 2 student student 6 Apr 15 22:44 /tmp/umask-test-dir
```

**What I learned:** `umask` subtracts from the system maximum at creation time. `027` applied: `666 - 027 = 640` for files → `rw-r-----`, `777 - 027 = 750` for directories → `rwxr-x---`. `umask 027` is common in hardened environments where files should not be world-readable. Default `022` leaves files world-readable (`644`) which is fine for most systems. Reset `umask` after changing it in a shell session — a changed mask affects everything created until the shell exits.

---

## Lab: Putting It Together

**Task:** Four permission tasks using both octal and symbolic modes.

**What I did:**

```bash
# 1. Create lab-script.sh, set 750, verify
touch /tmp/lab-script.sh
chmod 750 /tmp/lab-script.sh
ls -l /tmp/lab-script.sh

# 2. Create lab-secret.txt, set owner read-only using symbolic, verify
touch /tmp/lab-secret.sh
chmod u=r,g=,o= /tmp/lab-secret.sh
ls -l /tmp/lab-secret.sh

# 3. Create lab-shared dir, set 750, verify with ls -ld
mkdir -p /tmp/lab-shared
chmod 750 /tmp/lab-shared
ls -ld /tmp/lab-shared

# 4. Check current umask, explain what it means
umask
umask -S
touch /tmp/umask-test.txt
mkdir -p /tmp/umask-test
ls -l /tmp/umask-test.txt
ls -ld /tmp/umask-test
```

**Output:**

```
# Task 1
-rwxr-----. 1 student student 0 Apr 16 10:00 /tmp/lab-script.sh

# Task 2
-r--------. 1 student student 0 Apr 16 10:02 /tmp/lab-secret.sh

# Task 3
drwxr-x---. 2 student student 6 Apr 16 10:06 /tmp/lab-shared

# Task 4
0027
u=rwx,g=rx,o=
-rw-r-----. 1 student student 0 Apr 16 10:10 /tmp/umask-test.txt
drwxr-x---. 2 student student 6 Apr 16 10:11 /tmp/umask-test
```

**Outcome:** All four tasks completed correctly.

**What each task revealed:**

- Task 1: `750` — owner rwx=7, group r-x=5, others none=0. `rwxr-x---` confirmed in output.
- Task 2: `u=r,g=,o=` uses the `=` operator to set exactly — `g=` and `o=` with nothing after clears all bits for those sets. Cleaner than chaining multiple `-` removals.
- Task 3: `ls -l` on a directory lists its contents. `ls -ld` shows the directory entry itself — needed to check permissions on the directory. Figured this out mid-lab. `chmod -R 750` would apply recursively to everything inside — useful but needs care since files and directories usually need different permission sets.
- Task 4: `umask -S` shows the mask in symbolic format — not drilled, found it independently. Current mask is `027` still set from Drill 5. Files get `640`, directories get `750`. Math: `666-027=640`, `777-027=750`.

**Errors hit:** None.

**Key distinction learned:** `ls -l` lists directory contents. `ls -ld` shows the directory entry itself. Always use `ls -ld` when checking permissions on a directory.

---

## What Stuck With Me

- **Three sets, three bits.** Owner, group, others. Read=4, write=2, execute=1. Add per set to get the octal digit.
- **Octal sets everything at once.** `chmod 644 file` — one command, full permission set defined. Faster in scripts.
- **Symbolic changes individual bits.** `chmod u+x file` adds execute without touching anything else. Better interactively when recalculating the full octal is annoying.
- **`=` sets exactly.** `chmod u=r,g=,o=` clears group and others entirely. Cleaner than multiple `-` operations.
- **`chown user:group` in one shot.** Most of the time owner and group need setting together.
- **`umask` subtracts at creation time.** `022` is the standard default. `027` is the hardened default. Reset after changing in a session.
- **`ls -ld` for directory permissions.** `ls -l` lists contents, not the directory itself.

---

## Tips from Session

- Reach for octal in scripts and documentation — faster and unambiguous. Use symbolic interactively when adding or removing a single bit without recalculating the full set.
- `chmod -R` sets the same permissions on files and directories alike — usually wrong. Be deliberate when using it.
- Always reset `umask` after changing it in a shell session — a changed mask affects everything created until the shell exits.

---

> **Carry Forward:** SSH key permissions (`600`) in practice — Block 4 Topic 4 SSH hardening. `chmod -R` used carefully when setting up service directories — Block 4. Special permission bits (setuid, setgid, sticky bit) — Block 4 Linux Administration. `umask` in `.bashrc` for persistent default — Topic 14 environment.