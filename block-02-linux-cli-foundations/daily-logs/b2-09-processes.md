# Processes — ps, top, htop, kill, pkill, jobs, bg, fg, &

**Block:** Block 2 — Linux CLI Foundations 
**Topic:** Processes — `ps`, `top`, `htop`, `kill`, `pkill`, `jobs`, `bg`, `fg`, `&` 
**Filename:** `b2-09-processes.md` 
**Path:** `block-02-linux-cli/daily-logs/b2-09-processes.md`

---

## The Big Picture

Every program running on the system is a process with a PID. The kernel tracks every process — who owns it, how much CPU and memory it's using, and what spawned it. Every process has a parent. The shell forks a child to run each command. `systemd` is PID 1 — the root of the entire tree, PPID 0, no parent. Everything else traces back to it.

Two views: `ps aux` is a static snapshot — use it to find something specific. `top` and `htop` are live — use them when diagnosing a slow system or a runaway process. Signals are how you talk to processes. Default `kill` sends SIGTERM (15) — polite shutdown request. SIGKILL (9) is force termination, last resort only.

### Quick Reference

|Concept|Detail|
|---|---|
|`ps aux`|full process snapshot — all users, all processes|
|`ps -p PID -o pid,ppid,user,stat,cmd`|inspect a specific process with chosen fields|
|`pgrep name`|returns PID by process name — cleaner than `ps aux \| grep`|
|`top` / `htop`|live view — htop is visual, top is always available|
|Load average|1/5/15 min CPU queue — compare against core count|
|`kill PID`|sends SIGTERM (15) — graceful shutdown request|
|`kill -9 PID`|sends SIGKILL — force terminate, no cleanup|
|`pkill name`|kill by name pattern — no PID lookup needed|
|`pkill -f "pattern"`|match full command string — use for specific args|
|`&`|run process in background, keep terminal free|
|`jobs`|list background and suspended jobs in current shell|
|`fg %N`|bring job N to foreground|
|`bg %N`|resume suspended job N in background|
|`Ctrl+Z`|suspend foreground process — sends SIGSTOP|
|`Ctrl+C`|interrupt foreground process — sends SIGINT|

### Common Signals

|Signal|Number|Meaning|
|---|---|---|
|SIGTERM|15|Graceful shutdown — default `kill`|
|SIGKILL|9|Force terminate — no cleanup, can't be caught|
|SIGHUP|1|Reload config — used on daemons without restart|
|SIGINT|2|Keyboard interrupt — what `Ctrl+C` sends|
|SIGSTOP|19|Suspend process — what `Ctrl+Z` sends|
|SIGCONT|18|Resume a stopped process — what `bg` sends|
|SIGCHLD|17|Sent to parent when child exits — clears zombies|

---

## Learning by Doing

### Drill 1 — Snapshot the process list

**What I ran:**

```bash
ps aux | head -20
ps aux | wc -l
```

**Output:**

```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  1.6  50340 41440 ?        Ss   03:12   0:03 /usr/lib/systemd/systemd
root           2  0.0  0.0      0     0 ?        S    03:12   0:00 [kthreadd]
...
277
```

**What I learned:** `ps` alone shows only processes in the current terminal. `ps aux` shows everything — all users, all processes, no terminal required. Column breakdown: `VSZ` is total virtual memory mapped (includes parts not in RAM yet), `RSS` is actual physical RAM in use right now — RSS is what matters for memory pressure. `TTY` of `?` means no terminal attached — background daemon. `STAT` shows process state: `S`=sleeping, `R`=running, `I`=idle kernel thread, `Z`=zombie, `s`=session leader. `TIME` is total CPU cycles consumed, not wall clock time. Kernel threads show in brackets like `[kthreadd]`.

---

### Drill 2 — Find a specific process and read its state

**What I ran:**

```bash
ps aux | grep sshd
ps -p 1 -o pid,ppid,user,stat,cmd
```

**Output:**

```
root  1298  0.0  0.2  8108  5984 ?  Ss  03:12  0:00 sshd: /usr/sbin/sshd -D [listener]
root  3334  0.0  0.3 17780  9608 ?  Ss  03:13  0:00 sshd-session: student [priv]
student  3338  0.0  0.3 17920  7588 ?  S  03:13  0:08 sshd-session: student@pts/0
student  5534  0.0  0.0 227496 1996 pts/0  S+  10:36  0:00 grep --color=auto sshd

PID  PPID USER  STAT CMD
  1     0 root  Ss   /usr/lib/systemd/systemd
```

**What I learned:** `PPID` is the parent process ID. PID 1 has PPID 0 — no parent, root of the entire process tree. sshd runs as three separate processes: the main listener daemon, a privileged session handler, and the actual user session. One service, multiple processes — parent spawning children to handle work. The `grep` command itself appears in its own output — filter it with `grep -v grep` or use `pgrep` instead.

---

### Drill 3 — Live process view

**What I ran:**

```bash
top   # quit with q
htop  # quit with q — installed via epel-release
```

**What I learned:** Load average shows CPU queue depth over 1, 5, and 15 minutes. Compare against core count — on a 2-core VM, load of `2.0` is fully loaded, above that means queuing. `top` sorts by CPU by default so the worst offender is already at the top. When diagnosing a slow system: load average first to confirm it's CPU, then `%CPU` column, then `%MEM`if CPU looks clean. `htop` is the same data with color-coded per-core bars and memory visualization — faster to read. `top` is always available on minimal installs and containers. Know both.

---

### Drill 4 — Find and kill a process

**What I ran:**

```bash
sleep 300 &
ps aux | grep sleep
kill $(pgrep sleep)
ps aux | grep sleep
```

**Output:**

```
[1] 6136
student  6136  0.0  0.0 226640 1752 pts/0  S  15:49  0:00 sleep 300
student  6138  0.0  0.0 227496 1996 pts/0  S+  15:49  0:00 grep --color=auto sleep
[1]+  Terminated  sleep 300
student  6141  0.0  0.0 227496 1984 pts/0  S+  15:49  0:00 grep --color=auto sleep
```

**What I learned:** `&` runs the process in the background and returns the terminal immediately. Shell prints `[job_number] PID`to confirm. `pgrep` returns only the PID — no grep filtering its own output, no column parsing. `$()` captures the output and passes it directly to `kill`. Default `kill` sends SIGTERM (15) — a polite shutdown request, not force kill. The process can catch it and exit cleanly. `Terminated` in output confirms clean SIGTERM exit. `Killed` would indicate SIGKILL. Always try SIGTERM first — only reach for `kill -9` if the process doesn't respond.

---

### Drill 5 — Jobs, background, and foreground

**What I ran:**

```bash
sleep 200 &
sleep 201 &
jobs
fg %1
# Ctrl+Z to suspend
jobs
bg %1
jobs
```

**Output:**

```
[1] 6200
[2] 6201
[1]-  Running   sleep 200 &
[2]+  Running   sleep 201 &
sleep 200
^Z
[1]+  Stopped   sleep 200
[1]+  Stopped   sleep 200
[2]-  Running   sleep 201 &
[1]+ sleep 200 &
[1]-  Running   sleep 200 &
[2]+  Running   sleep 201 &
```

**What I learned:** `Ctrl+Z` sends SIGSTOP — freezes the process in memory, hands control back to the shell. Not terminated, not running — suspended. PID still exists. `bg` sends SIGCONT — resumes it in the background. `Ctrl+Z` + `bg` is how you move a foreground process to the background after the fact, when you forgot to add `&` before running it. Kill ends the process permanently. Suspend freezes it — resumable with `fg` or `bg`.

---

## Lab: Putting It Together

**Task:** Start three background sleep processes (500, 501, 502). List them with jobs and verify PIDs with ps. Kill sleep 501 specifically. Confirm it's gone. Bring sleep 500 to foreground, suspend it, resume in background. Kill all remaining sleep processes. Confirm nothing remains.

**What I did:**

```bash
# Start three background sleep processes: sleep 500, sleep 501, sleep 502
sleep 500 &
sleep 501 &
sleep 502 &

# [3] 6249
# [4] 6250
# [5] 6251

# Use jobs to list them
jobs
# [3]   Running                 sleep 500 &
# [4]-  Running                 sleep 501 &
# [5]+  Running                 sleep 502 &

# Use ps aux | grep sleep to verify all three PIDs
ps aux | grep sleep
# student     6249  0.0  0.0 226640  1772 pts/0    S    16:53   0:00 sleep 500
# student     6250  0.0  0.0 226640  1768 pts/0    S    16:53   0:00 sleep 501
# student     6251  0.0  0.0 226640  1768 pts/0    S    16:53   0:00 sleep 502
# student     6253  0.0  0.0 227496  1996 pts/0    S+   16:54   0:00 grep --color=auto sleep


# Kill sleep 501 by name using pkill
kill 6250 # pkill looks for patterns to specifically kill sleep 501 use kill <PID>


# Confirm it's gone with jobs and ps aux | grep sleep
jobs
# [3]   Running                 sleep 500 &
# [4]-  Terminated              sleep 501
# [5]+  Running                 sleep 502 &

ps aux | grep sleep
# student     6249  0.0  0.0 226640  1772 pts/0    S    16:53   0:00 sleep 500
# student     6251  0.0  0.0 226640  1768 pts/0    S    16:53   0:00 sleep 502
# student     6259  0.0  0.0 227496  1996 pts/0    S+   16:56   0:00 grep --color=auto sleep

# Bring sleep 500 to foreground with fg, suspend it with Ctrl+Z, then resume it in background with bg
fg 3
# sleep 500
# ^Z
# [3]+  Stopped                 sleep 500

bg 3
# [3]+ sleep 500 &

jobs
# [3]-  Running                 sleep 500 &
# [5]+  Running                 sleep 502 &

# Kill all remaining sleep processes using pkill
pkill sleep
# [3]-  Terminated              sleep 500
# [5]+  Terminated              sleep 502

# Confirm nothing remains
jobs
# No Output
```

**Outcome:** All tasks completed. Both remaining processes terminated cleanly.

**Errors hit:** None.

**Key distinction learned:** The task asked for `pkill` to kill sleep 501 specifically — used `kill PID` instead, which works but misses the point. To target a specific argument with pkill, use `pkill -f "sleep 501"`. The `-f` flag matches against the full command string including arguments. Without `-f`, `pkill sleep` kills every sleep process at once. `pkill` is the right tool when you want to kill a named service across multiple PIDs without looking up each one — `pkill nginx`, `pkill gunicorn`. `kill PID` when you need surgical precision on one specific process.

---

## What Stuck With Me

- **PID 1 is systemd, PPID 0 — no parent.** Everything traces back to it. Kill a parent and you can take its children with it.
- **`ps aux` is a snapshot, `top`/`htop` is live.** Use ps to find, use top/htop to diagnose.
- **Default `kill` is SIGTERM, not force kill.** Polite request. Process can catch and clean up. `kill -9` is last resort.
- **`Ctrl+Z` suspends, `Ctrl+C` kills.** Suspend freezes in memory — resumable. `bg` after suspend moves it to background without losing it.
- **`pkill -f` for full command match.** `pkill sleep` hits all sleep processes. `pkill -f "sleep 501"` hits only that one.
- **RSS is the memory number that matters.** VSZ is virtual mapped memory — often inflated. RSS is actual physical RAM in use.

---

## Tips from Session

- Always try `kill PID` before `kill -9`. If SIGTERM doesn't work within a few seconds, then force it. Skipping straight to -9 prevents clean shutdown and can leave locks, temp files, or corrupted state behind.
- Use `pgrep` over `ps aux | grep` in scripts — returns only the PID, no filtering needed, won't match its own grep process.

---

> **Carry Forward:** `SIGHUP` for live config reload revisited in Block 4 Topic 1 — systemd and service management. Zombie processes and SIGCHLD covered when parent-child process relationships come up in Block 3 scripting. `kill`/`pkill` used directly in the Block 3 system health check script.