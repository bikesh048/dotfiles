# Day 2: Ownership — chown, chgrp, and Groups

## Goal
Understand users, groups, and how to change file ownership.

## Users and Groups in Linux

Every Linux user has:
- **UID** (User ID) — unique number identifying the user
- **Primary group** — their default group (files they create get this group)
- **Secondary groups** — additional groups they belong to

```bash
# See your user info
id
# Output: uid=1001(bikesh) gid=1001(bikesh) groups=1001(bikesh),33(www-data),27(sudo)
#                                                    │                │            │
#                                         primary group     secondary    secondary
```

### System Users vs Human Users

| Type | Examples | UID Range | Has Home Dir? | Can Login? | Purpose |
|------|----------|-----------|---------------|------------|---------|
| System | www-data, nobody, mysql | 1-999 | Usually no | No | Run services |
| Human | bikesh, deployer | 1000+ | Yes | Yes | Real people/deploy users |

```bash
# See a user's info
id www-data
# uid=33(www-data) gid=33(www-data) groups=33(www-data)

id deployer
# uid=1001(deployer) gid=1001(deployer) groups=1001(deployer),33(www-data)
```

## Why Groups Matter

Groups let you share access WITHOUT making files world-readable:

```
Scenario: deployer owns files, www-data needs to read/write them

Solution 1 (bad):  chmod 666 file    → EVERYONE can read+write (insecure!)
Solution 2 (good): chown deployer:www-data file + chmod 664 file
                   → only deployer and www-data can write
```

## chown — Change Owner

```bash
# Change owner only
sudo chown bikesh file.txt

# Change owner and group
sudo chown deployer:www-data file.txt

# Change group only (note the colon before group)
sudo chown :www-data file.txt

# Recursive (all files inside directory)
sudo chown -R deployer:www-data /var/www/app/
```

**Important:** Only `root` can change file ownership. Regular users can't give away their files.

## chgrp — Change Group

```bash
# Change group
sudo chgrp www-data file.txt

# Recursive
sudo chgrp -R www-data /var/www/app/
```

**Note:** `chown :www-data` and `chgrp www-data` do the same thing. Most people use `chown` for both.

## How New Files Get Their Owner and Group

When a user creates a file:

```
Owner = the user who created it
Group = the user's PRIMARY group (not secondary groups!)
```

Example:
```bash
# deployer's primary group is "deployer" (not www-data)
id deployer
# uid=1001(deployer) gid=1001(deployer) groups=1001(deployer),33(www-data)

# When deployer creates a file:
sudo -u deployer touch /tmp/test-file
ls -la /tmp/test-file
# -rw-r--r--  deployer  deployer  ← group is "deployer", NOT "www-data"!
```

**This is a problem!** Deployer creates files with group `deployer`, but www-data needs group `www-data` to access them. We'll solve this on Day 4 with setgid.

## Group Management Commands

```bash
# List all groups
cat /etc/group

# Create a new group
sudo groupadd developers

# Add user to a group (append, keep existing groups)
sudo usermod -aG www-data deployer
# -a = append (without this, it REPLACES all groups!)
# -G = secondary group

# Remove user from a group
sudo gpasswd -d bikesh developers

# See which groups a user belongs to
groups deployer
# deployer : deployer www-data
```

### The -a Flag is Critical!

```bash
# DANGEROUS — removes user from ALL other groups:
sudo usermod -G www-data deployer
# deployer is now ONLY in www-data, removed from sudo, developers, etc!

# SAFE — adds to group while keeping existing:
sudo usermod -aG www-data deployer
# deployer keeps all existing groups AND gets www-data added
```

---

## Real-World Example: The Tripcart Permission Model

```
deployer (uid=1001)
  ├── primary group: deployer
  └── secondary group: www-data    ← added by Ansible

www-data (uid=33)
  └── primary group: www-data

File: /var/www/qa-tripcart/storage/logs/laravel.log
  owner: deployer    ← deployer can read+write (owner permissions)
  group: www-data    ← www-data can read+write (group permissions)
  mode: 664          ← rw-rw-r--
```

The Ansible playbook does this:
```yaml
# In users.yml — add deployer to www-data group
- name: Ensure users are in the correct groups
  user:
    name: deployer
    groups: www-data
    append: yes

# In permissions.yml — set ownership on all files
- name: Set ownership on entire project directory
  file:
    path: /var/www/qa-tripcart
    owner: deployer
    group: www-data
    recurse: yes
```

---

## Practice Exercises

**Setup:**
```bash
mkdir -p /tmp/permissions-lab/day2
cd /tmp/permissions-lab/day2
```

### Exercise 1: Understand Your Identity
```bash
# Check your user and groups
id
whoami
groups

# Q: What is your primary group?
# Q: What secondary groups do you have?
# Q: Are you in the sudo group?
```

### Exercise 2: File Ownership on Creation
```bash
touch my-file.txt
ls -la my-file.txt
# Q: Who is the owner?
# Q: What is the group? Is it your primary or secondary group?
```

### Exercise 3: Change Ownership
```bash
# Create files
echo "owned by me" > test-ownership.txt
ls -la test-ownership.txt

# Try changing owner without sudo
chown root test-ownership.txt
# Q: What happens? Why?

# Change with sudo
sudo chown root:root test-ownership.txt
ls -la test-ownership.txt

# Change back
sudo chown $(whoami):$(whoami) test-ownership.txt
```

### Exercise 4: Group Sharing Scenario
```bash
# Simulate deployer + www-data scenario
sudo bash -c '
  mkdir /tmp/permissions-lab/day2/webapp
  echo "<?php echo hello; ?>" > /tmp/permissions-lab/day2/webapp/index.php

  # Owned by deployer:www-data
  chown deployer:www-data /tmp/permissions-lab/day2/webapp/index.php
  chmod 664 /tmp/permissions-lab/day2/webapp/index.php
'

ls -la /tmp/permissions-lab/day2/webapp/index.php
# Q: Can deployer write to this file? (Yes — owner has rw-)
# Q: Can www-data write to this file? (Yes — group has rw-)
# Q: Can bikesh write to this file? (No — others have r--)
# Q: What if bikesh is in the www-data group? (Yes! — group check passes)
```

### Exercise 5: The -a Flag Danger
```bash
# Check deployer's current groups
id deployer

# NEVER run this in production (just understand it):
# sudo usermod -G onlyThisGroup deployer  ← REMOVES all other groups!

# Always use -aG:
# sudo usermod -aG newgroup deployer      ← ADDS group, keeps existing
```

---

## Key Takeaways

1. Every file has ONE owner and ONE group
2. Users have a primary group (for new files) and secondary groups (for access)
3. Only `root` can change file ownership (`chown`)
4. New files get the creator's PRIMARY group — this is why deployer creates files with group `deployer`, not `www-data`
5. Always use `usermod -aG` (with `-a`!) to add groups — without `-a` you remove all existing groups
6. The `deployer:www-data` ownership model lets both the deploy user and PHP work with the same files

---

## Quick Reference

```bash
id                              # Show your user/group info
id username                     # Show another user's info
groups username                 # List user's groups

sudo chown user:group file      # Change owner and group
sudo chown -R user:group dir/   # Recursive
sudo chown :group file          # Change group only
sudo usermod -aG group user     # Add user to group (KEEP -a!)

cat /etc/passwd                 # All users
cat /etc/group                  # All groups
```

