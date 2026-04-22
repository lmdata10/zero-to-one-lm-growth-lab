# Block 2 - Linux CLI Foundations

**Target:** Navigate, manipulate, and inspect a Linux system without Googling basic commands.

---

## What This Block Is

Every role in my target trajectory - Cloud Admin, DevOps, SRE, Platform Engineer, Cloud Security - runs on Linux. This block builds the operating layer everything else sits on: filesystem navigation, file manipulation, permissions, users, processes, and text processing. Skip this and every block after it has gaps in it.

This isn't Linux appreciation. It's the hands-on muscle memory that makes Block 4 administration, Block 5 Python scripting, and eventually RHCSA feel like extensions of what you already know - not cold starts.

---

## Progress

| # | Topic | Status |
|---|-------|--------|
| 1 | Filesystem hierarchy - what `/etc`, `/var`, `/home`, `/usr`, `/tmp` actually are | ✅ |
| 2 | Navigation - `pwd`, `ls`, `cd`, `find`, `locate` | ✅ |
| 3 | File manipulation - `touch`, `cp`, `mv`, `rm`, `mkdir`, `rmdir` | ✅ |
| 4 | Reading files - `cat`, `less`, `more`, `head`, `tail`, `tail -f` | ✅ |
| 5 | Searching - `grep`, `grep -r`, `grep -i`, pipes `\|` | ✅ |
| 6 | Redirection - `>`, `>>`, `<`, `2>`, `/dev/null` | ✅ |
| 7 | Permissions - `chmod`, `chown`, `chgrp`, octal vs symbolic, `umask` | ✅ |
| 8 | Users and groups - `useradd`, `usermod`, `userdel`, `groupadd`, `/etc/passwd`, `/etc/shadow` | ✅ |
| 9 | Processes - `ps`, `top`, `htop`, `kill`, `pkill`, `jobs`, `bg`, `fg`, `&` | ✅ |
| 10 | Package management - `dnf install/remove/update/search`, `rpm -q` | ✅ |
| 11 | Disk and filesystem - `df -h`, `du -sh`, `lsblk`, `mount`, `umount` | ✅ |
| 12 | Archiving - `tar`, `gzip`, `gunzip`, common flags | ✅ |
| 13 | Text processing - `cut`, `awk`, `sed` | ✅ |
| 14 | Environment - `env`, `export`, `PATH`, `.bashrc`, `.bash_profile` | ✅ |
| 15 | Help system - `man`, `--help`, `apropos`, `tldr` | ✅ |

---

## Session Logs

| Log | Topic |
|-----|-------|
| [b2-01-filesystem-hierarchy.md](daily-logs/b2-01-filesystem-hierarchy.md) | Filesystem hierarchy - root tree, key directories, virtual filesystems, disk layout |
| [b2-02-navigation.md](daily-logs/b2-02-navigation.md) | Navigation - pwd, ls, cd, find, locate |
| [b2-03-file-manipulation.md](daily-logs/b2-03-file-manipulation.md) | File manipulation - touch, cp, mv, rm, mkdir, rmdir |
| [b2-04-reading-files.md](daily-logs/b2-04-reading-files.md) | Reading files - cat, less, more, head, tail, tail -f |
| [b2-05-searching.md](daily-logs/b2-05-searching.md) | Searching - grep, grep -r, grep -i, pipes |
| [b2-06-redirection.md](daily-logs/b2-06-redirection.md) | Redirection - >, >>, <, 2>, /dev/null |
| [b2-07-permissions.md](daily-logs/b2-07-permissions.md) | Permissions - chmod, chown, chgrp, octal vs symbolic, umask |
| [b2-08-users-and-groups.md](daily-logs/b2-08-users-and-groups.md) | Users and groups - useradd, usermod, userdel, groupadd, /etc/passwd, /etc/shadow |
| [b2-09-processes.md](daily-logs/b2-09-processes.md) | Processes - ps, top, htop, kill, pkill, jobs, bg, fg, & |
| [b2-10-package-management.md](daily-logs/b2-10-package-management.md) | Package management - dnf install/remove/update/search, rpm -q |
| [b2-11-disk-and-filesystem.md](daily-logs/b2-11-disk-and-filesystem.md) | Disk and filesystem - df -h, du -sh, lsblk, mount, umount |
| [b2-12-archiving.md](daily-logs/b2-12-archiving.md) | Archiving - tar, gzip, gunzip, common flags |
| [b2-13-text-processing.md](daily-logs/b2-13-text-processing.md) | Text processing - cut, awk, sed |
| [b2-14-environment.md](daily-logs/b2-14-environment.md) | Environment - env, export, PATH, .bashrc, .bash_profile |
| [b2-15-help-system.md](daily-logs/b2-15-help-system.md) | Help system - man, --help, apropos, tldr |

---

## Key Concepts From This Block

- Everything starts from `/` root. Learn the directories - know where to look before you start searching.
- `/var/log` is where every service writes its logs. First place to check when something breaks.
- `/etc/` is where all configs live. Read before you edit. Back up before you change.
- Linux operates on UIDs and GIDs, not names. The kernel checks numbers against inode ownership.
- Permissions are three sets of three bits - owner, group, others. Octal in scripts, symbolic interactively.
- `/etc/shadow` exists because `/etc/passwd` is world-readable. Hashes can't live in a file anyone can read.
- `kill` default is SIGTERM - polite request. `kill -9` is force. Always try SIGTERM first.
- `df -h` for space, `du -sh` for what's using it. 80% threshold - don't wait for 90%.
- `tar` bundles, `gzip` compresses. The `z` flag does both. Always inspect with `-t` before extracting.
- `grep` finds, `cut` extracts columns, `awk` filters and reformats, `sed` edits. Chain with pipes.
- `export` pushes a variable into child process environments. Writing to `.bashrc` makes it permanent.
- `--help` for flags, `tldr` for examples, `man` for full reference, `apropos` when you don't know the command.
- `userdel -r` always - without `-r` the home directory orphans and the UID can be reassigned.
- `mount` is temporary. fstab is permanent. A mount without an fstab entry dies on reboot.

---

## Exit Criteria

- [x] Navigate any Linux system cold, no notes
- [x] Create users, set permissions, manage processes without referencing docs
- [x] At least 5 CLI one-liners in repo solving real tasks (log grep, disk check, etc.)

---

## Honest Assessment

## Honest Assessment

**What clicked:** The mental model approach worked — analogy first, then detail. Permissions, users, and environment concepts landed cleanly once the "why" was clear. Hands-on execution in the terminal beat any passive watching — doing the drills myself instead of watching someone else do them eliminated procrastination and made retention stick. The one-liner pattern-action tools (`grep`, `awk`, `sed`) clicked once I saw them chained together solving actual problems.

**What was hard:** Processes, disk/filesystem operations, and package management still have grey areas — they're dense topics and the context didn't always feel real in isolation. I kept thinking "this doesn't match what happens in production" and second-guessed whether I was learning the right way. `find` deserves more depth than it got — wildcards too. These will come up heavily in Block 3 scripting, so revisiting with real context (finding files for a backup, pattern matching in loops) will sharpen them.

**What I'd do differently:** Lab tasks should be framed as real scenarios — not just "create a user and set permissions" but "provision a service account for nginx, lock it with /sbin/nologin, add it to the web group." The format and pacing worked well — analogy, drills one-by-one, hands-on lab, session log capture — but the scenarios need to feel like work, not exercises. Also: side comments next to commands in drills would have helped me understand not just what runs, but why I'm running it in that moment.

**On passive learning:** Resisted the urge to watch YouTube tutorials or buy more udemy courses. They feel authoritative but they'd have made me passive again. Hands-on first, certs later — that's the right sequence for foundation work. Will revisit Block 2 topics as they come up in Block 4 administration with real production context.

**Topics to revisit:** Processes (systemd context in Block 4), disk operations (LVM in Block 4), package management (repo config and version locking in Block 4). They're not weak — just need real application to settle.