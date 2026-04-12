# Block 2 — Linux CLI Foundations

**Target:** Navigate, manipulate, and inspect a Linux system without Googling basic commands.

---

## What This Block Is

Every role in my target trajectory — SysAdmin, Cloud Admin, DevOps, SRE — runs on Linux. This block builds the operating layer everything else sits on: filesystem navigation, file manipulation, permissions, users, processes, and text processing. Skip this and every block after it has gaps in it.

This isn't Linux appreciation. It's the hands-on muscle memory that makes Block 4 administration, Block 5 Python scripting, and eventually RHCSA feel like extensions of what you already know — not cold starts.

---

## Progress

| # | Topic | Status |
|---|-------|--------|
| 1 | Filesystem hierarchy — what `/etc`, `/var`, `/home`, `/usr`, `/tmp` actually are | ✅ |
| 2 | Navigation — `pwd`, `ls`, `cd`, `find`, `locate` | 🔄 |
| 3 | File manipulation — `touch`, `cp`, `mv`, `rm`, `mkdir`, `rmdir` | ⏳ |
| 4 | Reading files — `cat`, `less`, `more`, `head`, `tail`, `tail -f` | ⏳ |
| 5 | Searching — `grep`, `grep -r`, `grep -i`, pipes `\|` | ⏳ |
| 6 | Redirection — `>`, `>>`, `<`, `2>`, `/dev/null` | ⏳ |
| 7 | Permissions — `chmod`, `chown`, `chgrp`, octal vs symbolic, `umask` | ⏳ |
| 8 | Users and groups — `useradd`, `usermod`, `userdel`, `groupadd`, `/etc/passwd`, `/etc/shadow` | ⏳ |
| 9 | Processes — `ps`, `top`, `htop`, `kill`, `pkill`, `jobs`, `bg`, `fg`, `&` | ⏳ |
| 10 | Package management — `dnf install/remove/update/search`, `rpm -q` | ⏳ |
| 11 | Disk and filesystem — `df -h`, `du -sh`, `lsblk`, `mount`, `umount` | ⏳ |
| 12 | Archiving — `tar`, `gzip`, `gunzip`, common flags | ⏳ |
| 13 | Text processing — `cut`, `awk`, `sed` (basics — enough to manipulate log output) | ⏳ |
| 14 | Environment — `env`, `export`, `PATH`, `.bashrc`, `.bash_profile` | ⏳ |
| 15 | Help system — `man`, `--help`, `apropos`, `tldr` | ⏳ |

Status options: ✅ Done / 🔄 In Progress / ⏳ Not Started

---

## Session Logs

| Log | Topic |
|-----|-------|
| [b2-01-filesystem-hierarchy.md](daily-logs/b2-01-filesystem-hierarchy.md) | Filesystem hierarchy — root tree, key directories, virtual filesystems, disk layout |

---

## Key Concepts From This Block

- Everything start from `/` root in Linux. Learn the directories, filenames, know where to look.
-  `/var/log` is where every service writes its logs.
-  `etc/` is where all configs live

[Fill as you go. One concept per bullet. Your words — not copy-pasted from the session log.]

---

## Exit Criteria

- [ ] Navigate any Linux system cold, no notes
- [ ] Create users, set permissions, manage processes without referencing docs
- [ ] At least 5 CLI one-liners in repo solving real tasks (log grep, disk check, etc.)

---

## Honest Assessment

[Fill at end of block — what clicked, what didn't, what you'd do differently.]