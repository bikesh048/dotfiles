
# Day 1: Linux File Permissions Basics

## Goal
Understand how Linux decides WHO can do WHAT to a file.

## Concept: Everything is a File

In Linux, everything — documents, directories, devices — is a file. Every file has:
1. An **owner** (one user)
2. A **group** (one group)
3. **Permissions** (what owner, group, and others can do)

## The Permission String

When you run `ls -la`, you see:

```
-rw-r--r--  1  deployer  www-data  1024  Feb 9  app.php
│├──┤├──┤├──┤     │         │
│  │   │   │      │         └── group
│  │   │   │      └──────────── owner
│  │   │   └─────────────────── others (everyone else)
│  │   └─────────────────────── group permissions
│  └─────────────────────────── owner permissions
└────────────────────────────── file type (- = file, d = directory)
```

## The Three Permission Types

| Symbol | Meaning for FILES        | Meaning for DIRECTORIES        |
|--------|--------------------------|--------------------------------|
| `r`    | Read file contents       | List directory contents (ls)   |
| `w`    | Modify file contents     | Create/delete files inside     |
| `x`    | Execute as program       | Enter directory (cd)           |

## Numeric (Octal) Notation

Each permission is a number:
```
r = 4
w = 2
x = 1
```

Add them together for each category:

```
rwx = 4+2+1 = 7  (full access)
rw- = 4+2+0 = 6  (read + write)
r-x = 4+0+1 = 5  (read + execute)
r-- = 4+0+0 = 4  (read only)
--- = 0+0+0 = 0  (no access)
```

So `644` means:
```
6 = rw-  (owner can read+write)
4 = r--  (group can read only)
4 = r--  (others can read only)
```

And `775` means:
```
7 = rwx  (owner can do everything)
7 = rwx  (group can do everything)
5 = r-x  (others can read+execute)
```

## How Linux Checks Permissions

When a user tries to access a file, Linux checks in this ORDER:

```
1. Is the user the OWNER?     → use owner permissions (first 3 bits)
2. Is the user in the GROUP?  → use group permissions (middle 3 bits)
3. Otherwise                  → use other permissions (last 3 bits)
```

**Important:** Linux stops at the FIRST match. If you are the owner, group permissions don't apply to you even if the group has more access.

### Example:

```
-rw-r--rw-  deployer  www-data  config.php
```

- `deployer` → is owner → gets `rw-` (read+write)
- `www-data` → is in group → gets `r--` (read only)
- `bikesh` → is neither → gets `rw-` (read+write!)

Notice: in this weird example, "others" have MORE access than the group!

---

## Practice Exercises

**Setup: Create a practice area**
```bash
# Create a temporary practice directory
mkdir -p /tmp/permissions-lab/day1
cd /tmp/permissions-lab/day1
```

### Exercise 1: Reading Permission Strings
Create files and read their permissions:
```bash
touch file1.txt
ls -la file1.txt
# Q: What are the permissions? Who is the owner? What group?
```

### Exercise 2: Changing Permissions with chmod (Numeric)
```bash
# Create a file
echo "hello" > secret.txt

# Make it readable only by owner
chmod 600 secret.txt
ls -la secret.txt
# Expected: -rw-------

# Make it readable by everyone
chmod 644 secret.txt
ls -la secret.txt
# Expected: -rw-r--r--

# Make it fully open
chmod 777 secret.txt
ls -la secret.txt
# Expected: -rwxrwxrwx
```

### Exercise 3: Changing Permissions with chmod (Symbolic)
```bash
touch demo.txt

# Add write permission for group
chmod g+w demo.txt
ls -la demo.txt

# Remove read permission for others
chmod o-r demo.txt
ls -la demo.txt

# Add execute for owner
chmod u+x demo.txt
ls -la demo.txt

# Set exact permissions: owner=rw, group=r, others=nothing
chmod u=rw,g=r,o= demo.txt
ls -la demo.txt
# Expected: -rw-r-----
```

### Exercise 4: Directory Permissions
```bash
mkdir testdir
echo "inside file" > testdir/inside.txt

# Remove execute from directory
chmod 664 testdir

# Try to enter it
cd testdir
# Q: What happens? Why?

# Fix it
chmod 775 testdir
cd testdir
# Q: Now what happens?
```

### Exercise 5: Permission Check Order
```bash
# This exercise requires root. If you can't use root, just read and understand.
sudo bash -c '
  echo "test content" > /tmp/permissions-lab/day1/order-test.txt
  chown deployer:www-data /tmp/permissions-lab/day1/order-test.txt
  chmod 064 /tmp/permissions-lab/day1/order-test.txt
'
ls -la /tmp/permissions-lab/day1/order-test.txt
# Shows: ----rw-r-- deployer www-data
# Q: Can deployer read this file? (Answer: NO! Owner permissions are ---)
# Q: Can a www-data process read it? (Answer: YES! Group permissions are rw-)
# This proves Linux checks owner FIRST, even if group has more access.
```

---

## Key Takeaways

1. Every file has owner, group, and permissions
2. `r=4, w=2, x=1` — add them up for each category
3. For directories, `x` means "can enter", `w` means "can create/delete files inside"
4. Linux checks: owner first, then group, then others — stops at first match
5. `chmod` changes permissions, using numeric (644) or symbolic (g+w) notation

---

## Quick Reference

```
chmod 644 file   →  rw-r--r--   (typical file)
chmod 755 file   →  rwxr-xr-x   (typical script/directory)
chmod 664 file   →  rw-rw-r--   (group-writable file)
chmod 775 dir    →  rwxrwxr-x   (group-writable directory)
chmod 600 file   →  rw-------   (private file)
chmod 700 dir    →  rwx------   (private directory)
```
