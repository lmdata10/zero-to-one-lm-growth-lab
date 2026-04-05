# Git Mental Model

**Block:** Block 1 — Git & GitHub  
**Topic:** What Git actually is — the mental model, core loop  
**Filename:** `b1-01-git-mental-model.md`  
**Path:** `block-01-git-github/logs/b1-01-git-mental-model.md`

---

## The Big Picture

Git isn't tracking changes to your files—it's taking snapshots of your entire project at specific moments in time. Every snapshot (called a commit) gets a **unique hash**, like a fingerprint. Think of it like saving a photo of your project's state rather than tracking what changed between versions.

The flow is always the same: you work on files → you tell Git which changes to include → you save a snapshot. Nothing moves without you explicitly telling Git to move it.

### The Three Zones (Your Mental Map)

- **Working directory** — where you actually work on files
- **Staging area** — where you line up changes for your next snapshot
- **Repository** (inside `.git`) — where all your snapshots are permanently stored

---

## Drills

### Drill 1 — Init a repo and inspect .git

**What I ran:**
```bash
mkdir git-lab && cd git-lab
git init
ls -la .git/
```

**Output:**
```
drwxr-xr-x@ - student 30 Mar 17:17 hooks
drwxr-xr-x@ - student 30 Mar 17:17 info
drwxr-xr-x@ - student 30 Mar 17:17 objects
drwxr-xr-x@ - student 30 Mar 17:17 refs
.rw-r--r--@ 137 student 30 Mar 17:17 config
.rw-r--r--@  73 student 30 Mar 17:17 description
.rw-r--r--@  23 student 30 Mar 17:17 HEAD
```

**What I learned:** The `.git` folder is Git's entire brain for your project. Every snapshot, every reference, every setting lives in here. Delete this folder and Git forgets the repo ever existed. It's that important.

---

### Drill 2 — Configure Git identity, create file, check status

**What I ran:**
```bash
git config --global user.name "Your Name"
git config --global user.email "you@email.com"
touch readme.txt
git status
```

**Output:**
```
On branch master
No commits yet
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	readme.txt
nothing added to commit but untracked files present
```

**What I learned:** When Git says a file is "untracked," it means Git sees the file exists, but you haven't told it to care yet. The file is sitting in your working directory, completely ignored by Git's snapshot system.

---

### Drill 3 — Stage the file

**What I ran:**
```bash
git add readme.txt
git status
```

**Output:**
```
On branch master
No commits yet
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file: readme.txt
```

**What I learned:** `git add` moves the file from your working directory into the staging area. The message "Changes to be committed" is Git's way of saying, "I see these changes and they're queued for the next snapshot." But it's not saved yet—it's just waiting.

---

### Drill 4 — First commit and log

**What I ran:**
```bash
echo "my first repo" >> readme.txt
git commit -m "init: add readme"
git log
```

**Output:**
```
commit 5ed3f7a70961d56c730f2331cad6e145627e6c5d (HEAD -> master)
Author: LM-10 <lm-10@email.com>
Date:   Mon Mar 30 17:33:45 2026 -0300
    init: add readme
```

**What I learned:** That long string (`5ed3f7a...`) is your commit's unique hash—a fingerprint of that exact snapshot. `HEAD -> master` tells you where you are right now in the project's history. `HEAD` is just a pointer that always points to your current location.

---

### Drill 5 — Second commit, watch the chain

**What I ran:**
```bash
echo "learning git" >> readme.txt
git add readme.txt
git commit -m "docs: update readme with learning note"
git log
```

**Output:**
```
commit ca921d8483aaffc624268a13a4028fe19559466b (HEAD -> master)
Author: LM-10 <lm-10@email.com>
Date:   Mon Mar 30 17:36:46 2026 -0300
    docs: update readme with learning note

commit 5ed3f7a70961d56c730f2331cad6e145627e6c5d
Author: LM-10 <lm-10@email.com>
Date:   Mon Mar 30 17:33:45 2026 -0300
    init: add readme
```

**What I learned:** Each commit points back to the one before it—that's the chain. Every snapshot knows its parent. `HEAD` automatically moved forward to the newest commit. `git log` shows history newest first, so you see where you are before where you've been.

---

## Putting It Together: The Lab

**Task:** Create `ops-lab` directory, init as Git repo, create three files, stage only `notes.txt` and `commands.txt`, leave `scratch.txt` untracked, commit with a conventional message, verify with `git status` and `git log`.

**What I did:**

```bash
# Create a new directory called ops-lab
mkdir ops-lab && cd ops-lab

# Initialize it as a Git repo 
git init

# Create three files: notes.txt, commands.txt, scratch.txt
touch notes.txt commands.txt scratch.txt

# Stage only notes.txt and commands.txt (leave scratch.txt untracked)
git add notes.txt commands.txt

# Commit with a meaningful message following the convention from the curriculum 
git commit -m "lab: tracking lab files"

# Verify the commit landed and scratch.txt is still untracked
git status
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
# 	scratch.txt
# nothing added to commit but untracked files present

git log
# commit 8477061a7e8849c863957e07c87df5b114405bad (HEAD -> master)
# Author: LM-10 <lm-10@email.com> 
# Date: Mon Mar 30 17:55:20 2026 -0300 
# 	lab: tracking lab files
```

**Outcome:** The commit landed successfully. `scratch.txt` stayed untracked—exactly as intended.

**The mistake I made:** Typed `notext.txt` instead of `notes.txt` in the `git add` command. Git didn't yell at me about it, which is the tricky part—it just added a file that didn't exist in my mental model.

**How I fixed it:** I checked `git status` before committing and caught the mistake. Re-ran `git add` with the correct filename. This is why checking status is non-negotiable.

---

## What Stuck With Me

- **Git is a camera, not a track-changes tool.** It takes snapshots. You control when.
- **Three zones = three states.** Know which one your files are in at all times.
- **Hashes are permanent.** Once you commit, that snapshot is locked in forever with its unique ID.
- **HEAD is your position marker.** It moves forward with each commit, always pointing to where you are.
- **Selective staging matters.** Not everything should go in every commit. `scratch.txt` staying untracked shows you have control over what gets saved.

---

## Tips from Session

- **Run `git status` constantly.** Before you add, after you add, after you commit. It's your GPS. It tells you exactly where you are.
- **Git won't always catch your typos.** If you mistype a filename in `git add`, Git will just add whatever you typed (or nothing). Always verify with `git status` before committing.

---

## Carry Forward

- **master vs main** — I keep seeing both names. Need to understand when and why Git switched the default.