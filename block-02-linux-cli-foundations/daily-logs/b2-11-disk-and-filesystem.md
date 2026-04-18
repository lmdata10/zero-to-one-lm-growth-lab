# Disk and Filesystem — df -h, du -sh, lsblk, mount, umount

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Disk and Filesystem — `df -h`, `du -sh`, `lsblk`, `mount`, `umount` 
**Filename:** `b2-11-disk-and-filesystem.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-11-disk-and-filesystem.md`

---

## The Big Picture

Storage problems are silent until they're not. A filesystem that hits 100% doesn't slow down gracefully — writes fail, services crash, logs stop, databases corrupt. Three questions you're always answering: what storage does this system have (`lsblk`), how much is used vs available (`df -h`), and what's eating the space (`du -sh`).

Linux treats storage devices as files. `/dev/nvme0n1` is the whole disk. `/dev/nvme0n1p1` is a partition on it. Mounting attaches a partition to a directory in the filesystem tree — anything written to that directory hits that partition. `/etc/fstab` defines permanent mounts that survive reboots. A `mount` command without an fstab entry is temporary — gone after reboot.

### Quick Reference

|Concept|Detail|
|---|---|
|`lsblk`|list block devices — disks, partitions, mount points|
|`lsblk -f`|adds filesystem type, UUID, and usage %|
|`df -h`|disk space used vs available per filesystem|
|`df -h /path`|check a specific mount point|
|`du -sh /path`|total size of a directory, human readable|
|`du -sh /path/*`|size of each item inside a directory|
|`du -sh /* \| sort -rh`|find largest directories — pipe to sort|
|`mount /dev/X /mnt/Y`|attach a filesystem to a mount point|
|`umount /mnt/Y`|detach a filesystem cleanly|
|`umount -l /mnt/Y`|lazy umount — detach immediately, release when handles close|
|`lsof +D /mnt/Y`|find processes holding open files on a mount|
|`fuser -km /mnt/Y`|kill all processes on a mount — nuclear option, use carefully|
|`/etc/fstab`|persistent mount config — survives reboot|
|Disk threshold|80% investigate, 85% act — don't wait for 90%+|

---

## Learning by Doing

### Drill 1 — See what storage the system has

**What I ran:**

```bash
lsblk
lsblk -f
```

**Output:**

```
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sr0          11:0    1  8.1G  0 rom  /run/media/student/Rocky-10-1-aarch64-dvd
nvme0n1     259:0    0   20G  0 disk
├─nvme0n1p1 259:1    0  600M  0 part /boot/efi
├─nvme0n1p2 259:2    0    1G  0 part /boot
└─nvme0n1p3 259:3    0 18.4G  0 part
  ├─rl-root 253:0    0 16.4G  0 lvm  /
  └─rl-swap 253:1    0    2G  0 lvm  [SWAP]
```

**What I learned:** `nvme0n1` is the whole 20G disk. Partitions are subdivisions of it — `nvme0n1p1`, `nvme0n1p2`, `nvme0n1p3`. `nvme0n1p3` is handed to LVM which carves it into logical volumes — `rl-root` (16.4G, mounted at `/`) and `rl-swap` (2G). The MOUNTPOINTS column shows where each partition's contents are accessible in the filesystem tree. A mountpoint is a directory — unmount and the directory still exists but is empty, the partition's contents are no longer visible there. `lsblk -f`adds filesystem type, UUID, and usage percentage per partition.

---

### Drill 2 — Check disk space usage

**What I ran:**

```bash
df -h
df -h /
df -h /boot
```

**Output:**

```
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/rl-root   17G  4.5G   12G  28% /
/dev/nvme0n1p2       960M  468M  493M  49% /boot
/dev/nvme0n1p1       599M   13M  587M   3% /boot/efi
/dev/sr0             8.2G  8.2G     0 100% /run/media/student/Rocky-10-1-aarch64-dvd
```

**What I learned:** `Use%` is consumed space as a percentage of total. Production threshold: 80% investigate, 85% act. Waiting until 90%+ leaves no lead time — logs and databases can fill the remaining space in minutes. `/boot` at 49% is worth watching — old kernel versions accumulate there with each `dnf update`. Clean with `dnf remove --oldkernels` before it gets high. `/dev/sr0` at 100% is expected — read-only DVD ISO.

---

### Drill 3 — Find what's eating disk space

**What I ran:**

```bash
du -sh /var/* 2>/dev/null
du -sh /var/log/* 2>/dev/null
du -sh /tmp/* 2>/dev/null
```

**Output:**

```
100M    /var/cache
63M     /var/tmp
8.0M    /var/log
...
5.8M    /var/log/anaconda
```

**What I learned:** `-s` summarises — one total per argument instead of listing every subdirectory. `-h` is human readable. Workflow for a full filesystem: `df -h` to identify which filesystem is full, then `du -sh /mountpoint/* | sort -rh` to find the biggest directories, drill deeper into the largest until the culprit file or directory is found. Binary search on the directory tree — each `du` cuts the problem in half. `/var/cache` at 100M and `/var/tmp` at 63M are the top consumers here — on a production server `/var/log` for runaway logs and `/var/cache/dnf` for package cache buildup are the usual suspects.

---

### Drill 4 — Mount and umount a filesystem

**What I ran:**

```bash
lsblk
ls /mnt
sudo mount /dev/sr0 /mnt
ls /mnt
df -h /mnt
sudo umount /mnt
ls /mnt
```

**Output:**

```
hgfs
mount: /mnt: WARNING: source write-protected, mounted read-only.
AppStream  BaseOS  EFI  images  LICENSE  media.repo  RPM-GPG-KEY-Rocky-10
Filesystem  Size  Used Avail Use% Mounted on
/dev/sr0    8.2G  8.2G    0  100% /mnt
hgfs
```

**What I learned:** Before mount, `/mnt` shows only `hgfs` (VMware shared folder). After mounting `/dev/sr0`, the DVD ISO contents become visible at `/mnt`. After umount, `/mnt` returns to showing only `hgfs` — the mount point directory persists, the partition's contents are no longer accessible there. `umount` fails with "device is busy" if any process has an open file handle on the mount — a terminal sitting in that directory, a process reading from it, or a service running from it. Diagnose with `lsof +D /mountpoint` before taking action.

---

### Drill 5 — Check fstab and understand persistent mounts

**What I ran:**

```bash
cat /etc/fstab
```

**Output:**

```
UUID=9315d5d3-6eba-4eb6-91ae-32193ad72ed3 /          xfs   defaults        0 0
UUID=50281a04-416d-4158-bd99-0bfdd8a00e5b /boot       xfs   defaults        0 0
UUID=3E59-35A1                            /boot/efi   vfat  umask=0077      0 2
UUID=5dca0a63-cb98-4e41-b8d3-b816dcba846c none        swap  defaults        0 0
```

**What I learned:** fstab defines what gets mounted at boot and where. `mount` command is immediate but temporary — gone after reboot. fstab entry makes it permanent. Fields: UUID, mount point, filesystem type, options, dump flag, fsck order. UUIDs are used instead of device names like `/dev/sda1` because device names can shift when disks are added — UUID never changes. Removing the `/` entry means the system can't find its root filesystem and fails to boot. Removing `/boot`survives this boot but fails the next — kernel and initramfs become unreachable.

---

## Lab: Putting It Together

**Task:** Identify top disk consumer. Find three largest directories under `/var`. Find largest single file under `/var/log`. Check dnf cache size. Mount DVD ISO at `/mnt/labdisk`, verify, list contents, umount cleanly. Confirm gone with `df -h` and `lsblk`.

**What I did:**

```bash
# Check overall disk usage across all filesystems, identify the top consumer
df -h | sort -k5 -n -r
# /dev/sr0             8.2G  8.2G     0 100% /run/media/student/Rocky-10-1-aarch64-dvd
# /dev/nvme0n1p2       960M  468M  493M  49% /boot
# /dev/mapper/rl-root   17G  4.5G   12G  28% /

df -h /boot
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/nvme0n1p2  960M  468M  493M  49% /boot

# Find the three largest directories under /var
du -sh /var/* 2>/dev/null | sort -rh | head -3
# 100M    /var/cache
# 63M     /var/tmp
# 8.0M    /var/log

# Find the largest single file under /var/log
du -sh /var/log/* 2>/dev/null | sort -rh | head -1
# 5.8M    /var/log/anaconda


# Check how much space the dnf package cache is using
du -sh /var/cache/* 2>/dev/null | grep dnf
# 60M     /var/cache/dnf

# Create a directory called /mnt/labdisk, mount the DVD ISO there, verify it mounted, list the contents, then umount it cleanly
sudo mkdir /mnt/labdisk
df
# Filesystem          1K-blocks    Used Available Use% Mounted on
# /dev/mapper/rl-root  17141760 4690484  12451276  28% /
# devtmpfs              1194440       0   1194440   0% /dev
# tmpfs                 1221856       0   1221856   0% /dev/shm
# efivarfs                  256      34       223  14% /sys/firmware/efi/efivars
# tmpfs                  488744    9484    479260   2% /run
# tmpfs                    1024       0      1024   0% /run/credentials/systemd-journald.service
# /dev/nvme0n1p2         983040  478564    504476  49% /boot
# /dev/nvme0n1p1         613184   12860    600324   3% /boot/efi
# tmpfs                  244368     120    244248   1% /run/user/1000
# /dev/sr0              8503710 8503710         0 100% /run/media/student/Rocky-10-1-aarch64-dvd

sudo mount /dev/sr0 /mnt/labdisk
# mount: /mnt/labdisk: WARNING: source write-protected, mounted read-only.

ls /mnt
# hgfs  labdisk

sudo umount /mnt/labdisk

ls /mnt
# hgfs  labdisk
# looks there are some processes running which is why it is not getting unmounted properly
$ sudo lsof +D /mnt/labdisk
# lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/1000/gvfs
#       Output information may be incomplete.
# lsof: WARNING: can't stat() fuse.portal file system /run/user/1000/doc
#       Output information may be incomplete.
# Found that you need to kill the process

sudo fuser -km /mnt/labdisk
# turns out that was a blunder or could have a big one in real prod server. it kicked me out of the ssh session got me panicked
# ssh'd back in without issues

sudo umount /mnt/labdisk
# umount: /mnt/labdisk: not mounted.

ls /mnt
# hgfs  labdisk

sudo umount -l /mnt/labdisk
# umount: /mnt/labdisk: not mounted.

ls /mnt
# hgfs  labdisk
# something is off - might need to just remove /mnt/labdsik using sudo rmdir /mnt/labdisk


# Confirm the mount is gone with df -h and lsblk

df -h
# Filesystem           Size  Used Avail Use% Mounted on
# /dev/mapper/rl-root   17G  4.5G   12G  28% /
# devtmpfs             1.2G     0  1.2G   0% /dev
# tmpfs                1.2G     0  1.2G   0% /dev/shm
# efivarfs             256K   34K  223K  14% /sys/firmware/efi/efivars
# tmpfs                478M   16M  463M   4% /run
# /dev/nvme0n1p2       960M  468M  493M  49% /boot
# /dev/nvme0n1p1       599M   13M  587M   3% /boot/efi
# /dev/sr0             8.2G  8.2G     0 100% /run/media/student/Rocky-10-1-aarch64-dvd
# tmpfs                1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
# tmpfs                1.0M     0  1.0M   0% /run/credentials/getty@tty2.service
# tmpfs                239M  112K  239M   1% /run/user/1000

lsblk
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sr0          11:0    1  8.1G  0 rom  /run/media/student/Rocky-10-1-aarch64-dvd
# nvme0n1     259:0    0   20G  0 disk
# ├─nvme0n1p1 259:1    0  600M  0 part /boot/efi
# ├─nvme0n1p2 259:2    0    1G  0 part /boot
# └─nvme0n1p3 259:3    0 18.4G  0 part
#   ├─rl-root 253:0    0 16.4G  0 lvm  /
#   └─rl-swap 253:1    0    2G  0 lvm  [SWAP]
```


**Outcome:** All tasks completed. Mount and umount worked correctly.

**Errors hit:**

```
lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/1000/gvfs
```

Ran `fuser -km /mnt/labdisk` to clear what appeared to be blocking processes — this sent SIGKILL to every process holding a file handle on the mount including the active shell session, which terminated the SSH connection.

**How I resolved it:** SSH'd back in. The umount had already succeeded before `fuser` ran — subsequent `umount` attempts returned `not mounted` confirming it was already detached. `df -h` and `lsblk` confirmed `/mnt/labdisk` was not in the mount list.

**Key distinction learned:** `lsof` fuse warnings are harmless — not a sign that something is blocking the umount. `fuser -km` is the nuclear option — it kills every process with an open handle on the mount including your own shell. Always use `lsof +D /mountpoint` first to identify what's actually holding the mount open, confirm it's safe to kill, then act. On a production server `fuser -km` could take down a running service.

The mount point directory (`/mnt/labdisk`) persists after umount — `umount` only detaches the filesystem, it does not remove the directory. `rmdir /mnt/labdisk` to clean up.

---

## What Stuck With Me

- **`df -h` for space, `du -sh` for what's using it.** `df` shows filesystem-level usage. `du` drills into directories to find the culprit.
- **80% threshold, not 90%.** By 90% a runaway process can fill the rest in minutes. Investigate at 80%, act at 85%.
- **Mount is temporary, fstab is permanent.** A mount command without an fstab entry doesn't survive reboot.
- **UUIDs in fstab, not device names.** Device names shift when disks are added. UUIDs don't.
- **`lsof +D /mount` before `fuser -km`.** Identify what's holding the mount open before killing anything. `fuser -km` is last resort.
- **Mount point directory survives umount.** The directory stays, the filesystem detaches. Clean up with `rmdir` if no longer needed.

---

## Tips from Session

- Pipe `du -sh /path/* | sort -rh` to rank directories by size instantly — this is the actual workflow for hunting down a full filesystem.
- `fuser -km /mountpoint` kills everything with an open handle including your own shell. On a remote server that means losing your session. Always check `lsof +D` first.

---

> **Carry Forward:** LVM — physical volumes, volume groups, logical volumes, extending a volume — Block 4 Topic 12. `/etc/fstab` permanent mount entries for service directories revisited in Block 4. `logrotate` for managing `/var/log` growth — Block 4 Topic 10.