
# Day 6: Real-World Debugging — The Tripcart Case Study

## Goal
Practice diagnosing and fixing permission problems using everything from Days 1-5.

## The Debugging Framework

When you see "Permission denied", follow these 5 steps:

```
Step 1: WHO is trying to access?    → which user/process
Step 2: WHAT are they trying to do? → read, write, execute, enter directory
Step 3: What are the CURRENT permissions?  → ls -la, getfacl
Step 4: WHY is access denied?       → trace through the permission check
Step 5: What's the MINIMAL fix?     → change only what's needed
```

## Case Study 1: Sitemap Permission Denied

### The Error
```
file_put_contents(/var/www/qa-tripcart/public/sitemap/everest-alpine-trekking/sitemap.xml):
Failed to open stream: Permission denied
```

### Step 1: WHO?
The stack trace shows `Queue/Worker.php` → this is a **queue worker** running as `www-data` (because PHP-FPM runs as www-data).

```bash
# Verify what user PHP runs as:
ps aux | grep php-fpm
# www-data  12345  ... php-fpm: pool www
```

### Step 2: WHAT?
`file_put_contents()` = trying to **write** a file.

Writing a file requires:
- `w` on the FILE (if it exists)
- `w` + `x` on the DIRECTORY (if creating new file)

### Step 3: CURRENT Permissions?
```bash
ls -la /var/www/qa-tripcart/public/sitemap/everest-alpine-trekking/
# drwxr-sr-x  deployer  www-data  .
# -rw-r--r--  deployer  www-data  sitemap.xml

getfacl /var/www/qa-tripcart/public/sitemap/everest-alpine-trekking/sitemap.xml
# owner: deployer
# group: www-data
# user::rw-
# group::r--          ← BASE group entry
# group:developers:r-x
# mask::rwx
# other::r--
```

### Step 4: WHY Denied?

Trace the permission check for www-data trying to WRITE sitemap.xml:

```
1. Is www-data the owner?
   Owner = deployer → NO

2. Does www-data match a named user ACL?
   No user:www-data entry → NO

3. Is www-data the owning group?
   Group = www-data → YES
   → Use group::r--
   → r-- does NOT include write
   → DENIED!

4. (Never reached) Check named group entries
5. (Never reached) Check others
```

**Root cause:** `group::r--` — the base group entry only has read.

### Step 5: Minimal Fix

```bash
# Immediate fix on existing files:
sudo find /var/www/qa-tripcart/public/sitemap -type f -exec setfacl -m g::rw {} \;
sudo find /var/www/qa-tripcart/public/sitemap -type d -exec setfacl -m g::rwx {} \;

# Permanent fix (prevent it on new files):
sudo setfacl -R -d -m g::rwx /var/www/qa-tripcart/public/sitemap
```

---

## Case Study 2: Laravel Log Write Failure

### The Error
```
Unable to create or write to /var/www/qa-tripcart/storage/logs/laravel-2026-02-09.log
```

### Debugging
```bash
# Step 1: WHO? → php-fpm (www-data)
# Step 2: WHAT? → write/create new file

# Step 3: Check parent directory (for creating new file)
ls -la /var/www/qa-tripcart/storage/logs/
# drwxr-sr-x deployer www-data .

getfacl /var/www/qa-tripcart/storage/logs/
# group::r-x   ← can't write! Can't create files!

# Step 4: WHY?
# www-data is owning group → uses group::r-x → no write → can't create file

# Step 5: Fix
sudo setfacl -m g::rwx /var/www/qa-tripcart/storage/logs/
sudo setfacl -d -m g::rwx /var/www/qa-tripcart/storage/logs/
```

---

## Case Study 3: Developer Can't Read Nginx Logs

### The Error
```
tail -f /var/log/nginx/error.log
tail: cannot open 'error.log' for reading: Permission denied
```

### Debugging
```bash
# Step 1: WHO? → bikesh (developer user)
id bikesh
# uid=1002(bikesh) gid=1002(bikesh) groups=1002(bikesh),1003(developers)

# Step 2: WHAT? → read file

# Step 3: Check permissions
ls -la /var/log/nginx/error.log
# -rw-r----- www-data adm error.log
# Owner: www-data (rw-)
# Group: adm (r--)
# Others: --- (nothing)

ls -la -d /var/log/nginx/
# drwxr-x--- root adm /var/log/nginx/

# Step 4: WHY?
# bikesh is not www-data (owner) → NO
# bikesh is not in adm group → NO
# others permission = --- → DENIED
# Also: directory /var/log/nginx/ is 750 root:adm → bikesh can't even ENTER

# Step 5: Fix — add developers to adm group
sudo usermod -aG adm bikesh
# (bikesh must re-login for group to take effect)
```

---

## Case Study 4: Files Created by Artisan Have Wrong Permissions

### The Problem
After running `php artisan cache:clear`, cache files are owned by deployer but with `644` instead of `664`:

```bash
ls -la /var/www/qa-tripcart/bootstrap/cache/
# -rw-r--r-- deployer deployer config.php    ← group is deployer (not www-data)!
#                                               and permissions are 644 (not 664)!
```

### Debugging
```bash
# Step 1: WHO created the file? → deployer (via sudo -u deployer php artisan)
# Step 2: WHAT went wrong? → wrong group + wrong permissions

# Step 3: Check umask
sudo -u deployer bash -c 'umask'
# 0022  ← creates files as 644 (group can't write!)

# Check if directory has setgid
ls -la -d /var/www/qa-tripcart/bootstrap/cache/
# drwxr-xr-x deployer www-data  ← no 's'! setgid not set!

# Step 4: WHY?
# umask 022 → files get 644 (group can't write)
# No setgid → files get deployer's primary group (deployer, not www-data)

# Step 5: Fix
# Set umask:
echo "umask 002" >> /home/deployer/.bashrc

# Set setgid:
sudo chmod 2775 /var/www/qa-tripcart/bootstrap/cache/

# Fix existing files:
sudo chown -R deployer:www-data /var/www/qa-tripcart/bootstrap/cache/
sudo find /var/www/qa-tripcart/bootstrap/cache/ -type f -exec chmod 664 {} \;
sudo find /var/www/qa-tripcart/bootstrap/cache/ -type d -exec chmod 2775 {} \;
```

---

## Debugging Cheat Sheet

```bash
# === GATHER INFORMATION ===

# Who am I?
id
whoami
groups

# What user is this process running as?
ps aux | grep php-fpm
ps aux | grep nginx
ps aux | grep supervisord

# What are the permissions?
ls -la /path/to/file
ls -la -d /path/to/directory/    # -d shows the directory itself

# What are the ACLs?
getfacl /path/to/file
getfacl /path/to/directory/

# What is the umask?
umask
sudo -u deployer bash -c 'umask'

# Does the directory have setgid?
stat -c "%a %U %G" /path/to/directory   # Shows numeric mode, owner, group

# === COMMON FIXES ===

# Fix ownership
sudo chown -R deployer:www-data /path/

# Fix basic permissions
sudo find /path/ -type d -exec chmod 2775 {} \;   # directories
sudo find /path/ -type f -exec chmod 664 {} \;    # files

# Fix ACL base group
sudo find /path/ -type d -exec setfacl -m g::rwx {} \;
sudo find /path/ -type f -exec setfacl -m g::rw {} \;

# Fix ACL defaults (for new files)
sudo setfacl -R -d -m g::rwx /path/
sudo setfacl -R -d -m m::rwx /path/

# Fix mask
sudo setfacl -R -m m::rwx /path/

# Nuclear option: remove all ACLs and start fresh
sudo setfacl -R -b /path/
sudo chown -R deployer:www-data /path/
sudo find /path/ -type d -exec chmod 2775 {} \;
sudo find /path/ -type f -exec chmod 664 {} \;
```

---

## Practice Exercises

### Exercise 1: Debug a Permission Denied
```bash
# Setup the broken scenario
sudo bash -c '
  mkdir -p /tmp/permissions-lab/day6/app/storage/logs
  echo "log data" > /tmp/permissions-lab/day6/app/storage/logs/app.log
  chown deployer:www-data /tmp/permissions-lab/day6/app/storage/logs/app.log
  chmod 640 /tmp/permissions-lab/day6/app/storage/logs/app.log
  # Add ACL that sets base group to r--
  setfacl -m g::r /tmp/permissions-lab/day6/app/storage/logs/app.log
'

# YOUR TASK: www-data needs to WRITE to this file
# 1. Check current permissions (ls -la)
# 2. Check ACLs (getfacl)
# 3. Identify the problem
# 4. Fix it with the minimal command
# 5. Verify the fix
```

### Exercise 2: Debug a Missing Directory
```bash
# Setup
sudo bash -c '
  mkdir -p /tmp/permissions-lab/day6/app/public/sitemap
  chown deployer:www-data /tmp/permissions-lab/day6/app/public/sitemap
  chmod 2755 /tmp/permissions-lab/day6/app/public/sitemap   # group has r-x, not rwx!
'

# YOUR TASK: www-data needs to CREATE files inside this directory
# 1. Check permissions
# 2. Identify the problem (hint: directory needs w for creating files)
# 3. Fix it
# 4. Create a test file as www-data to verify
```

### Exercise 3: Full Scenario Debugging
```bash
# Setup a realistic broken deployment
sudo bash -c '
  mkdir -p /tmp/permissions-lab/day6/webapp/{storage/logs,bootstrap/cache,public/uploads}

  # Simulate deployer with wrong umask creating files
  umask 022
  echo "cached" > /tmp/permissions-lab/day6/webapp/bootstrap/cache/config.php
  echo "log" > /tmp/permissions-lab/day6/webapp/storage/logs/laravel.log
  mkdir /tmp/permissions-lab/day6/webapp/public/uploads/images

  # Owner is root (simulating wrong ownership)
  chown -R root:root /tmp/permissions-lab/day6/webapp
'

# YOUR TASK: Fix everything so that:
# - deployer owns all files
# - www-data group on everything
# - directories are 2775
# - files are 664
# - ACL base group is rwx for dirs, rw for files
# - Default ACLs set for inheritance
#
# Write your fix commands below, then run them and verify with getfacl
```

---

## Key Takeaways

1. Always follow the 5-step debugging framework: WHO, WHAT, CURRENT, WHY, FIX
2. Check BOTH `ls -la` and `getfacl` — basic permissions and ACLs can conflict
3. When ACLs exist, the `group::` entry matters most for the owning group
4. `chmod` changes the mask when ACLs exist — use `setfacl` for base group
5. Check the DIRECTORY permissions too — you need `wx` on a directory to create files inside
6. Always verify your fix after applying it
