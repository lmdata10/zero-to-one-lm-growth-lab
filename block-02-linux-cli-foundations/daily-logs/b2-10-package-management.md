# Package Management — dnf install/remove/update/search, rpm -q

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Package Management — `dnf install/remove/update/search`, `rpm -q` 
**Filename:**`b2-10-package-management.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-10-package-management.md`

---

## The Big Picture

Every program on a Linux system gets there through a package — a compressed archive containing the binary, config files, man pages, and dependency metadata. `dnf` is the package manager on RHEL-based systems. It talks to configured repositories, resolves dependencies automatically, and keeps a full install history you can roll back. `rpm` is the lower-level tool underneath — it only knows what's already installed locally, no repo awareness. Use `dnf` for everything involving repos. Use `rpm` to interrogate what's already on the system or to install a raw `.rpm` file directly.

### Quick Reference

|Concept|Detail|
|---|---|
|`rpm -q package`|confirm a package is installed|
|`rpm -qi package`|detailed info — version, size, install date, repo|
|`rpm -ql package`|list every file the package owns|
|`rpm -qf /path/to/file`|find which package owns a file|
|`rpm -q --whatprovides /path`|find which package provides a binary or file|
|`dnf search term`|search package names and descriptions across repos|
|`dnf info package`|version, size, repo source, description before installing|
|`dnf install package -y`|install and skip confirmation prompt|
|`dnf remove package -y`|remove and resolve dependencies cleanly|
|`dnf check-update`|list available updates without applying them|
|`dnf update package`|update a specific package|
|`dnf list installed`|all installed packages with repo source|
|`dnf repolist`|enabled repos on the system|
|`dnf repolist all`|all repos including disabled|
|`dnf history`|full transaction audit trail with IDs|
|`dnf history undo <ID>`|roll back a specific transaction|
|`dnf provides /path`|like `--whatprovides` but searches repos too|

---

## Learning by Doing

### Drill 1 — Query an installed package with rpm

**What I ran:**

```bash
rpm -q bash
rpm -qi bash
rpm -ql bash | head -20
```

**Output:**

```
bash-5.2.26-6.el10.aarch64

Name        : bash
Version     : 5.2.26
Release     : 6.el10
Architecture: aarch64
Install Date: Sat 11 Apr 2026 05:50:01 PM
...
Summary     : The GNU Bourne Again shell
```

**What I learned:** `rpm -q` confirms a package is installed and returns the full version string. `rpm -qi` gives detailed metadata — version, install date, size, source repo, license. `rpm -ql` lists every file the package owns — useful when you need to find where a binary or config landed. `rpm` is local only — no repo communication, instant output. `dnf list installed` covers the same ground but includes repo source and is slower due to metadata handling.

---

### Drill 2 — Search for and install a package

**What I ran:**

```bash
dnf search tree
dnf info tree
sudo dnf install tree -y
tree /etc | head -20
```

**Output:**

```
Package tree-2.1.0-8.el10.aarch64 is already installed.
Nothing to do.
Complete!

/etc
├── adjtime
├── aliases
├── alsa
│   ├── alsactl.conf
...
```

**What I learned:** `dnf search` scans package names and descriptions across all enabled repos. `dnf info` shows version, size, and repo source before committing — use it on a real server to confirm you're pulling the right package from the right repo. `-y`bypasses the confirmation prompt — required in scripts where no human is present to answer. `tree` was already installed so dnf skipped the download and reported `Nothing to do` — `-y` still ran cleanly.

---

### Drill 3 — Check for updates and review history

**What I ran:**

```bash
sudo dnf check-update | head -10
dnf history
dnf history info 1
```

**Output:**

```
bind-libs.aarch64     32:9.18.33-10.el10_1.3   appstream
bind-utils.aarch64    32:9.18.33-10.el10_1.3   appstream
cockpit.aarch64       344-3.el10_1.rocky.0.1   baseos
...

ID  | Command line          | Date and time    | Action(s) | Altered
--------------------------------------------------------------------
 4  | install htop -y       | 2026-04-17 12:30 | Install   |    3
 3  | install epel-release  | 2026-04-17 12:30 | Install   |    1
 2  |                       | 2026-04-11 17:56 | I, U      |  181
 1  |                       | 2026-04-11 17:49 | Install   | 1256 EE
```

**What I learned:** `dnf check-update` shows what's available without applying anything — safe to run anytime. `dnf history` is the audit trail and rollback mechanism. Transaction ID 1 with 1256 packages is the base OS install — everything after is what was added manually. On a real server: something breaks after an update, check history to see exactly what changed, then `dnf history undo <ID>` to roll it back. Also useful when inheriting a server — history shows what was installed and when.

---

### Drill 4 — Remove a package and verify

**What I ran:**

```bash
sudo dnf remove tree -y
rpm -q tree
dnf list installed | grep tree
```

**Output:**

```
Dependencies resolved.
...
Complete!

package tree is not installed

ostree-libs.aarch64   2025.6-1.el10   @AppStream
```

**What I learned:** `dnf remove` resolves the full dependency graph — removes the package and anything pulled in solely to support it, and warns if something else depends on what you're removing. `rpm -e` removes only the specified package with no dependency checking — can silently orphan dependencies or break other packages. Always reach for `dnf remove`. The `ostree-libs` result in the grep is a string match on `tree`, not the `tree` package — `rpm -q tree` is the clean confirmation.

---

### Drill 5 — Query package providers and repo sources

**What I ran:**

```bash
dnf repolist
dnf repolist all | head -20
rpm -q --whatprovides /usr/bin/ssh
```

**Output:**

```
repo id      repo name
appstream    Rocky Linux 10 - AppStream
baseos       Rocky Linux 10 - BaseOS
epel         Extra Packages for Enterprise Linux 10 - aarch64
extras       Rocky Linux 10 - Extras

appstream           Rocky Linux 10 - AppStream          enabled
appstream-debuginfo Rocky Linux 10 - AppStream - Debug  disabled
...

openssh-clients-9.9p1-12.el10_1.rocky.0.1.aarch64
```

**What I learned:** `--whatprovides` answers "what package do I install to get this file or binary" — most useful when an error references a missing path and you don't know the package name. `dnf provides /path` does the same but also searches uninstalled packages in repos. Repo list shows four sources: `baseos` for core OS, `appstream` for applications, `extras` for additional Rocky packages, `epel` added manually for community packages like htop. Disabled repos exist in config but are ignored unless explicitly enabled with `--enablerepo`.

---

## Lab: Putting It Together

**Task:** Find the package providing curl. Check if wget is installed. Verify openssh-server version and repo. Install nmap, run a local scan, remove it cleanly. Review dnf history for all lab transactions.

**What I did:**

```bash
# find curl provider
rpm -q --whatprovides /usr/bin/curl

# check wget
rpm -q wget
dnf list installed wget

# openssh-server info
dnf info openssh-server

# nmap — search, info, install, scan, remove
dnf list nmap
dnf info nmap
sudo dnf install nmap -y
nmap 127.0.0.1
sudo dnf remove nmap -y

# history review
dnf history
```

**Output (key lines):**

```
curl-8.12.1-2.el10_1.2.aarch64
wget-1.24.5-5.el10.aarch64

openssh-server 9.9p1 — From repo: baseos

PORT     STATE SERVICE
22/tcp   open  ssh
631/tcp  open  ipp
9090/tcp open  zeus-admin

ID  | Command line      | Date and time    | Action(s) | Altered
 9  | remove nmap -y    | 2026-04-18 00:06 | Removed   |    1
 8  | install nmap -y   | 2026-04-18 00:02 | Install   |    1
```

**Outcome:** All tasks completed. Lab transaction IDs: 8 (install nmap), 9 (remove nmap).

**Errors hit:** None.

**Key distinction learned:** `dnf list` works when you know the exact package name. `dnf search` is for when you're not sure — it scans names and descriptions across all enabled repos. The nmap scan output is worth reading — ports 22 (ssh), 631 (cups), and 9090 (cockpit) are open on the VM. That's the actual attack surface. Revisit in Block 4 firewall hardening and Block 6 networking.

---

## What Stuck With Me

- **`dnf` for repos, `rpm` for local queries.** `dnf` resolves dependencies and talks to repos. `rpm` interrogates what's already installed — faster, no network touch.
- **`rpm -q --whatprovides /path`** — when you know the file you need but not the package name that provides it.
- **`dnf info` before installing on a real server.** Confirms version, size, and repo source before committing.
- **`dnf history` is the rollback mechanism.** Every transaction logged with an ID. `dnf history undo <ID>` reverses it.
- **`dnf remove` is dependency-aware, `rpm -e` is not.** Always reach for `dnf remove`.
- **`-y` in scripts.** No human to answer confirmation prompts — `-y` is required for automation.

---

## Tips from Session

- `rpm -qf /path/to/file` finds what package owns an already-installed file. `rpm -q --whatprovides` and `dnf provides` find what package you need to install to get a file. Know which direction you're querying.
- `dnf check-update` before any maintenance window — know what's pending before touching a production server.

---

> **Carry Forward:** `dnf.conf`, EPEL, and version locking covered in Block 4 Topic 13 — package management advanced. Repo configuration in `/etc/yum.repos.d/` comes up when adding third-party repos in Block 4. nmap revisited properly in Block 6 networking tools.