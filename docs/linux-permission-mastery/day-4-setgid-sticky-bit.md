
# Day 4: Special Bits — setgid, setuid, and Sticky Bit

## Goal
Understand the three special permission bits that solve group inheritance and security problems.

## The Problem setgid Solves

Remember from Day 2: new files get the creator's PRIMARY group.

```bash
id deployer
# uid=1001(deployer) gid=1001(deployer) groups=1001(deployer),33(www-data)
#                     ↑ primary group

sudo -u deployer touch /var/www/app/newfile.txt
ls -la /var/www/app/newfile.txt
# -rw-rw-r--  deployer  deployer   ← group is "deployer", NOT "www-data"!
```

www-data can't access it because the group is `deployer`, not `www-data`.

**We need new files to automatically get group `www-data`.** That's what setgid does.

## The Three Special Bits

| Bit | Octal | On Files | On Directories |
|-----|-------|----------|----------------|
| setuid | 4 | Run as file owner (dangerous!) | No effect |
| setgid | 2 | Run as file group | **New files inherit directory's group** |
| sticky | 1 | No effect | Only file owner can delete files |

The special bit is a 4th digit BEFORE the normal 3:

```
chmod 2775 directory
      │
      └── 2 = setgid
```

## setgid on Directories (The One We Use)

When setgid is set on a directory, every new file/subdirectory created inside **inherits the directory's group** instead of the creator's primary group.

### Without setgid:
```
drwxrwxr-x  deployer:www-data  /var/www/app/storage/

deployer creates file inside:
-rw-rw-r--  deployer:deployer  newfile.txt    ← group is "deployer" (BAD!)
```

### With setgid:
```
drwxrwsr-x  deployer:www-data  /var/www/app/storage/
       ↑
       s = setgid (replaces x in group)

deployer creates file inside:
-rw-rw-r--  deployer:www-data  newfile.txt    ← group is "www-data" (GOOD!)
```

### How to spot it:
```
drwxrwsr-x   ← lowercase 's' means setgid + execute
drwxrwSr-x   ← uppercase 'S' means setgid but NO execute (unusual)
```

### Setting setgid:
```bash
# Numeric: add 2 before the normal permissions
chmod 2775 /var/www/app/storage

# Symbolic:
chmod g+s /var/www/app/storage

# Verify:
ls -la -d /var/www/app/storage
# drwxrwsr-x  deployer  www-data  storage/
```

### New subdirectories also inherit setgid:
```
/var/www/app/storage/           (2775, setgid, group=www-data)
  └── logs/                     (2775, setgid, group=www-data)  ← inherited!
      └── laravel.log           (664, group=www-data)           ← inherited!
```

This is why `2775` is so important — the setgid cascades down to ALL new content.

## setuid on Files (Know It, Avoid It)

setuid makes a file run as its OWNER, not as the user who runs it.

```bash
ls -la /usr/bin/passwd
# -rwsr-xr-x  root  root  passwd
#    ↑
#    s = setuid

# When bikesh runs passwd, it executes as ROOT
# That's how normal users can change their own password
# (because /etc/shadow is owned by root)
```

**Never set setuid on your own scripts** — it's a security risk. Just know what it means when you see it.

## Sticky Bit on Directories

The sticky bit on a directory means: only the file OWNER (or root) can delete files inside, even if others have write permission on the directory.

```bash
ls -la -d /tmp
# drwxrwxrwt  root  root  /tmp
#          ↑
#          t = sticky bit

# Everyone can create files in /tmp
# But bikesh can't delete deployer's files, even though /tmp is world-writable
```

Setting sticky bit:
```bash
chmod 1777 /tmp      # 1 = sticky bit
chmod +t /tmp        # symbolic
```

## Our Tripcart Setup: 2775

```
Mode: 2775
  2 = setgid       → new files inherit www-data group
  7 = rwx (owner)  → deployer has full access
  7 = rwx (group)  → www-data has full access
  5 = r-x (others) → everyone else can read

Result: drwxrwsr-x  deployer:www-data

When deployer creates a file inside:
  File:      -rw-rw-r--  deployer:www-data  (umask 002 + setgid)
  Directory: drwxrwsr-x  deployer:www-data  (setgid inherited!)
```

The combination of **umask 002 + setgid 2775** means:
- deployer creates files → group is www-data (setgid) with write permission (umask 002)
- www-data can read+write everything

---

## Practice Exercises

**Setup:**
```bash
mkdir -p /tmp/permissions-lab/day4
cd /tmp/permissions-lab/day4
```

### Exercise 1: See setgid in Action
```bash
# Create two directories
mkdir normal-dir setgid-dir

# Set setgid on one
chmod 2775 setgid-dir

# Compare
ls -la -d normal-dir setgid-dir
# drwxrwxr-x  ... normal-dir      ← no 's'
# drwxrwsr-x  ... setgid-dir      ← has 's'!
```

### Exercise 2: Group Inheritance
```bash
# This needs sudo. If you can't use sudo, just read and understand.

# Setup: create dirs with different groups
sudo bash -c '
  mkdir -p /tmp/permissions-lab/day4/no-setgid
  mkdir -p /tmp/permissions-lab/day4/with-setgid

  chown deployer:www-data /tmp/permissions-lab/day4/no-setgid
  chown deployer:www-data /tmp/permissions-lab/day4/with-setgid

  chmod 775 /tmp/permissions-lab/day4/no-setgid
  chmod 2775 /tmp/permissions-lab/day4/with-setgid
'

# Create files as deployer in each
sudo -u deployer touch /tmp/permissions-lab/day4/no-setgid/test.txt
sudo -u deployer touch /tmp/permissions-lab/day4/with-setgid/test.txt

# Compare:
ls -la /tmp/permissions-lab/day4/no-setgid/test.txt
# deployer:deployer     ← primary group (BAD for www-data!)

ls -la /tmp/permissions-lab/day4/with-setgid/test.txt
# deployer:www-data     ← inherited from directory (GOOD!)
```

### Exercise 3: setgid Cascades to Subdirectories
```bash
sudo bash -c '
  mkdir -p /tmp/permissions-lab/day4/parent
  chown deployer:www-data /tmp/permissions-lab/day4/parent
  chmod 2775 /tmp/permissions-lab/day4/parent
'

# Create subdirectory as deployer
sudo -u deployer mkdir /tmp/permissions-lab/day4/parent/child

ls -la -d /tmp/permissions-lab/day4/parent/child
# Q: What is the group? (www-data — inherited)
# Q: Does it have the setgid bit? (Yes — also inherited!)
# This means child/grandchild/etc all inherit too
```

### Exercise 4: Sticky Bit
```bash
mkdir /tmp/permissions-lab/day4/shared-space
chmod 1777 /tmp/permissions-lab/day4/shared-space

ls -la -d /tmp/permissions-lab/day4/shared-space
# drwxrwxrwt ← 't' at the end = sticky bit

# Q: Can everyone create files here? YES
# Q: Can user A delete user B's files? NO (sticky bit prevents it)
```

### Exercise 5: Decode Permission Strings
```
Q1: drwxrwsr-x — what special bits are set?
    A: setgid (the 's' in group execute position)

Q2: -rwsr-xr-x — what special bits are set?
    A: setuid (the 's' in owner execute position)

Q3: drwxrwxrwt — what special bits are set?
    A: sticky bit (the 't' in others execute position)

Q4: What is the numeric mode for drwxrwsr-x?
    A: 2775 (2=setgid, 7=rwx, 7=rwx, 5=r-x)

Q5: What is the numeric mode for drwxrwxrwt?
    A: 1777 (1=sticky, 7=rwx, 7=rwx, 7=rwx)
```

### Exercise 6: Simulate Our Full Fix
```bash
# Simulate the Tripcart permission model
sudo bash -c '
  # Create project structure
  mkdir -p /tmp/permissions-lab/day4/webapp/{storage/logs,bootstrap/cache,public/sitemap}

  # Set ownership
  chown -R deployer:www-data /tmp/permissions-lab/day4/webapp

  # Set permissions with setgid
  find /tmp/permissions-lab/day4/webapp -type d -exec chmod 2775 {} \;
  find /tmp/permissions-lab/day4/webapp -type f -exec chmod 664 {} \;
'

# Now simulate deployer creating a new log file (with umask 002)
sudo -u deployer bash -c 'umask 002; echo "log entry" > /tmp/permissions-lab/day4/webapp/storage/logs/app.log'

ls -la /tmp/permissions-lab/day4/webapp/storage/logs/app.log
# Q: What is the owner? (deployer)
# Q: What is the group? (www-data — from setgid!)
# Q: What are the permissions? (664 — from umask 002!)
# Q: Can www-data write to it? (YES!)
```

---

## Key Takeaways

1. **setgid on directories** (2xxx) makes new files inherit the directory's group — this is how we ensure www-data group on all files
2. setgid cascades — new subdirectories also get the setgid bit
3. **2775** = setgid + owner rwx + group rwx + others r-x
4. **umask 002 + setgid 2775** together solve the ownership problem: deployer creates files that www-data can access
5. Sticky bit (1xxx) prevents users from deleting each other's files (/tmp uses this)
6. setuid (4xxx) on files is dangerous — know it but don't use it

---

## Quick Reference

```bash
# Set setgid
chmod 2775 dir/           # numeric
chmod g+s dir/            # symbolic

# Set sticky bit
chmod 1777 dir/           # numeric
chmod +t dir/             # symbolic

# Spot special bits in ls output:
# drwxrwsr-x  = setgid (s in group)
# -rwsr-xr-x  = setuid (s in owner)
# drwxrwxrwt  = sticky (t in others)

# Uppercase S/T means the bit is set but execute is NOT:
# drwxrwSr-x  = setgid, no group execute
# drwxrwxrwT  = sticky, no others execute
```
