# Environment - env, export, PATH, .bashrc, .bash_profile

**Block:** Block 2 - Linux CLI Foundations
**Topic:** Environment - `env`, `export`, `PATH`, `.bashrc`, `.bash_profile`
**Filename:** `b2-14-environment.md`
**Path:** `block-02-linux-cli/daily-logs/b2-14-environment.md`

---

## The Big Picture

Every process runs inside an environment - a set of key-value pairs that tell it where to find things, how to behave, and who's running it. When you type a command, the shell doesn't search the entire filesystem - it checks the directories listed in `PATH`, in order, and runs the first match. Get `PATH` wrong and commands stop working.

Three scopes to understand:

- **Current shell:** variables set here exist here only. Close the terminal, they're gone.
- **Child shell:** spawned by the current shell. Inherits exported variables from the parent, runs, exits. Changes inside never come back up.
- **Persistent:** written to `.bashrc` or `.bash_profile`. The shell reads these files on startup and applies them every session.

`export` marks a variable to be passed into child process environments. Without it, the variable exists only in the current shell - child processes can't see it.

`.bash_profile` runs once on login shells (SSH, console). `.bashrc` runs every time a new interactive shell opens. Standard setup: `.bash_profile` sources `.bashrc` so both apply on login. Put everything in `.bashrc`.

### Quick Reference

| Concept | Detail |
|---|---|
| `env` | print all current environment variables |
| `printenv` | same as env, pipeable |
| `echo $VAR` | print a specific variable's value |
| `VAR="value"` | set variable in current shell only |
| `export VAR` | mark variable for child process inheritance |
| `export VAR="value"` | set and export in one step |
| `unset VAR` | remove a variable |
| `source ~/.bashrc` | reload file in current shell - changes take effect now |
| `. ~/.bashrc` | same as source - shorthand |
| `bash file` | runs file in a child shell - changes don't come back |
| `export PATH="$HOME/bin:$PATH"` | prepend to PATH - personal tools take priority |
| `export PATH="$PATH:$HOME/bin"` | append to PATH - system binaries take priority |
| `~/.bashrc` | runs every interactive shell - put aliases and exports here |
| `~/.bash_profile` | runs on login shell - sources `.bashrc` in standard setup |

---

## Learning by Doing

### Drill 1 - Inspect the current environment

**What I ran:**

```bash
env | head -20
echo $PATH
echo $HOME
echo $USER
```

**Output:**

```
SHELL=/bin/bash
HOSTNAME=rocky-vm
PWD=/home/student
HOME=/home/student
USER=student
...
/home/student/.local/bin:/home/student/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
/home/student
student
```

**What I learned:** `PATH` is a colon-separated list of directories the shell searches in order when a command is typed. Six directories on this system - the shell checks each left to right and runs the first match. Setting `PATH=""` makes every command by name fail - `ls`, `grep`, nothing works without typing the full path like `/usr/bin/ls`. Fix in the same session: `export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin`.

---

### Drill 2 - Set and export variables

**What I ran:**

```bash
MYVAR="hello"
echo $MYVAR
bash -c 'echo "child sees: $MYVAR"'
export MYVAR
bash -c 'echo "child sees: $MYVAR"'
```

**Output:**

```
hello
child sees:
child sees: hello
```

**What I learned:** Without `export`, a variable exists only in the current shell. When the shell forks a child, unexported variables are not copied into the child's environment. `export` marks the variable for inclusion in child process environments - child processes inherit it. `export $MYVAR` is a common mistake - it expands to the value (`export hello`) and exports a variable named `hello`, not `MYVAR`. Always `export MYVAR` - the name, not the value.

---

### Drill 3 - Modify PATH and make it permanent

**What I ran:**

```bash
echo $PATH
export PATH=$PATH:/tmp/testbin
echo $PATH
mkdir -p /tmp/testbin
echo '#!/bin/bash
echo "custom tool works"' > /tmp/testbin/mytool
chmod +x /tmp/testbin/mytool
mytool
```

**Output:**

```
/home/student/.local/bin:/home/student/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
/home/student/.local/bin:/home/student/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/tmp/testbin
custom tool works
```

**What I learned:** `PATH=$PATH:/tmp/testbin` appends the new directory to the existing PATH - the shell now searches `/tmp/testbin` as the last option. `export` pushes it into the environment so child processes inherit the updated PATH. This change dies when the terminal closes - `export` persists to child processes, not across sessions. To make it permanent, write to `.bashrc`: `echo 'export PATH="$PATH:/tmp/testbin"' >> ~/.bashrc`. Use `$HOME/bin` over `~/bin` in scripts - tilde expansion is not guaranteed outside interactive shells.

---

### Drill 4 - Edit .bashrc and source it

**What I ran:**

```bash
echo 'export MYAPP_ENV="production"' >> ~/.bashrc
echo 'alias ll="ls -lh"' >> ~/.bashrc
source ~/.bashrc
echo $MYAPP_ENV
ll /tmp | head -5
```

**Output:**

```
production
total 72
-rw-r--r--. 1 student student 22 Apr 20 22:33 app.conf
...
```

**What I learned:** `source ~/.bashrc` executes the file in the current shell - variables and aliases defined in it become available immediately. `bash ~/.bashrc` runs it in a child shell - changes exist in that child, the child exits, the current shell sees nothing. `source` (or `. file`) is the correct way to apply config file changes without opening a new terminal.

---

### Drill 5 - Login vs non-login shells

**What I ran:**

```bash
cat ~/.bash_profile
cat ~/.bashrc | tail -10
```

**Output:**

```
# .bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

export MYAPP_ENV="production"
export LAB_SETUP="complete"
```

**What I learned:** Login shell (SSH login, console) reads `.bash_profile`. Non-login interactive shell (opening a new terminal) reads `.bashrc`. The standard Rocky/RHEL `.bash_profile` sources `.bashrc` with `. ~/.bashrc` - so login shells get everything in both files. Put all customization in `.bashrc`, let `.bash_profile` source it. That covers both cases without duplicating anything.

---

## Lab: Putting It Together

**Task:** Count env variables. Create unexported variable and confirm child can't see it. Export and confirm child can. Add permanent PATH, alias, and variable to `.bashrc`. Source and verify. Confirm with child shell. Show last 15 lines of `.bashrc`.

**What I did:**

```bash
# count env variables
printenv | wc -l

# unexported variable
LAB_ENV="testing"
bash -c 'echo "$LAB_ENV"'   # blank

# export and verify
export LAB_ENV
bash -c 'echo "$LAB_ENV"'   # testing

# permanent PATH - prepend $HOME/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# permanent alias
# added alias lsl='ls -lah' to .bashrc via nano

# permanent variable
echo 'export LAB_SETUP="complete"' >> ~/.bashrc

# source and verify
source ~/.bashrc
echo $LAB_SETUP             # complete
lsl /tmp | head -5

# child shell confirmation
bash -c 'echo "$LAB_SETUP"' # complete

# confirm .bashrc additions
tail -15 ~/.bashrc
```

**Output (key lines):**

```
32

(blank)
testing

total 92K
drwxrwxrwt. 35 root    root    4.0K Apr 21 18:32 .
...

complete

export MYAPP_ENV="production"
export LAB_SETUP="complete"
```

**Outcome:** All tasks completed.

**Errors hit:** Ran `echo LAB_SETUP` without `$` - printed the literal string `LAB_SETUP` instead of the variable value. Fixed with `echo $LAB_SETUP`.

**How I resolved it:** Added `$` prefix to expand the variable.

**Key distinction learned:** `source` runs a file in the current shell - changes take effect immediately. `bash file` runs in a child shell - changes are lost when the child exits. Always `source` when applying config file changes to the current session.

Prepend vs append to PATH: `$HOME/bin:$PATH` puts personal tools first - they win on name conflicts with system binaries. `$PATH:$HOME/bin` appends - system binaries win. Pick based on intent. `$HOME/bin` is safer than `~/bin` in scripts where tilde expansion may not occur.

---

## What Stuck With Me

- **Current shell, child shell, persistent - three scopes.** Export reaches child shells. `.bashrc` reaches all future sessions.
- **`export VAR` not `export $VAR`.** `$VAR` expands to the value - you'd be exporting the wrong name entirely.
- **`source` vs `bash file`.** Source runs in current shell. `bash file` runs in child and throws away results.
- **`.bash_profile` sources `.bashrc`.** Put everything in `.bashrc`. One file, works everywhere.
- **PATH change without `.bashrc` entry dies on terminal close.** Always write permanent changes to `.bashrc`.
- **`$HOME/bin` over `~/bin` in scripts.** Tilde expansion is interactive-shell behaviour - `$HOME` is always reliable.

---

## Tips from Session

- Always verify a variable change with `echo $VAR` immediately after setting it - catch mistakes before they compound.
- Before editing `.bashrc`, check `tail -20 ~/.bashrc` first - know what's already there before appending. Duplicate exports and aliases create noise.

---

> **Carry Forward:** `.bashrc` customization for prompt and tool config revisited throughout Block 3 and Block 4. `PATH` management for custom scripts in Block 3 - scripts committed to `~/bin` need it in PATH to run by name. `export` used directly in Block 3 scripts for passing variables to subprocesses.

