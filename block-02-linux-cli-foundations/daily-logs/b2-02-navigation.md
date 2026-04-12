# Navigation — pwd, ls, cd, find, locate

**Block:** Block 2 — Linux CLI Foundations
**Topic:** Navigation — `pwd`, `ls`, `cd`, `find`, `locate`
**Filename:** `b2-02-navigation.md`
**Path:** `block-02-linux-cli/daily-logs/b2-02-navigation.md`

---

## The Big Picture

The shell always knows where you are. Every command runs relative to a location in the filesystem tree. Navigation is moving around that tree and knowing what's there.

Five commands do all of it:
	1. `pwd` tells you where you are
	2. `ls` shows what's there
	3. `cd` moves you
	4. `find` searches the live filesystem
	5. `locate` searches a pre-built index. 

The flags on `ls` and the scoping on `find` are what separate someone who knows these commands from someone who uses them well.

---

## Learning by Doing

### Drill 1 — Move around the tree and observe position

**What I ran:**

```bash
pwd
cd /var/log
pwd
cd ..
pwd
cd ~
pwd
```

**Output:**

```
/
/var/log
/var
/home/student
```

**What I learned:** `cd ..` moves one level up to the parent directory — from `/var/log` to `/var`, not two levels. Chain it to move multiple levels: `cd ../..`
`cd ~` or `cd` resolves to the current user's home directory — `/home/student` 
`cd -` returns to the previous working directory — not drilled here but worth knowing, it's underused and saves time constantly.

---

### Drill 2 — Long listing format

**What I ran:**

```bash
cd /etc
ls
ls -l
ls -lah
```

**Output (ls -lah, first few lines):**

```
total 1.3M
drwxr-xr-x. 133 root root 8.0K Apr 11 18:13 .
dr-xr-xr-x.  18 root root  235 Apr 11 17:56 ..
-rw-r--r--.   1 root root   16 Apr 11 17:53 adjtime
-rw-r--r--.   1 root root 1.5K Nov 29  2023 aliases
drwxr-xr-x.   3 root root   65 Apr 11 17:51 alsa
drwxr-xr-x.   2 root root 4.0K Apr 11 17:51 alternatives
```

**What I learned:** Plain `ls` gives names only. `-l` adds permissions, ownership, size, and timestamps. `-a` reveals hidden dotfiles. `-h` makes sizes human-readable (1.5K vs 1536). Combined: `ls -lah` is the default long listing to reach for. Add `-t` to sort by modification time, `-r` to reverse order. `ls -lahtr` is useful in `/var/log` to find what changed most recently.

---

### Drill 3 — Dotfiles in home directory

**What I ran:**

```bash
cd ~
ls -la
```

**Output:**

```
total 28
drwx------. 14 student student 4096 Apr 11 17:55 .
drwxr-xr-x.  3 root    root      21 Apr 11 17:53 ..
-rw-------.  1 student student   62 Apr 11 17:56 .bash_history
-rw-r--r--.  1 student student   18 Oct 28  2024 .bash_logout
-rw-r--r--.  1 student student  144 Oct 28  2024 .bash_profile
-rw-r--r--.  1 student student  522 Oct 28  2024 .bashrc
drwx------.  9 student student 4096 Apr 11 17:54 .cache
drwx------. 10 student student 4096 Apr 11 17:56 .config
drwx------.  4 student student   32 Apr 11 17:54 .local
drwxr-xr-x.  4 student student   39 Apr 11 17:49 .mozilla
```

**What I learned:** All dotfiles here are user-scoped — they only affect `student`, not the whole system. System-wide equivalents live in `/etc`. `.bashrc` runs every interactive shell — aliases, functions, prompt config live here, it's the one you edit most. `.bash_profile` runs once at login and usually just sources `.bashrc`. `.bash_history` is `rw-------` — only the owner can read it, which matters because command history can contain sensitive info. `.cache`, `.config`, `.local` are application data directories, not shell config.

---

### Drill 4 — find with wildcards and flags

**What I ran:**

```bash
find /etc -name "*.conf" -type f | head -10
find /home -type f -name ".*"
```

**Output:**

```
find: '/etc/lvm/devices': Permission denied
find: '/etc/lvm/archive': Permission denied
find: '/etc/pki/rsyslog': Permission denied
/etc/lvm/lvm.conf
/etc/lvm/lvmlocal.conf
/etc/resolv.conf
/etc/dnf/protected.d/setup.conf
...
```

```
/home/student/.bash_logout
/home/student/.bash_profile
/home/student/.bashrc
/home/student/.bash_history
...
```

**What I learned:** `*` is a wildcard — matches anything. `*.conf` matches any filename ending in `.conf`. `.*` matches any filename starting with a dot — which is how Linux defines hidden files. `Permission denied` errors mean `find` hit a root-owned directory — the command is correct, the OS is working correctly. Running as a non-root user, some directories are locked out. Fix: `2>/dev/null` to suppress stderr. That's Topic 6.

---

### Drill 5 — locate vs find

**What I ran:**

```bash
sudo dnf install plocate -y
sudo updatedb
locate passwd
```

**Output:**

```
/etc/passwd
/etc/passwd-
/etc/pam.d/passwd
/etc/security/opasswd
/usr/bin/gpasswd
/usr/bin/passwd
...
```

**What I learned:** `plocate` was already installed — the database just hadn't been built yet. `updatedb` built it. `locate` searches a pre-built index on disk, not the live filesystem — that's why it returns instantly. `find` walks the actual directory tree in real time, every time. `locate` trades freshness for speed: the index can be hours old. If you create a file now and `locate` it immediately, it won't appear until the next `updatedb`. For recently created files, use `find`. On production systems `updatedb` runs nightly via cron.

One search for `passwd` returned four different things: the account database (`/etc/passwd`), its backup (`/etc/passwd-`), the PAM config (`/etc/pam.d/passwd`), and the binary (`/usr/bin/passwd`). Knowing the filesystem hierarchy tells you what each one is just from the path.

---

## Lab: Putting It Together

**Task:** Four navigation tasks using only listing and find commands, no notes.

**What I did:**

```bash
# 1. Find shell config file and show contents
find /home -type f -name ".*"
cat /home/student/.bash_profile

# 2. List everything in /usr/bin starting with "git"
find /usr/bin -type f -name "git*"

# 3. Find all .log files under /var/log owned by root
find /var/log -type f -name "*.log" -user root

# 4. Show 5 most recently modified files in /etc
ls -lt /etc | head -5
```

**Outcome:** All four tasks executed correctly.

**What each task revealed:**

- Task 1: `.bash_profile` found and read. Sources `.bashrc` on login. `.bashrc` is the file that matters for interactive shell config — `.bash_profile` usually just hands off to it.
- Task 2: `git` is not installed on this VM. Command was correct, result was accurate — nothing returned means nothing found.
- Task 3: Several `.log` files owned by root under `/var/log/tuned/` and `/var/log/anaconda/`. `Permission denied` on audit, sssd, gdm — running as student, those directories are root-only. Suppress with `2>/dev/null` in Topic 6.
- Task 4: `cups` was the most recently modified entry in `/etc` at 20:58 — print system config, touched during VM service setup. `-lt` sorts by time descending, `head -5` limits output.

**Errors hit:**

```
find: '/var/log/private': Permission denied
find: '/var/log/audit': Permission denied
...
```

**How I resolved them:** Expected behavior — non-root user hitting root-owned directories. Not an error in the command. Will suppress cleanly with `2>/dev/null` in Topic 6.

---

## What Stuck With Me

- **`pwd` first when disoriented.** Never guess where you are — one command tells you exactly.
- **`ls -lah` is the default.** Add `-t` for time sort, `-r` to reverse. Know the flags, not just the command.
- **`cd -` returns to previous directory.** Underused. Saves time when jumping between two locations.
- **`find` is live, `locate` is indexed.** `find` is always current and slower. `locate` is fast and potentially stale. Use `find` for recently created files.
- **`Permission denied` from `find` is not a broken command.** It's the OS working correctly. Redirect stderr to suppress it.

---

## Tips from Session

- `Permission denied` in `find` output means it hit a root-owned directory — not a bug in your command. Add `2>/dev/null` to suppress it cleanly. We'll drill this in Topic 6.
- On an unfamiliar system: `ls -lah ~` first, then `cat .bashrc`. Tells you who configured the environment and how it's set up.

---

> **Carry Forward:** Stderr redirection (`2>/dev/null`) to suppress permission errors from `find` — Topic 6. `.bashrc` editing for aliases and environment config — Topic 14. `-user` flag on `find` for permission-based searches — useful again in Topic 7 (permissions).