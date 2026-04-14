# `zero-to-one-lm-growth-lab`

Each block is sequenced intentionally. Don't skip ahead. Each one feeds the next.

---

## Current Progress

| Block | Status | Current Topic |
|-------|--------|---------------|
| Block 1 — Git & GitHub | ✅ Complete | — |
| Block 2 — Linux CLI Foundations | 🔄 In Progress | Topic 2 — Navigation |

**Block 2 — Linux CLI Foundations**
- [x] Topic 1: Filesystem hierarchy
- [x] Topic 2: Navigation
- [x] Topic 3: File manipulation
- [ ] Topic 4: Reading files
- [ ] Topic 5: Searching
- [ ] Topic 6: Redirection
- [ ] Topic 7: Permissions
- [ ] Topic 8: Users and groups
- [ ] Topic 9: Processes
- [ ] Topic 10: Package management
- [ ] Topic 11: Disk and filesystem
- [ ] Topic 12: Archiving
- [ ] Topic 13: Text processing
- [ ] Topic 14: Environment
- [ ] Topic 15: Help system

---

## Timeline

| Block / Cert | Topic                                     | Target                          |
| ------------ | ----------------------------------------- | ------------------------------- |
| Block 1      | Git & GitHub                              | Completed                       |
| Block 2      | Linux CLI Foundations                     | April 2026                      |
| Block 3      | Bash Scripting                            | April 2026                      |
| Block 4      | Linux Administration                      | May 2026                        |
| Block 5      | Python for SysAdmins                      | June 2026                       |
| Block 6      | Networking Fundamentals                   | June 2026                       |
| Block 7      | Docker Fundamentals                       | July 2026                       |
| Block 8      | Windows Server & PowerShell               | July-Aug 2026                   |
| Block 9      | AZ-104 Cert Prep                          | August–November 2026            |
| **Diploma**  | **NSCC IT Systems Management & Security** | **September 2026 — WAITLISTED** |
| Block 10     | AWS SAA Cert Prep                         | December 2026–March 2027        |
| Cert         | Security+                                 | April/May 2027                  |
| Cert         | SC-500 Cloud Security                     | Mid-2027 (Ottawa phase)         |
| Cert         | Terraform Associate                       | Mid-2027 (Ottawa phase)         |
| Cert         | RHCSA                                     | March/April 2028                |
| Cert         | EX188 — Container Specialist              | April/May 2028                  |
| Cert         | EX280 — OpenShift Administrator           | Mid-2028                        |
| Cert         | CKA                                       | Toronto phase (conditional)     |

---

## Diploma — Parallel Track

**NSCC IT Systems Management & Security** **Status:** Waitlisted. September 2026 start not confirmed. Curriculum continues regardless.

If confirmed, runs in parallel with Blocks 9–10 and cert prep.

Key integrations:

- `ISEC 2700` (Intro to Information Security) primes Security+
- `OSYS 1000` and `OSYS 3030` (Linux courses) compound Blocks 2–4 and prime RHCSA
- Windows Server diploma content compounds Block 8
- Goal: be ahead of the cohort in every technical subject from day one

Rule: curriculum blocks prime the diploma, not the other way around.

---

## Cert Sequence — Rationale

| **#** | **Cert**                      | **Timing**        | **Why**                                                                                                                                                  |
| ----- | ----------------------------- | ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | AZ-104 Azure Administrator    | Aug–Nov 2026      | Primary Halifax credential. Azure dominates Canadian enterprise. Portal-heavy — needs real console time.                                                 |
| 2     | AWS SAA-C03                   | Dec 2026–Mar 2027 | Cloud breadth. Concepts transfer from AZ-104. Opens Ottawa federal cloud roles. Splunk Cloud runs on AWS.                                                |
| 3     | Security+                     | Apr/May 2027      | If NSCC confirmed: ISEC 2700 makes this near-free effort. If not: study lightly alongside AWS SAA, sit opportunistically.                                |
| 4     | SC-500 Cloud Security         | Mid-2027          | Replaces AZ-500. Defender for Cloud, Sentinel, Purview. Highest-ceiling cert for Cloud Security Engineer path in Canada. Follows AZ-104 depth naturally. |
| 5     | Terraform Associate           | Mid-2027          | IaC in nearly every DevOps/Cloud Eng JD. Cloud-agnostic — works across Azure and AWS you'll have hands-on experience with.                               |
| 6     | RHCSA                         | Mar/Apr 2028      | Non-negotiable foundation for all Red Hat certs. Live terminal exam. 2+ years Blocks 2–4 + diploma Linux courses is the prep. Do not attempt early.      |
| 7     | EX188 Container Specialist    | Apr/May 2028      | Red Hat's bridge cert. Podman, Containerfiles, container networking. Fast pass (3–4 weeks) if Block 7 is solid. Required before EX280.                   |
| 8     | EX280 OpenShift Administrator | Mid-2028          | Destination cert for Red Hat path. Dominant in Canadian federal, telco, and financial sector. High value in Ottawa and Toronto enterprise.               |
| 9     | CKA                           | Toronto phase     | Upstream Kubernetes for tech-sector employers (Shopify, Wealthsimple). Conditional — evaluate based on Ottawa landing.                                   |

**Dropped:** RHCE. Learn Ansible on the job when a role requires it. The cert no longer justifies the time investment given SC-500, Terraform, and the Red Hat container path.

---

## Block 1 — Git & GitHub

- **Why first:** Everything built in every other block gets committed here. Start before writing a single script.
- **Target:** Using Git daily without thinking about it.
- **Estimated time:** 1–2 weeks | **Status: Near complete — topic 11 remaining**

### Topics

1. ✅ What Git actually is — mental model (snapshots, not diffs)
2. ✅ `git init`, `git status`, `git add`, `git commit` — the core loop
3. ✅ `.gitignore` — what to never commit
4. ✅ `git log`, `git diff`, `git show` — reading history
5. ✅ Remote repos — `git remote`, `git push`, `git pull`, `git clone`
6. ✅ Branching — `git branch`, `git checkout`, `git switch`, `git merge`
7. ✅ Fixing mistakes — `git restore`, `git reset`, `git revert`, `git reflog`
8. ✅ Writing useful commit messages — conventional commits format
9. ✅ GitHub-specific — README.md, repo structure, viewing diffs in UI
10. ✅ Real workflow — feature branch → commit → push → merge
11. ✅ `git rebase` — when and why

### Exit Criteria

- Can init, commit, push to GitHub without referencing notes
- `zero-to-one-labs` repo live with correct folder structure
- Every session ends with a commit — muscle memory confirmed

---

## Block 2 — Linux CLI Foundations

- **Why here:** Everything in your target roles touches Linux. Operating layer under all of it.
- **Target:** Navigate, manipulate, and inspect a Linux system without Googling basic commands.
- **Estimated time:** 3–4 weeks | **Target:** April–May 2026

### Topics

1. Filesystem hierarchy — what `/etc`, `/var`, `/home`, `/usr`, `/tmp` actually are
2. Navigation — `pwd`, `ls`, `cd`, `find`, `locate`
3. File manipulation — `touch`, `cp`, `mv`, `rm`, `mkdir`, `rmdir`
4. Reading files — `cat`, `less`, `more`, `head`, `tail`, `tail -f`
5. Searching — `grep`, `grep -r`, `grep -i`, pipes `|`
6. Redirection — `>`, `>>`, `<`, `2>`, `/dev/null`
7. Permissions — `chmod`, `chown`, `chgrp`, octal vs symbolic, `umask`
8. Users and groups — `useradd`, `usermod`, `userdel`, `groupadd`, `/etc/passwd`, `/etc/shadow`
9. Processes — `ps`, `top`, `htop`, `kill`, `pkill`, `jobs`, `bg`, `fg`, `&`
10. Package management — `dnf install/remove/update/search`, `rpm -q`
11. Disk and filesystem — `df -h`, `du -sh`, `lsblk`, `mount`, `umount`
12. Archiving — `tar`, `gzip`, `gunzip`, common flags
13. Text processing — `cut`, `awk`, `sed` (basics — enough to manipulate log output)
14. Environment — `env`, `export`, `PATH`, `.bashrc`, `.bash_profile`
15. Help system — `man`, `--help`, `apropos`, `tldr`

### Exit Criteria

- Navigate any Linux system cold, no notes
- Create users, set permissions, manage processes without referencing docs
- At least 5 CLI one-liners in repo solving real tasks (log grep, disk check, etc.)

---

## Block 3 — Bash Scripting

- **Why here:** CLI fluency → automation. Separates someone who uses Linux from someone who administers it.
- **Target:** Write scripts that get used — not exercises, real tools.
- **Estimated time:** 3–4 weeks | **Target:** May 2026

### Topics

1. What a shell script is — shebang, permissions, executing
2. Variables — declaring, referencing, quoting rules (most common source of bugs)
3. User input — `read`, positional parameters `$1 $2`, `$@`, `$#`
4. Conditionals — `if/elif/else`, test operators (`-f`, `-d`, `-z`, `-eq`, `-ne`)
5. String and numeric comparisons — `[[ ]]` vs `[ ]` and why it matters
6. Loops — `for`, `while`, `until`, `break`, `continue`
7. Functions — defining, calling, returning values, local variables
8. Exit codes — `$?`, `exit 0`, `exit 1`, using exit codes for error handling
9. Error handling — `set -e`, `set -u`, `set -o pipefail`, traps
10. Working with files — reading line by line, checking existence, writing output
11. Scheduling — `crontab -e`, cron syntax, logging cron output
12. Real script: System health check — disk, memory, running services, output to log
13. Real script: User provisioning — create user, set password policy, add to group, log action
14. Real script: Log parser — grep errors from `/var/log`, count occurrences, write report
15. Debugging — `bash -x`, `set -x`/`set +x`, common bugs

### Exit Criteria

- 3 real scripts in repo: system health check, user provisioning, log parser
- Each script has error handling, comments, and a usage message
- Can read someone else's bash script and explain what it does

---

## Block 4 — Linux Administration

- **Why here:** Block 2 was navigation. This block is ownership. This is the actual job.
- **Target:** Fully administer a Rocky Linux server — services, security, users, logs, networking basics.
- **Estimated time:** 3–4 weeks | **Target:** May–June 2026

> GitHub CLI adoption begins alongside this block.

### Topics

1. Systemd — `systemctl start/stop/restart/enable/disable/status`, unit files
2. Writing a basic systemd service unit — run your own script as a service
3. Logging with journald — `journalctl`, filtering by unit/time/priority, persistent logs
4. SSH — key-based auth, `~/.ssh/config`, disabling password auth, `sshd_config` hardening
5. sudo — `/etc/sudoers`, `visudo`, specific command access, logging sudo use
6. PAM basics — password policies, account lockout (`faillock`), `/etc/security/`
7. Firewall — `firewalld`, zones, `firewall-cmd`, permanent vs runtime rules
8. SELinux — mandatory access control, `getenforce`, `setenforce`, `audit2why`, booleans
9. Scheduled tasks — cron vs systemd timers, when to use which
10. Log management — `/var/log` structure, `logrotate`, finding the right log
11. Network configuration — `nmcli`, `ip addr`, `ip route`, static IP, DNS `/etc/resolv.conf`
12. Storage — LVM basics (PVs, VGs, LVs), extending a volume
13. Package management advanced — repos, `dnf.conf`, EPEL, version locking
14. Performance basics — `vmstat`, `iostat`, `sar`, load average, identifying bottlenecks
15. Backup basics — `rsync`, scheduling, verifying restores

### Exit Criteria

- Rocky Linux VM hardened: SSH key-only, firewall configured, SELinux enforcing
- Can bring a service down, diagnose why, and restore it
- Hardening checklist committed as a reusable runbook

---

## Block 5 — Python for SysAdmins

- **Why here:** Not Python-the-developer. Python-the-ops-person. Automate what Bash can't do cleanly.
- **Target:** Write Python scripts that replace manual ops tasks. Not building apps.
- **Estimated time:** 3 weeks | **Target:** June 2026

> Claude Code activates alongside this block — only once Pro plan is confirmed.

### Topics

1. Why Python for ops — when Bash isn't enough
2. Variables, types, strings, f-strings
3. Lists, dicts, loops — the data structures you'll actually use
4. Functions — defining, calling, default args
5. File I/O — reading and writing files, parsing text
6. `os` and `sys` modules — interacting with the system
7. `subprocess` — running shell commands from Python
8. Error handling — `try/except`, meaningful error messages
9. Working with JSON — `json` module, parsing API responses
10. `argparse` — making scripts that accept arguments like real tools
11. Real script: Parse a log file, extract errors, write summary report
12. Real script: Check system health via `subprocess`, output structured report
13. Real script: Automate a repetitive file/directory task

### Exit Criteria

- 3 real scripts in repo with argparse, error handling, and comments
- Can replace a Bash script with Python when the task warrants it
- Understands when to use Bash vs Python

---

## Block 6 — Networking Fundamentals

- **Why here:** AZ-104 networking domains, firewall work, and troubleshooting all require this. Without it, cloud networking is magic words.
- **Target:** Understand how data moves. Troubleshoot connectivity problems methodically.
- **Estimated time:** 3 weeks | **Target:** June–July 2026

### Topics

1. OSI model — practical only, not memorisation
2. IP addressing — classes, CIDR, subnetting
3. Subnetting practice — calculating ranges, hosts, broadcast
4. TCP vs UDP — what the difference actually means in practice
5. DNS — how resolution works, record types (A, AAAA, CNAME, MX, TXT)
6. DHCP — lease process, static vs dynamic
7. Routing basics — default gateway, routing tables, `ip route`
8. NAT — why it exists, how it works
9. Firewalls — packet filtering, stateful inspection, port rules
10. Common ports — 22, 80, 443, 3389, 53, 25, 465 — know them cold
11. CLI tools — `ping`, `traceroute`, `netstat`, `ss`, `nmap`, `curl`, `dig`, `nslookup`
12. Troubleshooting methodology — systematic "can't reach X" diagnosis
13. VPN conceptual — tunnels, encryption, split tunnelling
14. Cloud networking preview — how VNets/VPCs map to these fundamentals

### Exit Criteria

- Can subnet without a calculator (not fast, but correctly)
- Can troubleshoot "can't reach X" systematically using CLI tools
- Networking sections of AZ-104 don't feel like a foreign language

---

## Block 7 — Docker & Container Fundamentals

- **Why here:** Bridges Linux administration to cloud-native. AKS, Container Instances, and App Service containers are AZ-104 topics. Also directly primes EX188 — Podman and Docker share the same mental model. Doing Podman here means EX188 is a 3–4 week fast pass, not a cold start.
- **Target:** Run, build, and manage containers with both Docker and Podman. Explain why they exist.
- **Estimated time:** 2–3 weeks | **Target:** July 2026

### Topics

1. Container mental model — VMs vs containers, what Docker actually is
2. `docker run`, `docker ps`, `docker images`, `docker stop`, `docker rm`
3. Image vs container — the distinction that trips everyone up
4. Dockerfile basics — `FROM`, `RUN`, `COPY`, `CMD`, building your own image
5. Container networking — bridge networks, port mapping, container-to-container
6. Volumes — persisting data, bind mounts vs named volumes
7. `docker-compose` — defining multi-container apps, `up/down`
8. Podman — how it differs from Docker, rootless containers, `podman` CLI parity
9. Containerfiles — Podman's equivalent of Dockerfile, building images with Podman
10. Real lab: containerize a Python script from Block 5, run with both Docker and Podman
11. Where containers fit in real infrastructure — when to use them vs VMs

### Exit Criteria

- Build an image from a Dockerfile and run it without referencing docs
- Repeat the same workflow using Podman on Rocky Linux VM
- At least one containerized script committed to repo
- Can explain the difference between Docker and Podman and why Red Hat moved to Podman

---

## Block 8 — Windows Server & PowerShell

- **Why here:** Halifax market requires it. Diploma covers it heavily. AZ-104 includes Azure AD and hybrid identity. Being comfortable here before the diploma means ahead of cohort from day one.
- **Target:** Administer a Windows Server environment and write PowerShell scripts for common ops tasks.
- **Estimated time:** 3–4 weeks | **Target:** July–August 2026

> Lab: Windows Server 2025 VM (already in setup)

### Topics

1. Windows Server roles and features — what they are, how to add/remove
2. Active Directory — users, groups, OUs, domain structure
3. Group Policy — GPOs, linking, enforcement, troubleshooting
4. DNS and DHCP on Windows Server — setup, scopes, reservations
5. PowerShell fundamentals — syntax, pipeline, cmdlets, `Get-Help`
6. PowerShell for user management — `New-ADUser`, `Set-ADUser`, `Get-ADGroupMember`
7. PowerShell for file and service management — `Get-Service`, `Start-Service`, file ops
8. Remote Desktop and WinRM — remote management, `Enter-PSSession`
9. Windows firewall — rules, profiles, managing via PowerShell
10. Event logs and troubleshooting — Event Viewer, `Get-EventLog`, reading Windows logs
11. Real script: Bulk user creation from CSV via PowerShell
12. Real script: System report — disk, uptime, services via PowerShell

### Exit Criteria

- Create users, apply GPOs, manage services on Windows Server without referencing docs
- Two PowerShell scripts committed: bulk user creation, system report
- Windows Server concepts in the diploma require no cold start

---

## Block 9 — AZ-104 Cert Prep

- **Why here:** Azure is the primary cert target for Halifax and Ottawa. Docker and Windows Server blocks make the content land — containers, AD, and hybrid identity all appear on the exam.
- **Target:** Pass AZ-104. Understand Azure well enough to work in it, not just answer questions.
- **Estimated time:** 10–12 weeks | **Target:** August–November 2026
- **Schedule exam:** When practice scores consistently hit 80%+

> Start Azure free account when this block begins — not before. Preserves the 12-month window. Use Microsoft Learn sandboxes for labs wherever possible to preserve free credit.

### Format

Domain-based. Each session: concept review → Microsoft Learn lab → practice question set → domain log → weak areas flagged.

### Domains

1. **Manage Azure Identities and Governance** (~20–25%)
    
    - Azure AD — users, groups, roles, licenses
    - RBAC — built-in roles, custom roles, scope
    - Subscriptions and resource groups — management hierarchy
    - Azure Policy — definitions, initiatives, compliance
    - Resource locks and tags
2. **Implement and Manage Storage** (~15–20%)
    
    - Storage accounts — types, replication, access tiers
    - Blob storage — containers, lifecycle, access levels
    - Azure Files — file shares, sync, mounting
    - Storage security — SAS tokens, access keys, private endpoints
3. **Deploy and Manage Azure Compute** (~20–25%)
    
    - Virtual machines — sizes, disks, availability sets, scale sets
    - VM extensions and custom script extension
    - App Service — plans, deployment, scaling
    - Azure Container Instances and AKS basics
    - Azure Functions conceptual
4. **Implement and Manage Virtual Networking** (~15–20%)
    
    - VNets and subnets — design, peering
    - NSGs — rules, association, flow logs
    - Azure DNS — zones, records, private DNS
    - VPN Gateway and ExpressRoute conceptual
    - Load Balancer and Application Gateway basics
5. **Monitor and Maintain Azure Resources** (~10–15%)
    
    - Azure Monitor — metrics, logs, alerts
    - Log Analytics — queries, workbooks
    - Azure Backup — vaults, policies, restore
    - Azure Site Recovery conceptual
6. **Exam Readiness**
    
    - Full practice exams (Tutorial Dojo or Whizlabs)
    - Weak domain targeted review
    - Timing drills — 60 questions in 120 minutes

### Exit Criteria

- Practice exam 80%+ consistently across two separate sittings
- Can navigate Azure portal and explain any resource created during labs
- AZ-104 passed ✓

---

## Block 10 — AWS SAA Cert Prep

- **Why here:** AZ-104 done, cloud concepts transfer significantly. AWS free tier gives 12-month runway. Directly relevant to Splunk Cloud infrastructure. Opens Ottawa federal cloud roles.
- **Target:** Pass AWS SAA-C03. Understand AWS architecture well enough to design and defend solutions.
- **Estimated time:** 10–12 weeks | **Target:** December 2026–March 2027
- **Schedule exam:** When practice scores consistently hit 80%+

> Start AWS free account when this block begins. Use AWS CloudShell for CLI practice.

### Format

Same rhythm as AZ-104: concept review → hands-on lab → practice questions → log → weak areas flagged.

### Domains

1. Cloud Fundamentals and AWS Global Infrastructure (~10%)
2. IAM and Security (~15%)
3. Compute (~20%)
4. Storage (~15%)
5. Networking (~20%)
6. Databases (~10%)
7. Architecture and Well-Architected Framework (~10%)
8. Exam Readiness

### Exit Criteria

- Practice exam 80%+ consistently across two separate sittings
- Can explain AWS architecture decisions and trade-offs out loud
- AWS SAA-C03 passed ✓

---

## Security+ — Target: April/May 2027

- **Why this timing:** Diploma `ISEC 2700` runs Year 1 and primes the content. Security+ builds on it.
- **If NSCC not confirmed:** Study lightly alongside AWS SAA and sit opportunistically. Don't run a full dedicated study cycle — SC-500 is the higher-value security cert for this path.
- **Resources:** Professor Messer (free) + Dion practice exams
- **Format:** Self-study on off days. One focused month of practice exams before sitting.

---

## SC-500 — Cloud Security — Target: Mid-2027 (Ottawa phase)

- **Why this cert:** Replaces AZ-500. Covers Microsoft Defender for Cloud, Sentinel, Purview, and cloud-native security operations. Highest-ceiling cert in the Canadian market for the Cloud Security Engineer target. Follows naturally from AZ-104 Azure depth.
- **Why this timing:** Ottawa phase — working in cloud environments makes the content immediately applicable. SC-500 + AZ-104 + AWS SAA is a strong security-leaning cloud profile for federal and financial sector.
- **Resources:** Microsoft Learn + SC-500 study guide

---

## Terraform Associate — Target: Mid-2027 (Ottawa phase)

- **Why this cert:** IaC appears in nearly every Cloud Engineer and DevOps JD. Cloud-agnostic — works across Azure and AWS, both of which you'll have hands-on experience with by this point.
- **Resources:** Bryan Krausen (Udemy) + HashiCorp Learn platform (free labs)
- **Format:** Hands-on only. Every concept gets deployed to a real cloud environment.

---

## RHCSA — Target: March/April 2028

- **Why this timing:** Blocks 2, 3, 4 plus diploma Linux courses provide 2+ years of daily hands-on Linux. RHCSA is a live terminal exam — rewards real experience, not cramming.
- **Why non-negotiable:** Required foundation for EX188 and EX280. Skipping it creates gaps that show up in live exam environments.
- **Resources:** Sander van Vugt RHCSA course + Red Hat learning path
- **Rule:** Do not attempt until 12+ months of real daily Linux use.

---

## EX188 — Container Specialist — Target: April/May 2028

- **Why here:** Red Hat's bridge cert between RHCSA and OpenShift. Covers Podman, Containerfiles, container networking, image management. Block 7 provides the foundation — EX188 formalises it.
- **Estimated prep:** 3–4 weeks post-RHCSA if Block 7 was done properly.
- **Resources:** Red Hat container labs + Podman documentation
- **Format:** Live hands-on exam.

---

## EX280 — OpenShift Administrator — Target: Mid-2028

- **Why this cert:** Destination cert for the Red Hat path. Dominant in Canadian federal government, telco, and financial sector. High value in Ottawa and Toronto enterprise markets.
- **Why this timing:** RHCSA → EX188 → EX280 is Red Hat's own sequence. Each assumes the previous.
- **Resources:** Red Hat DO280 course + OpenShift Developer Sandbox (free)
- **Format:** Live cluster exam. Administer a running OpenShift environment under time pressure.

---

## CKA — Certified Kubernetes Administrator — Target: Toronto phase (conditional)

- **Why conditional:** If Ottawa lands in OpenShift-heavy environments, CKA adds limited value — EX280 covers the concepts. If Toronto tech sector (Shopify, Wealthsimple, Clio) where upstream Kubernetes is common, CKA becomes the right cert. Evaluate at Ottawa landing.
- **Resources:** KodeKloud CKA course + killer.sh practice environment
- **Format:** Live cluster exam. Daily `kubectl` reps are the only prep that works.

---