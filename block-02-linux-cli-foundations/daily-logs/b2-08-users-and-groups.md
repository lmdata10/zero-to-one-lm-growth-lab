# Users and Groups — useradd, usermod, userdel, groupadd, /etc/passwd, /etc/shadow

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Users and Groups — `useradd`, `usermod`, `userdel`, `groupadd`, `/etc/passwd`, `/etc/shadow` 
**Filename:** `b2-08-users-and-groups.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-08-users-and-groups.md`

---
## The Big Picture

Linux doesn't know who you are — it knows a number. Every user is a UID, every group is a GID. When you access a file, the kernel checks those numbers against the file's ownership. Names like `student` or `wheel` are just labels humans read. The system only operates on numbers.

Three files underpin all user management:

- `/etc/passwd` — one line per user: username, UID, GID, home dir, shell
- `/etc/shadow` — password hashes, root-readable only (passwd is world-readable — hashes can't live there)
- `/etc/group` — group names, GIDs, and member lists

Creating a user writes to all three. Deleting one removes those entries. Read these files directly and you know exactly what's on the system — no GUI needed.

### Quick Reference

| Concept          | Detail                                                            |
| ---------------- | ----------------------------------------------------------------- |
| User database    | `/etc/passwd` — world-readable, no hashes                         |
| Password hashes  | `/etc/shadow` — root only, `!` prefix = locked                    |
| Group database   | `/etc/group` — names, GIDs, members                               |
| Create user      | `useradd -m -s /bin/bash -c "Full Name" username`                 |
| `-m` / `-M`      | create / suppress home directory                                  |
| `-r`             | system account — UID below 1000, no home by default               |
| Modify user      | `usermod -aG groupname username` — always `-aG`, never `-G` alone |
| Delete user      | `userdel -r username` — always `-r`, cleans home dir              |
| Set password     | `echo "user:pass" \| sudo chpasswd` — non-interactive             |
| Lock / unlock    | `passwd -l` prepends `!` to hash — `passwd -u` removes it         |
| Service accounts | `/sbin/nologin` — runs processes, blocks interactive login        |

---

## Learning by Doing

### Drill 1 — Read the user database directly

**What I ran:**

```bash
getent passwd student
id student
```

**Output:**

```
student:x:1000:1000:student:/home/student:/bin/bash
uid=1000(student) gid=1000(student) groups=1000(student),10(wheel)
```

**What I learned:** The passwd fields in order: `username:password:UID:GID:GECOS:home:shell`. The `x` in the password field means the actual hash is in `/etc/shadow`. GECOS is the comment field — usually full name or description, blank or copied from username on automated installs. `id` shows supplementary groups that `passwd` doesn't — `wheel` appears here, which is what gives sudo access on RHEL-based systems.

---

### Drill 2 — Check shadow and group files

**What I ran:**

```bash
sudo grep student /etc/shadow
grep student /etc/group
```

**Output:**

```
student:$y$j9T$8.JtFRamVdTCN6JmrliytMIC$1InXarMWcYIvwbAmHFMgc0lQ/gTrrBdycfihT/oHab/::0:99999:7:::
wheel:x:10:student
student:x:1000:
```

**What I learned:** Shadow fields in order: `username:hash:lastchanged:minage:maxage:warndays:inactive:expire:reserved`. The `$y$` prefix on the hash means yescrypt algorithm — current default on Rocky 9. `99999` for maxage means effectively no expiry (~273 years). Shadow exists as a separate file because `/etc/passwd` must be world-readable for the system to resolve UIDs to names — if the hash lived there, any user could copy it and run it through a cracker offline. Shadow is root-readable only. `student:x:1000:` in the group file shows the primary group with no explicit members listed — primary group membership is defined in passwd, not group.

---

### Drill 3 — Create a user and observe what changes

**What I ran:**

```bash
sudo useradd -m -s /bin/bash -c "Test User" testuser
getent passwd testuser
sudo grep testuser /etc/shadow
grep testuser /etc/group
ls -ld /home/testuser
```

**Output:**

```
testuser:x:1001:1001:Test User:/home/testuser:/bin/bash
testuser:!:20560:0:99999:7:::
testuser:x:1001:
drwx------. 3 testuser testuser 78 Apr 16 22:23 /home/testuser
```

**What I learned:** `-m` creates the home directory, `-s` assigns the shell, `-c` sets the GECOS field. The `!` in the shadow hash field means the account has no password set and is locked — the user exists but cannot log in until a password is set with `passwd`. On RHEL-based systems, `useradd` without `-m` does not create a home directory — this is different from Debian-based systems which create it by default. Home dir permissions are `700` — only the owner can access it.

---

### Drill 4 — Modify a user and set a password

**What I ran:**

```bash
sudo usermod -aG wheel testuser
id testuser
echo "testuser:TempPass123!" | sudo chpasswd
sudo grep testuser /etc/shadow
```

**Output:**

```
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser),10(wheel)
testuser:$y$j9T$F.fQmBtvEVhscqCeYkCl71$...:20560:0:99999:7:::
```

**What I learned:** `-aG` appends to the supplementary group list. `-G` without `-a` replaces the entire list silently — no warning, no confirmation. A user already in five groups gets reduced to just the specified group. Always use `-aG` together. `chpasswd`reads `username:password` pairs from stdin — designed for scripted or bulk password setting. `passwd --stdin` does the same thing differently. The `!` in shadow is gone once the password is set — account is now unlocked and loginable.

**Errors hit:**

```
passwd: Authentication token manipulation error
passwd: password unchanged
```

**How I resolved it:** Interactive `passwd` failed due to a PAM/SELinux configuration issue on Rocky 9. Used `chpasswd` as the non-interactive alternative — same result, different path.

---

### Drill 5 — Delete a user and observe orphaned files

**What I ran:**

```bash
sudo userdel testuser
getent passwd testuser
ls -ld /home/testuser
sudo userdel -r testuser 2>/dev/null || echo "user already deleted"
ls -ld /home/testuser 2>/dev/null || echo "home dir gone"
grep testuser /etc/group
sudo rm -rf /home/testuser
```

**Output:**

```
(blank — user gone from passwd)
drwx------. 3 1001 1001 78 Apr 16 22:23 /home/testuser
user already deleted
drwx------. 3 1001 1001 78 Apr 16 22:23 /home/testuser
(blank — not in group)
```

**What I learned:** `userdel` without `-r` removes the user from `/etc/passwd`, `/etc/shadow`, and `/etc/group` but leaves the home directory on disk. The directory then shows `1001 1001` instead of `testuser testuser` — the kernel can't resolve the UID to a name because that mapping no longer exists. `-r` removes the home directory and mail spool along with the account entry. Since the user was already deleted before `-r` ran, the cleanup was skipped and the directory had to be removed manually. Two risks with orphaned home dirs: disk accumulation on systems with frequent user churn, and UID reassignment — if `1001` is reused for a new user, they inherit the old home directory and everything in it.

---

## Lab: Putting It Together

**Task:** Full provisioning workflow — service account, group, dev user, lock/unlock, clean teardown.

**What I did:**

```bash
# Service account — no shell, no home dir
sudo useradd -s /sbin/nologin -M -c "App Service Account" svcapp

# Group creation and membership
sudo groupadd appteam
sudo usermod -aG appteam svcapp

# Verify
getent passwd svcapp
id svcapp
grep appteam /etc/group

# Dev user with home dir and shell
sudo useradd -m -s /bin/bash -c "Dev User" devuser
echo "devuser:complexpassword123" | sudo chpasswd

# Lock and verify
sudo passwd -l devuser
sudo grep devuser /etc/shadow

# Unlock and verify
sudo passwd -u devuser
sudo grep devuser /etc/shadow

# Clean teardown
sudo userdel -r devuser
sudo userdel -r svcapp
sudo groupdel appteam

# Verify gone
ls -ld /home/devuser 2>/dev/null || echo "home dir gone"
getent group appteam
```

**Output (key lines):**

```
svcapp:x:1003:1003:App Service Account:/home/svcapp:/sbin/nologin
uid=1003(svcapp) gid=1003(svcapp) groups=1003(svcapp),1004(appteam)
appteam:x:1004:svcapp

# Locked shadow entry
devuser:!$y$j9T$q0l/FFs8WDfWcNTqLQkK2/$...:20560:0:99999:7:::

# Unlocked shadow entry
devuser:$y$j9T$q0l/FFs8WDfWcNTqLQkK2/$...:20560:0:99999:7:::

home dir gone
(blank — appteam gone)
```

**Outcome:** All tasks completed. Both users and the group cleaned up with no orphaned directories or leftover entries.

**Errors hit:**

```
userdel: svcapp home directory (/home/svcapp) not found
```

**How I resolved it:** Not an error — expected behaviour. `-M` prevented home dir creation. The path in `/etc/passwd` is a field in a record, not a guarantee the directory was created. `userdel -r` tried to remove it, found nothing, warned and continued. Clean.

**Key distinction learned:** The home directory path in `/etc/passwd` is metadata — a default path stored in the record. `-M` tells `useradd` not to create the directory on disk. The field still gets populated. The kernel doesn't validate it at creation time.

`passwd -l` prepends `!` to the existing hash — it doesn't replace it. The original hash is preserved underneath. `passwd -u` strips the `!` and restores the account. Password unchanged throughout.

---

## What Stuck With Me

- **Linux operates on UIDs and GIDs, not names.** Names are labels for humans. The kernel checks numbers against inode ownership.
- **`/etc/passwd` is world-readable — `/etc/shadow` is not.** Shadow exists specifically to keep password hashes out of a file that any process can read.
- **`useradd` on RHEL does not create a home dir without `-m`.** Debian does. Know which distro you're on.
- **`-aG` always, never `-G` alone.** `-G` without `-a` silently replaces the full supplementary group list.
- **`userdel -r` always.** Without it the home directory orphans on disk with a numeric UID that may get reassigned.
- **`passwd -l` prepends `!`, doesn't wipe the hash.** Lock is reversible. Unlock restores the original hash.
- **Service accounts get `/sbin/nologin`.** The account runs processes and owns files — it is not a person. `nologin` prevents interactive shell access while leaving the account functional for the service.

---

## Tips from Session

- Always `userdel -r` unless there is a specific reason to keep the home directory. Orphaned dirs accumulate silently and create a UID reassignment risk.
- `-aG` and `-G` look similar and do completely different things. `-G` alone is a footgun — no warning, silent group list replacement. Muscle memory: always type `-aG`.
- Service accounts should use `/sbin/nologin` and be created with `-r` (system account, UID below 1000) when the account is for a daemon or service process, not a human.

---

> **Carry Forward:** `passwd -l` / `passwd -u` account locking revisited in Block 4 PAM topic — faillock and account lockout policy builds on this. Service account creation pattern reused in Block 3 user provisioning script. `chpasswd` non-interactive password setting used directly in that script. Shadow file field details (password aging, expiry) covered in Block 4 Topic 6 PAM basics.