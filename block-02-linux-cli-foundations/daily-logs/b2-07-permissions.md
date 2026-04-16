# Permissions — chmod, chown, octal vs symbolic, umask

**Block:** Block 2 — Linux CLI Foundations
**Topic:** Topic 7 — Permissions
**Filename:** `b2-07-permissions.md`
**Path:** `block-02-linux-cli-foundations/daily-logs/b2-07-permissions.md`

---

## The Big Picture

Every file and directory on Linux has permissions. Who can read it, write to it, execute it. This is the wall between your data and everyone else's. Think of a hotel — each room (file) has a lock. The keycard (permission) determines who can get in: owner (full access), group (limited access), everyone else (no access). Permissions work the same way: owner, group, others. Each has three permissions: read (r), write (w), execute (x).

---

## Learning by Doing

### Drill 1 — View permissions

**What I ran:**

```bash
ls -la /
```

**Output:**

```
total 24
dr-xr-xr-x.  18 root root  235 Apr 11 17:56 .
dr-xr-xr-x.   2 root root    6 Apr  1  2025 afs
lrwxrwxrwx.   1 root root    7 Apr  1  2025 bin -> usr/bin
dr-xr-xr-x.   7 root root 4096 Apr 11 17:58 boot
dr-xr-xr-x.  20 root root 3440 Apr 15 15:09 dev
dr-xr-xr-x. 133 root root 8192 Apr 15 18:09 etc
dr-xr-xr-x.   3 root root   21 Apr 11 17:53 home
drwxrwxrwt.  26 root root 4096 Apr 15 19:42 tmp
drwxr-xr-x.  18 root root 4096 Apr 11 17:53 usr
drwxr-xr-x.  20 root root 4096 Apr 11 17:53 var
```

**What I learned:** The first column shows 10 characters: type (d/-/l) + owner permissions + group permissions + others permissions. The dot means SELinux context is active.

---

### Drill 2 — Check your home directory permissions

**What I ran:**

```bash
ls -la ~
```

**Output:**

```
total 32
drwx------. 15 student student 4096 Apr 13 19:10 .
drwxr-xr-x.  3 root    root      21 Apr 11 17:53 ..
-rw-------.  1 student student 6178 Apr 14 23:39 .bash_history
-rw-r--r--.  1 student student   18 Oct 28  2024 .bash_logout
-rw-r--r--.  1 student student  144 Oct 28  2024 .bash_profile
-rw-r--r--.  1 student student 1480 Apr 13 21:53 .bashrc
drwx------.  9 student student 4096 Apr 11 17:54 .cache
drwx------. 10 student student 4096 Apr 11 17:56 .config
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Desktop
drwx------.   4 student student   32 Apr 11 17:54 .local
drwxr-xr-x.   4 student student   39 Apr 11 17:49 .mozilla
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Music
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Pictures
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Public
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Templates
drwxr-xr-x.   2 student student    6 Apr 11 17:54 Videos
/home/student
```

**What I learned:** Home directory has drwx------ — only the student user can enter, read, write. No one else has any access.

---

### Drill 3 — Change permissions with symbolic mode

**What I ran:**

```bash
touch testfile.txt
ls -la testfile.txt
chmod a=r testfile.txt
ls -la testfile.txt
```

**Output:**

```
-rw-r--r--. 1 student student 0 Apr 15 19:46 testfile.txt
-r--r--r--. 1 student student 0 Apr 15 19:46 testfile.txt
```

**What I learned:** a=r removes all permissions and sets read for everyone. Original rw-r--r-- became r--r--r--.

---

### Drill 4 — Add execute with symbolic

**What I ran:**

```bash
chmod u+x testfile.txt
ls -la testfile.txt
chmod u=x testfile.txt
ls -la testfile.txt
```

**Output:**

```
-r-xr--r--. 1 student student 0 Apr 15 19:46 testfile.txt
---xr--r--. 1 student student 0 Apr 15 19:46 testfile.txt
```

**What I learned:** u+x adds execute to owner, keeps read/write. u=x sets only execute for owner, removes read/write.

---

### Drill 5 — Octal mode

**What I ran:**

```bash
chmod 755 testfile.txt
ls -la testfile.txt
chmod 644 testfile.txt
ls -la testfile.txt
```

**Output:**

```
-rwxr-xr-x. 1 student student 0 Apr 15 19:46 testfile.txt
-rw-r--r--. 1 student student 0 Apr 15 19:46 testfile.txt
```

**What I learned:** 755 = owner rwx (7), group rx (5), others rx (5). 644 = owner rw (6), group r (4), others r (4).

---

### Drill 6 — Check ownership

**What I ran:**

```bash
ls -la /etc/passwd
```

**Output:**

```
-rw-r--r--. 1 root root 2210 Apr 11 17:53 /etc/passwd
```

**What I learned:** /etc/passwd is owned by root:root. Regular users can read it because it has r-- for others.

---

### Drill 7 — Check your groups

**What I ran:**

```bash
groups
id
```

**Output:**

```
student wheel
uid=1000(student) gid=1000(student) groups=1000(student),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

**What I learned:** I am student (uid 1000), primary group student (gid 1000), secondary group wheel (gid 10). wheel is the sudo group on RHEL-based systems.

---

## Lab: Putting it together

**Task:** Create a directory where a group can share files for a web project, with owner rwx, group rx, others r--.

**What I did:**

```bash
mkdir -p ~/webproject
touch ~/webproject/index.html
touch ~/webproject/style.css
touch ~/webproject/script.js
chmod 750 ~/webproject
chmod 644 ~/webproject/*
ls -la ~/webproject/
```

**Output:**

```
drwxr-x---.  2 student student   58 Apr 15 21:27 .
drwxr-xr-x. 16 student student 4096 Apr 13 19:57 ..
-rw-r--r--.  1 student student    0 Apr 15 21:27 index.html
-rw-r--r--.  1 student student    0 Apr 15 21:27 script.js
-rw-r--r--.  1 student student    0 Apr 15 21:27 style.css
```

**Outcome:** Directory is 750 (owner rwx, group rx, others none). Files inside are 644 (owner rw, group r, others r). Group members can enter and read files but cannot delete them. The . in permissions shows SELinux context is active.

**Key distinction learned:** Execute permission on a directory is about traversal (cd into it, access files inside), not "executing" it like a file.

---

[update learnings]