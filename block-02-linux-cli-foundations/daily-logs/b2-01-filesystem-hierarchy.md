# Filesystem Hierarchy — What the Directories Actually Are

**Block:** Block 2 — Linux CLI Foundations
**Topic:** Filesystem Hierarchy
**Filename:** `b2-01-filesystem-hierarchy.md`
**Path:** `block-02-linux-cli/daily-logs/b2-01-filesystem-hierarchy.md`

---

## The Big Picture

Linux has one tree. Everything hangs off `/` — the root. No drive letters, no
separate volumes you have to think about — just one hierarchy with everything
mounted into it. The directory names aren't arbitrary: each one has a defined
purpose, and knowing where things live is how you navigate a system you've
never touched before without getting lost.

`/proc` and `/sys` are virtual — the kernel generates what you see on the fly.
Nothing in those directories is stored on disk. That distinction matters when
you're reading system state vs. reading config files.

---

## Learning by Doing

### Drill 1 — List the root filesystem

**What I ran:**

```bash
ls /
```

**Output:**

```bash
afs  boot  etc   lib    media  opt   root  sbin  sys  usr
bin  dev   home  lib64  mnt    proc  run   srv   tmp  var
```

**What I learned:** The top-level directories map directly to function. `/etc` is configs, `/var` is variable data (logs), `/home` is user directories, `/dev` is devices, `/opt` is third-party software (Splunk installs to `/opt/splunk` by default). `/media` is for removable media mounts — not a folder for personal files. `/mnt` is a manual mount point you use yourself; `/media` is handled automatically by the system.

---

### Drill 2 — Explore /etc and /var/log

**What I ran:**

```bash
ls /etc | head -20
cd /var/log
ls
```

**Output:**

```
adjtime
aliases
alsa
alternatives
anacrontab
asound.conf
at.deny
audit
authselect
avahi
bash_completion.d
bashrc
bindresvport.blacklist
binfmt.d
bluetooth
brlapi.key
brltty
brltty.conf
chromium
chrony.conf
```

```
anaconda         gdm                tuned
audit            lastlog            vmware-network.1.log
boot.log         maillog            vmware-network.2.log
btmp             messages           vmware-network.3.log
chrony           private            vmware-network.log
cron             qemu-ga            vmware-vgauthsvc.log.0
cups             samba              vmware-vmsvc-root.log
dnf.librepo.log  secure             vmware-vmtoolsd-root.log
dnf.log          speech-dispatcher  vmware-vmtoolsd-student.log
dnf.rpm.log      spooler            vmware-vmusr-student.log
firewalld        sssd               wtmp
```

**What I learned:** Every service writes its own log to `/var/log`. The filenames tell you exactly what's inside. `secure` — authentication events, SSH logins, sudo usage, failed attempts. First place to check for anything security-related. `messages` — general system catch-all. `dnf.log` — package manager activity. `boot.log` — what happened at boot, services that failed to start. `btmp`, `wtmp`, `lastlog` are login records but not plain text — read them with `last`, `lastb`, `lastlog`.

---

### Drill 3 — /home, /usr/bin, and /proc

**What I ran:**

```bash
ls /home
ls /usr/bin | head -20
cat /proc/cpuinfo | head -20
```

**Output:**

```
student
```

```
[
aarch64-redhat-linux-gnu-pkg-config
ac
aconnect
activate-global-python-argcomplete
addr2line
adwaita-1-demo
airscan-discover
alias
alsaloop
alsamixer
alsaunmute
amidi
amixer
amuFormat.sh
aplay
aplaymidi
aplaymidi2
appstreamcli
apropos
```

```
processor       : 0
BogoMIPS        : 48.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics ...
CPU implementer : 0x61
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0x000
CPU revision    : 0

processor       : 1
BogoMIPS        : 48.00
...
```

**What I learned:** `/proc/cpuinfo` is not a real file on disk. `/proc` is a virtual filesystem — the kernel generates content on the fly when you read it. Nothing is stored. `CPU implementer: 0x61` is Apple Silicon — expected on M2 running Rocky in VMware Fusion. 2 processors visible. `/usr/bin` is where most commands you actually run live — hundreds of binaries in one directory. When you type a command, this is one of the first places the shell looks.

---

### Drill 4 — Read disk usage

**What I ran:**

```bash
df -h
```

**Output:**

```
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/rl-root   17G  4.3G   13G  27% /
devtmpfs             1.2G     0  1.2G   0% /dev
tmpfs                1.2G  100K  1.2G   1% /dev/shm
/dev/nvme0n1p2       960M  468M  493M  49% /boot
/dev/nvme0n1p1       599M   13M  587M   3% /boot/efi
/dev/sr0             8.2G  8.2G     0 100% /run/media/student/Rocky-10-1-aarch64-dvd
```

**What I learned:** `/dev/mapper/rl-root` is the main disk — 17G mounted at `/`. Set up with LVM during install (`rl` is the volume group). `/dev/sr0` is the Rocky installer ISO still mounted — read-only, 100% used, not the working disk. `tmpfs` entries are in-memory filesystems, gone on reboot. When a disk fills up unexpectedly, `df -h` is the first command — tells you which filesystem is full, then dig with `du`.

---

### Drill 5 — Find top-level directories only

**What I ran:**

```bash
cd /
find . -maxdepth 1 -type d | sort
```

**Output:**

```
.
./afs
./boot
./dev
./etc
./home
./media
./mnt
./opt
./proc
./root
./run
./srv
./sys
./tmp
./usr
./var
```

**What I learned:** `.` in this context means current directory, not hidden files. Hidden files in Linux start with a dot in their filename (`.bashrc`, `.ssh`). `-maxdepth 1` keeps `find` from recursing into every subdirectory — without it, `find` walks the entire filesystem and dumps thousands of lines. Always scope `find` or it runs away from you. `-type d` filters to directories only.

---

## Lab: Putting It Together

**Task:** Read memory info, find SSH configs in `/etc`, find the secure log, read OS release info.

**What I did:**

```bash
cat /proc/meminfo | head -3
ls /etc | grep -i ssh
ls /var/log | grep -i secure
cat /etc/os-release
```

**Outcome:** All four commands returned expected output.

**What each command revealed:**

- `cat /proc/meminfo | head -3` — live memory state from the kernel. 2.4G total, ~1.2G available. Virtual file, not on disk.
- `ls /etc | grep -i ssh` — two SSH-related entries: `libssh` (library) and `ssh` (config directory). SSH config lives in `/etc/ssh/`.
- `ls /var/log | grep -i secure` — confirms `secure` log exists. Contains authentication events — SSH logins, sudo usage, failed attempts. Not passwords stored — authentication activity.
- `cat /etc/os-release` — Rocky Linux 10.1, `ID_LIKE="rhel centos fedora"` confirms RHEL-compatibility. Everything learned here transfers to RHEL in production. Support through 2035.

---

## What Stuck With Me

- **One tree, everything mounted into it.** No drive letters. `/` is the root, everything hangs off it.
- **`/proc` and `/sys` are virtual.** The kernel generates content on read. Nothing stored on disk.
- **`/var/log` is your first stop when something breaks.** Every service writes its own log. Learn the filenames and you know where to look without guessing.
- **`/dev/mapper/rl-root` is the main disk.** LVM volume group. `/dev/sr0` is the installer ISO — not the working disk.
- **Always scope `find`.** `-maxdepth 1` keeps it from recursing the entire filesystem. Build the habit now.

---

## Tips from Session

- When a disk fills unexpectedly: `df -h` first to find which filesystem, then `du -sh` to find what's eating space. That sequence is muscle memory for sysadmins.
- `ID_LIKE` in `/etc/os-release` tells you the distro lineage. First thing to check on an unfamiliar Linux system.

---

> **Carry Forward:** `/proc` process directories — Block 4. LVM volume groups — Block 4 Topic 12. `du` for disk usage — Block 2 Topic 11.