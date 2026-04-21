# Archiving — tar, gzip, gunzip, common flags

**Block:** Block 2 — Linux CLI Foundations
**Topic:** Archiving — `tar`, `gzip`, `gunzip`, common flags
**Filename:** `b2-12-archiving.md`
**Path:** `block-02-linux-cli/daily-logs/b2-12-archiving.md`

---

## The Big Picture

Archiving is how you package and compress files for transfer, backup, or storage. Two separate operations that usually happen together: `tar` bundles multiple files and directories into a single file, and `gzip` compresses it. `tar` alone doesn't compress. `gzip` alone doesn't bundle. The `z` flag in `tar` runs both in one command — that's what you'll use in practice.

Three operations cold: create, inspect, extract.

```bash
tar -czf archive.tar.gz /path/    # create
tar -tzf archive.tar.gz           # inspect without extracting
tar -xzf archive.tar.gz -C /dest/ # extract to destination
```

Flags: `c` = create, `x` = extract, `t` = list, `z` = gzip compression, `f` = filename follows. `f` must come last — it takes the next argument as the filename.

### Quick Reference

| Command | What it does |
|---|---|
| `tar -czf archive.tar.gz /path/` | create compressed tarball |
| `tar -tzf archive.tar.gz` | inspect contents without extracting |
| `tar -xzf archive.tar.gz -C /dest/` | extract to specific directory |
| `tar -xzf archive.tar.gz -C /dest/ --strip-components=N` | extract and strip N path levels |
| `tar -rf archive.tar /path/file` | append file to uncompressed archive |
| `tar -cf archive.tar /path/` | bundle only, no compression |
| `gzip file` | compress single file — replaces original with `.gz` |
| `gunzip file.gz` | decompress — restores original, removes `.gz` |
| `file archive.tar.gz` | identify file type without relying on extension |

### Compression formats

| Format | Flag | Use case |
|---|---|---|
| gzip | `z` | Default — fast, universal support |
| bzip2 | `j` | Better ratio, slower — older software releases |
| xz | `J` | Best ratio, slowest — kernel releases, RPMs |
| zstd | `--zstd` | Modern, fast — increasingly common in backups |
| zip | — | Windows-compatible format |

---

## Learning by Doing

### Drill 1 — Create a tarball and inspect it

**What I ran:**

```bash
mkdir -p /tmp/archive-lab/configs
echo "server=prod" > /tmp/archive-lab/configs/app.conf
echo "port=8080" >> /tmp/archive-lab/configs/app.conf
echo "log level=info" > /tmp/archive-lab/configs/logging.conf
tar -czf /tmp/configs-backup.tar.gz /tmp/archive-lab/
tar -tzf /tmp/configs-backup.tar.gz
ls -lh /tmp/configs-backup.tar.gz
```

**Output:**

```
tar: Removing leading `/' from member names
tmp/archive-lab/
tmp/archive-lab/configs/
tmp/archive-lab/configs/app.conf
tmp/archive-lab/configs/logging.conf
-rw-r--r--. 1 student student 237 Apr 20 22:13 /tmp/configs-backup.tar.gz
```

**What I learned:** `t` lists archive contents without extracting — inspect before extracting to confirm the structure, check where files will land, and avoid overwriting something unintended. Critical on large archives from unknown sources. The leading slash warning is tar protecting against overwriting system files — paths inside the archive are stored as relative (`tmp/archive-lab/`) not absolute (`/tmp/archive-lab/`), so extraction can land anywhere safely.

---

### Drill 2 — Extract the tarball

**What I ran:**

```bash
mkdir /tmp/extracted
tar -xzf /tmp/configs-backup.tar.gz -C /tmp/extracted
ls -R /tmp/extracted
```

**Output:**

```
/tmp/extracted:
tmp

/tmp/extracted/tmp:
archive-lab

/tmp/extracted/tmp/archive-lab:
configs

/tmp/extracted/tmp/archive-lab/configs:
app.conf  logging.conf
```

**What I learned:** `-C` specifies the extraction target directory. Without `-C`, tar extracts into the current working directory — easy to dump files somewhere unintended. The archive recreates its full internal path structure inside the target. To avoid deep nesting: use `--strip-components=N` to strip N leading path levels, or archive from inside the source directory (`cd /path && tar -czf archive.tar.gz .`) so paths start with `./` instead of the full tree.

---

### Drill 3 — Work with gzip directly

**What I ran:**

```bash
cp /tmp/archive-lab/configs/app.conf /tmp/app.conf
gzip /tmp/app.conf
ls -lh /tmp/app.conf*
gunzip /tmp/app.conf.gz
ls -lh /tmp/app.conf*
```

**Output:**

```
-rw-r--r--. 1 student student 51 Apr 20 22:33 /tmp/app.conf.gz
-rw-r--r--. 1 student student 22 Apr 20 22:33 /tmp/app.conf
```

**What I learned:** `gzip` compresses a single file and replaces the original with a `.gz` file — the original is gone after compression. `gunzip` reverses it, restores the original, removes the `.gz`. This is the key difference from `tar -czf` — tar preserves the originals and creates a new archive file. `gzip` consumes the original. `gzip` works on single files only, not directories — that's tar's job.

---

### Drill 4 — Compare compressed vs uncompressed size

**What I ran:**

```bash
tar -cf /tmp/configs-backup.tar /tmp/archive-lab/
ls -lh /tmp/configs-backup.tar /tmp/configs-backup.tar.gz
file /tmp/configs-backup.tar
file /tmp/configs-backup.tar.gz
```

**Output:**

```
-rw-r--r--. 1 student student  10K Apr 20 22:41 /tmp/configs-backup.tar
-rw-r--r--. 1 student student 237  Apr 20 22:13 /tmp/configs-backup.tar.gz
/tmp/configs-backup.tar:    POSIX tar archive (GNU)
/tmp/configs-backup.tar.gz: gzip compressed data, from Unix, original size modulo 2^32 10240
```

**What I learned:** `file` identifies the actual file type from its contents — not the extension. Useful when a file has no extension or a misleading one. 10K uncompressed vs 237 bytes compressed on small text files — extreme ratio because text compresses well. Real-world logs and configs compress 70–80%. Skip compression (`tar -cf`) when content is already compressed — JPEGs, MP4s, existing `.gz` files — gzip on already-compressed data wastes CPU and can make files slightly larger.

---

### Drill 5 — Append to an existing archive

**What I ran:**

```bash
echo "debug=false" > /tmp/archive-lab/configs/debug.conf
tar -rf /tmp/configs-backup.tar /tmp/archive-lab/configs/debug.conf
tar -tf /tmp/configs-backup.tar
```

**Output:**

```
tmp/archive-lab/
tmp/archive-lab/configs/
tmp/archive-lab/configs/app.conf
tmp/archive-lab/configs/logging.conf
tmp/archive-lab/configs/debug.conf
```

**What I learned:** `-r` appends files to an existing uncompressed `.tar` archive without recreating it. Does not work on `.tar.gz` — gzip is a stream, appending would require decompressing the entire file, adding the content, and recompressing from scratch. To add a file to a `.tar.gz`: extract it, add the file, recreate the archive.

---

## Lab: Putting It Together

**Task:** Create a directory structure with logs and configs, populate with files, create a compressed tarball, inspect it, extract only configs without path nesting, verify, compare sizes, clean up.

**What I did:**

```bash
# create structure and populate
mkdir -p /tmp/lab-archive/{logs,configs}
echo "lab - file1.logs" >> /tmp/lab-archive/logs/file1
echo "lab - file2.logs" >> /tmp/lab-archive/logs/file2
echo "lab - file1.conf" >> /tmp/lab-archive/configs/file1.conf
echo "lab - file2.conf" >> /tmp/lab-archive/configs/file2.conf

# create compressed tarball
tar -czf /tmp/archive-full.tar.gz /tmp/lab-archive/

# inspect
tar -tzf /tmp/archive-full.tar.gz

# extract configs only, strip path nesting
mkdir /tmp/lab-restore
tar -xzf /tmp/archive-full.tar.gz -C /tmp/lab-restore/ --strip-components=3

# verify
ls -R /tmp/lab-restore/

# size comparison
du -sh /tmp/lab-archive
ls -lh /tmp/archive-full.tar.gz

# clean up
rm -rf /tmp/lab-archive /tmp/archive-full.tar.gz
```

**Output (key lines):**

```
tmp/lab-archive/
tmp/lab-archive/logs/
tmp/lab-archive/logs/file1
tmp/lab-archive/logs/file2
tmp/lab-archive/configs/
tmp/lab-archive/configs/file1.conf
tmp/lab-archive/configs/file2.conf

/tmp/lab-restore/:
file1  file1.conf  file2  file2.conf

16K     /tmp/lab-archive
291     /tmp/archive-full.tar.gz
```

**Outcome:** All tasks completed. Files landed flat in `/tmp/lab-restore/` with no path nesting.

**Errors hit:** None.

**Key distinction learned:** `--strip-components=3` stripped `tmp/` + `lab-archive/` + `configs/` — 3 levels — dropping files directly into the target. Count levels from `tar -t` output before running. Brace expansion `{logs,configs}` creates both directories in one `mkdir` command — reach for this pattern whenever creating multiple sibling directories.

Size comparison: 16K uncompressed vs 291 bytes compressed — 98% reduction on small text files. Real-world ratio on logs and configs is 70–80%. Still significant on large backup sets.

---

## What Stuck With Me

- **`tar` bundles, `gzip` compresses — separate tools.** The `z` flag combines them. Know what each does independently.
- **Always inspect before extracting.** `tar -t` shows structure and path depth before anything lands on disk.
- **`-C` always.** Extract to an explicit target, never rely on current directory.
- **`--strip-components=N` removes path nesting.** Count levels from `tar -t` output first.
- **`-r` append only works on uncompressed `.tar`.** Can't append to `.tar.gz` — gzip is a stream.
- **Skip compression on already-compressed content.** JPEGs, video, existing archives won't shrink further and waste CPU.

---

## Tips from Session

- Archive from inside the source directory to avoid path nesting problems: `cd /source && tar -czf /dest/archive.tar.gz .` — paths start with `./`, extraction lands clean.
- `file` command identifies actual file type from content, not extension — use it when you're handed an archive with no extension or a suspicious one.

---

> **Carry Forward:** `tar` with `rsync` for backup strategies — Block 4 Topic 15. Log archiving with `logrotate` uses compression under the hood — Block 4 Topic 10. `zstd` format becoming more common in modern backup tooling — worth revisiting when it appears in practice.