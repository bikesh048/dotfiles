
# Day 3: umask — The Default Permission Filter

## Goal
Understand how umask controls the default permissions of every new file.

## The Problem

When deployer creates a file, what permissions does it get?

```bash
sudo -u deployer touch /tmp/newfile.txt
ls -la /tmp/newfile.txt
# -rw-r--r--  deployer  deployer   ← group can only READ (r--)
```

www-data is in the group, but the file is `644` — group can't write! Who decided the permissions should be `644`? That's umask.

## What is umask?

umask is a **filter** that REMOVES permissions from new files. Think of it as:

```
Final permissions = Maximum permissions - umask
```

The maximum permissions are:
- Files: `666` (rw-rw-rw-) — files never get execute by default
- Directories: `777` (rwxrwxrwx)

### Common umask values:

```
umask 022 (default on most systems):
  Files:       666 - 022 = 644  (rw-r--r--)   ← group can't write!
  Directories: 777 - 022 = 755  (rwxr-xr-x)   ← group can't write!

umask 002 (what we set for deployer):
  Files:       666 - 002 = 664  (rw-rw-r--)   ← group CAN write!
  Directories: 777 - 002 = 775  (rwxrwxr-x)   ← group CAN write!

umask 077 (very restrictive):
  Files:       666 - 077 = 600  (rw-------)   ← only owner can access
  Directories: 777 - 077 = 700  (rwx------)   ← only owner can access
```

## How umask Actually Works (Bitwise)

The subtraction analogy is simplified. umask actually works with bitwise AND NOT:

```
Final = Maximum AND (NOT umask)

umask 022 in binary: 000 010 010
NOT umask:           111 101 101

Maximum (file) 666:  110 110 110
AND NOT umask:       111 101 101
Result:              110 100 100  = 644 (rw-r--r--)
```

But for daily use, just remember: **umask 022 = group can't write, umask 002 = group can write.**

## Checking and Setting umask

```bash
# Check current umask
umask
# 0022

# The leading 0 is for special permissions (setuid/setgid/sticky)
# 0022 means: no special bits removed, owner keeps all, group loses w, others lose w

# Set umask for current session
umask 002

# Check again
umask
# 0002

# Test: create a file
touch /tmp/test-umask.txt
ls -la /tmp/test-umask.txt
# -rw-rw-r--  ← now group has write!
```

## Making umask Permanent

umask only lasts for the current session. To make it permanent, add it to shell config:

```bash
# In ~/.bashrc (runs for every new bash session)
umask 002
```

This is exactly what our Ansible playbook does:

```yaml
- name: Set umask 002 for deployer (ensures group-writable files)
  lineinfile:
    path: "/home/deployer/.bashrc"
    line: "umask 002"
    regexp: "^umask"    # Replace any existing umask line
    state: present
```

## The sudo umask Problem

Even with umask 002 in deployer's `.bashrc`, there's a trap:

```bash
# GoCD runs commands as deployer via sudo:
sudo -u deployer bash -c 'touch /tmp/test.txt'

# But sudo might RESET the umask to the system default (022)!
```

Solution: Set umask in sudoers config:

```
# In /etc/sudoers.d/15-deployer-umask
Defaults:deployer umask=0002
```

This tells sudo: "When running commands as deployer, always use umask 0002."

Our Ansible playbook does this:
```yaml
security_sudoers_configs:
  - name: "deployer-umask"
    priority: "15"
    content: "Defaults:deployer umask=0002"
```

## Visual: The umask Journey

```
                    GoCD Agent
                        │
                        ▼
              sudo -u deployer bash -c 'deploy...'
                        │
          ┌─────────────┼──────────────┐
          │             │              │
     Is umask in    Is umask in    Is umask in
     .bashrc?       sudoers?       /etc/profile?
          │             │              │
     umask 002     umask=0002      (system default
     (for login)   (for sudo)       022 - we don't
          │             │            change this)
          └──────┬──────┘
                 ▼
         New file: rw-rw-r-- (664)
         www-data CAN write!
```

---

## Practice Exercises

**Setup:**
```bash
mkdir -p /tmp/permissions-lab/day3
cd /tmp/permissions-lab/day3
```

### Exercise 1: See Your Current umask
```bash
umask
# Q: What is your current umask?
# Q: If you create a file now, what permissions will it have?
#    Calculate: 666 - (your umask) = ?

touch test1.txt
ls -la test1.txt
# Q: Does it match your calculation?
```

### Exercise 2: Change umask and Observe
```bash
# Set permissive umask
umask 000
touch open-file.txt
mkdir open-dir
ls -la open-file.txt   # Should be: -rw-rw-rw- (666)
ls -la -d open-dir     # Should be: drwxrwxrwx (777)

# Set restrictive umask
umask 077
touch private-file.txt
mkdir private-dir
ls -la private-file.txt   # Should be: -rw------- (600)
ls -la -d private-dir     # Should be: drwx------ (700)

# Set our target umask
umask 002
touch shared-file.txt
mkdir shared-dir
ls -la shared-file.txt   # Should be: -rw-rw-r-- (664)
ls -la -d shared-dir     # Should be: drwxrwxr-x (775)
```

### Exercise 3: umask Doesn't Affect chmod
```bash
umask 077
touch restricted.txt
ls -la restricted.txt    # -rw------- (umask applied)

# But chmod ignores umask:
chmod 777 restricted.txt
ls -la restricted.txt    # -rwxrwxrwx (chmod overrides)

# umask only affects NEW file creation, not chmod
```

### Exercise 4: umask is Per-Session
```bash
# Set umask in this session
umask 002
touch session-file.txt
ls -la session-file.txt   # -rw-rw-r-- (664)

# Open a NEW terminal and create a file
# It will have default umask (022) unless .bashrc sets it

# Q: Why do we put umask in .bashrc?
# A: Because umask resets with each new shell session
```

### Exercise 5: Simulate the Deployment Problem
```bash
# Simulate default umask (022)
umask 022

mkdir -p /tmp/permissions-lab/day3/webapp/storage
echo "log entry" > /tmp/permissions-lab/day3/webapp/storage/laravel.log
ls -la /tmp/permissions-lab/day3/webapp/storage/laravel.log
# -rw-r--r-- ← group can only READ

# Q: If www-data is in the file's group, can it write? NO!

# Now fix with umask 002
umask 002
echo "new log entry" > /tmp/permissions-lab/day3/webapp/storage/new.log
ls -la /tmp/permissions-lab/day3/webapp/storage/new.log
# -rw-rw-r-- ← group can READ+WRITE

# Q: Can www-data write now? YES!
```

### Exercise 6: Calculate umask Values
```
Q1: You want new files to be 640 (rw-r-----). What umask?
    666 - 640 = 026  → umask 026

Q2: You want new directories to be 750 (rwxr-x---). What umask?
    777 - 750 = 027  → umask 027

Q3: umask 037 — what permissions do new files get?
    666 - 037 = 640  → rw-r-----

Q4: umask 002 — what permissions do new directories get?
    777 - 002 = 775  → rwxrwxr-x
```

---

## Key Takeaways

1. umask is a filter that REMOVES permissions from new files
2. Default umask `022` = group can't write (the root cause of our Tripcart bug)
3. umask `002` = group CAN write (our fix)
4. umask is per-session — put it in `.bashrc` for permanence
5. sudo can reset umask — use sudoers `Defaults:user umask=0002` to preserve it
6. umask only affects NEW file creation, not `chmod`

---

## Quick Reference

```bash
umask              # Show current umask
umask 002          # Set umask for this session

# Common umask values:
# 022 → files 644, dirs 755 (default, group read-only)
# 002 → files 664, dirs 775 (group writable)
# 077 → files 600, dirs 700 (owner only)
# 000 → files 666, dirs 777 (wide open, DON'T use)

# Make permanent:
echo "umask 002" >> ~/.bashrc

# Preserve in sudo:
echo "Defaults:deployer umask=0002" > /etc/sudoers.d/15-deployer-umask
```
