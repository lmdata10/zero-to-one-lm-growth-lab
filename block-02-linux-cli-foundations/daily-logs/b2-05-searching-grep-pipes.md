# Searching — grep, grep -r, grep -i, pipes

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Searching — `grep`, `grep -r`, `grep -i`, pipes `|` 
**Filename:** `b2-05-searching-grep-pipes.md`
**Path:** `block-02-linux-cli/daily-logs/b2-05-searching-grep-pipes.md`

---

## The Big Picture

If `tail -f` is how you watch logs live, `grep` is how you search through them after the fact. The name stands for Global Regular Expression Print — the practical meaning is: find lines that match a pattern.

The core behavior is simple — `grep "pattern" filename` scans every line and prints matches. The flags are what make it useful: `-i` for case-insensitive search, `-r` to recurse through directories, `-n` to show line numbers, `-v` to invert and show non-matching lines, `-c` to count instead of print. The flags get drilled below — the Big Picture is just the mental model.

The pipe `|` takes the output of one command and feeds it as input to the next. This is the Unix philosophy in action: small tools that do one thing well, chained together. Skip the useless `cat` — `grep "pattern" file` directly is cleaner and faster than `cat file | grep "pattern"`.

### Quick Reference

|Flag|What it does|
|---|---|
|`-i`|Case-insensitive match|
|`-r`|Recursive — search all files under a directory|
|`-n`|Show line numbers alongside matches|
|`-v`|Invert — show lines that do NOT match|
|`-c`|Count matching lines instead of printing them|
|`-l`|Show filenames only, not matching lines|
|`\|`|Pipe — feed stdout of one command into stdin of the next|

---

## Learning by Doing

### Drill 1 — Basic grep and case insensitive search

**What I ran:**

```bash
grep "student" /etc/passwd
grep -i "ROOT" /etc/passwd
```

**Output:**

```
student:x:1000:1000:student:/home/student:/bin/bash

root:x:0:0:Super User:/root:/bin/bash
operator:x:11:0:operator:/root:/usr/sbin/nologin
```

**What I learned:** `-i` made the search case-insensitive — searching for `ROOT` matched `root` in the file. It also caught `operator` because that line contains `/root` in the home directory field. `grep` matches anywhere in the line, not just the first field — worth keeping in mind when filtering `/etc/passwd` and getting unexpected results. Always check which field the match actually hit.

---

### Drill 2 — Line numbers and match count

**What I ran:**

```bash
grep -n "nologin" /etc/passwd
grep -c "nologin" /etc/passwd
```

**Output:**

```
2:bin:x:1:1:bin:/bin:/usr/sbin/nologin
3:daemon:x:2:2:daemon:/sbin:/usr/sbin/nologin
4:adm:x:3:4:adm:/var/adm:/usr/sbin/nologin
5:lp:x:4:7:lp:/var/spool/lpd:/usr/sbin/nologin
9:mail:x:8:12:mail:/var/spool/mail:/usr/sbin/nologin
...

32
```

**What I learned:** `-n` shows line numbers — useful when I need to go back and edit the file, or reference a specific line in a script. `-c` gives a count without printing the matches — useful for quick audits. 32 service accounts with `nologin` on this VM, confirmed in one command. I reach for `-n` when I need to locate something, `-c` when I just need the number.

---

### Drill 3 — Invert match and regex anchors

**What I ran:**

```bash
grep -v "#" /etc/ssh/sshd_config
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
```

**Output:**

```
# First command — strips lines containing # anywhere, leaves blank lines
Include /etc/ssh/sshd_config.d/*.conf
[blank lines between entries]
AuthorizedKeysFile      .ssh/authorized_keys
[blank lines]
Subsystem       sftp    /usr/libexec/openssh/sftp-server

# Second command — strips comment lines AND blank lines, clean output
Include /etc/ssh/sshd_config.d/*.conf
AuthorizedKeysFile      .ssh/authorized_keys
Subsystem       sftp    /usr/libexec/openssh/sftp-server
```

**What I learned:** `^` is a regex anchor meaning start of line. `^#` matches lines where `#` is the very first character — pure comment lines. The first command `-v "#"` is less precise — strips any line containing `#` anywhere, including mid-line occurrences. `^$` means start of line followed immediately by end of line — a blank line. Piping through `grep -v "^$"` strips those out.

The full pipeline: strip comment lines → strip blank lines → active config only. Three lines of active config on a stock SSH install. Everything else is comments. This pattern works on any heavily commented config file.

---

### Drill 4 — Recursive search and stderr redirection

**What I ran:**

```bash
sudo grep -r "PermitRootLogin" /etc/ssh/
sudo grep -r "failed" /var/log/ 2>/dev/null | head -10
```

**Output:**

```
/etc/ssh/sshd_config:#PermitRootLogin prohibit-password
/etc/ssh/sshd_config:# the setting of "PermitRootLogin prohibit-password".

/var/log/messages:Apr 11 17:53:44 localhost kernel: pci 0000:00:11.0: bridge window [io  size 0x1000]: failed to assign
/var/log/messages:Apr 11 17:53:44 localhost kernel: pci 0000:00:15.0: bridge window [io  size 0x1000]: failed to assign
...
```

**What I learned:** `-r` searched everything under `/etc/ssh/` recursively and found `PermitRootLogin` in `sshd_config` — commented out, meaning the default applies (`prohibit-password` — root can't SSH in with a password, only a key). I'll configure this properly in Block 4.

`2>/dev/null` — there are three standard streams: `0` stdin, `1` stdout, `2` stderr. `2>/dev/null` redirects stderr to `/dev/null`, a special file that discards everything written to it. Without it, `grep -r` across `/var/log/` floods the terminal with `Permission denied` errors. Normal output still comes through. I'll cover redirection fully in Topic 6.

The `failed` results are all PCI bridge assignment failures from boot — normal on a VM, not actual service failures. The kernel is noting hardware it couldn't configure on the virtual bus.

---

### Drill 5 — Pipes and grep in pipelines

**What I ran:**

```bash
ps aux | grep "ssh"
cat /etc/passwd | grep -v "nologin" | grep -v "false"
```

**Output:**

```
# ps aux | grep "ssh"
root        1295  0.0  0.2   8108  5988 ?  Ss  sshd: /usr/sbin/sshd -D [listener]
root        3309  0.0  0.3  17780  9624 ?  Ss  sshd-session: student [priv]
student     3313  0.0  0.3  17916  7584 ?  S   sshd-session: student@pts/0
student     4162  0.0  0.0 227496  1988 pts/0 S+ grep --color=auto ssh

# cat /etc/passwd | grep -v "nologin" | grep -v "false"
root:x:0:0:Super User:/root:/bin/bash
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
student:x:1000:1000:student:/home/student:/bin/bash
```

**What I learned:** The pipe feeds stdout of one command into stdin of the next. `ps aux` → filter for ssh lines. `cat passwd` → strip nologin → strip false → accounts with real shells remaining.

The last line of the first output — `grep --color=auto ssh` — is grep finding itself in the process list. `ps aux` captured it while it was running. Fix: add `grep -v grep` earlier in the pipeline, or use `pgrep ssh` instead. I'll fix this properly in the lab.

---

## Lab: Putting It Together

**Task:** Five search tasks combining grep flags and pipes.

**What I did:**

```bash
# 1. Find accepted SSH logins with line numbers
sudo grep -n "Accepted" /var/log/secure

# 2. Count accounts with /bin/bash
grep -c "/bin/bash" /etc/passwd

# 3. Recursive search for "student" in /etc
grep -r "student" /etc 2>/dev/null

# 4. Active config only from sshd_config
sudo grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# 5. sshd processes without self-grep
ps aux | grep -v grep | grep "sshd"
```

**Output:**

```
# Task 1
49:Apr 11 18:15:25 rocky-vm sshd-session[3370]: Accepted password for student from <vmware-host-ip> port 49592 ssh2
73:Apr 13 19:10:08 rocky-vm sshd-session[3309]: Accepted password for student from <vmware-host-ip> port 50260 ssh2
94:Apr 13 22:57:01 rocky-vm sshd-session[3985]: Accepted password for student from <vmware-host-ip> port 51333 ssh2

# Task 2
2

# Task 3
/etc/group:wheel:x:10:student
/etc/group:student:x:1000:
/etc/passwd:student:x:1000:1000:student:/home/student:/bin/bash
/etc/subgid:student:524288:65536
/etc/subuid:student:524288:65536
/etc/security/limits.conf:#@student        hard    nproc           20
/etc/security/limits.conf:#@student        -       maxlogins       4

# Task 4
Include /etc/ssh/sshd_config.d/*.conf
AuthorizedKeysFile      .ssh/authorized_keys
Subsystem       sftp    /usr/libexec/openssh/sftp-server

# Task 5
root        1295  sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        3309  sshd-session: student [priv]
student     3313  sshd-session: student@pts/0
root        3985  sshd-session: student [priv]
student     3989  sshd-session: student@pts/2
```

**Outcome:** All five tasks completed correctly.

**What each task revealed:**

- Task 1: Three accepted SSH logins on record, all from the Mac over VMware. Line numbers show exactly where each entry sits — useful context for investigating surrounding log entries with `-A` and `-B` flags.
- Task 2: Two accounts with `/bin/bash` — root and student. Quick shell audit in one command.
- Task 3: `/etc/subgid` and `/etc/subuid` entries for student — rootless container user namespace mapping. The system is already set up for rootless Podman. Relevant again in Block 7.
- Task 4: Three lines of active SSH config on a stock install. Everything else is comments.
- Task 5: `grep -v grep` earlier in the pipeline stripped the self-reference line. Clean sshd process list only. `pgrep sshd` is the cleaner alternative — covered in Topic 9.

**Errors hit:** None. Applied `2>/dev/null` on Task 3 proactively to suppress permission errors.

---

## What Stuck With Me

- **`grep` matches anywhere in the line.** Not just the field I'm targeting — check which field actually matched when results look unexpected.
- **`-i` by default.** Use case-sensitive only when case actually matters.
- **`^` anchors to start of line, `$` to end.** `^#` is comment lines. `^$` is blank lines. `grep -v "^#" | grep -v "^$"` is the active config pattern.
- **`-r` with `2>/dev/null`** is the standard recursive search across directories with mixed permissions.
- **Pipes chain left to right.** stdout of one command becomes stdin of the next. Chain as many as needed.
- **grep finds itself in `ps aux`.** Fix with `grep -v grep` in the pipeline or use `pgrep` directly.

---

## Tips from Session

- `grep -v "^#" file | grep -v "^$"` is the standard pattern for reading active config from any heavily commented file.
- Skip the useless `cat` — `grep "pattern" file` directly is cleaner and faster than `cat file | grep "pattern"`.
- `grep -r "pattern" /etc 2>/dev/null` is the fastest way to find which config file contains a setting when the location is unknown.

---

> **Carry Forward:** `2>/dev/null` and full redirection operators covered properly in Topic 6. `grep -A` and `-B` for context lines around a match — useful follow-on for log investigation. `pgrep` as a cleaner alternative to `ps aux | grep` — Topic 9 processes. `/etc/subgid` and `/etc/subuid` for rootless containers — Block 7 Containers.