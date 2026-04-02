
# Day 5: ACLs (Access Control Lists) — Beyond Basic Permissions

## Goal
Understand ACLs: what they are, when you need them, and the traps that caught us.

## Why ACLs?

Basic Linux permissions have a limit: ONE owner, ONE group, ONE "others". What if you need:
- `deployer` (owner) → rwx
- `www-data` (group) → rwx
- `developers` group → r-x (read only)

Basic permissions can't do this. You'd need a second group entry. That's what ACLs provide.

## ACL Basics

ACLs add **extra permission entries** beyond the standard owner/group/others:

```
Standard permissions:          With ACLs:
  user::rwx   (owner)           user::rwx       (owner)
  group::r-x  (group)           user:bikesh:rwx  (named user)
  other::r-x  (others)          group::r-x      (owning group)
                                 group:developers:r-x  (named group)
                                 mask::rwx       (ceiling)
                                 other::r-x      (others)
```

## Reading ACLs: getfacl

```bash
getfacl /var/www/qa-tripcart/storage/
# file: var/www/qa-tripcart/storage/
# owner: deployer
# group: www-data
# flags: -s-                         ← 's' = setgid
user::rwx                            ← deployer (owner) gets rwx
user:deployer:rwx                    ← named entry for deployer
group::rwx                           ← www-data (owning group) base entry
group:www-data:rwx                   ← named entry for www-data
group:developers:r-x                 ← named entry for developers
mask::rwx                            ← maximum for any group/named entry
other::r-x                           ← everyone else
default:user::rwx                    ← new files: owner gets rwx
default:user:deployer:rwx            ← new files: deployer gets rwx
default:group::rwx                   ← new files: owning group gets rwx
default:group:www-data:rwx           ← new files: www-data gets rwx
default:mask::rwx                    ← new files: mask is rwx
default:other::r-x                   ← new files: others get r-x
```

## The Two Types of ACL Entries

### 1. Access ACLs (applied to existing files/dirs)
```bash
# Grant www-data group rwx on a directory
setfacl -m g:www-data:rwx /var/www/app/storage

# Grant developer user read access
setfacl -m u:bikesh:rx /var/www/app/storage
```

### 2. Default ACLs (inherited by NEW files created inside)
```bash
# New files inside will give www-data rwx
setfacl -d -m g:www-data:rwx /var/www/app/storage

# -d = default (for inheritance)
```

**Default ACLs are crucial!** Without them, new files won't have the extra ACL entries.

## The ACL Mask — The Most Confusing Part

The **mask** is a CEILING for all group and named entries. Even if you set `group:www-data:rwx`, the effective permission is limited by the mask:

```
Effective permission = entry AND mask

Example:
  group:www-data:rwx    ← what you set
  mask::r-x             ← the ceiling
  effective: r-x        ← rwx AND r-x = r-x (write blocked!)
```

### You can see this in getfacl output:
```
group:www-data:rwx    #effective:r-x     ← the comment shows the REAL permission!
mask::r-x
```

### Solution: Always set mask to rwx
```bash
setfacl -m m::rwx /var/www/app/storage
setfacl -d -m m::rwx /var/www/app/storage   # default mask too
```

## THE BIG TRAP: chmod Changes the Mask!

This is the bug that caught us in the Tripcart setup:

```
BEFORE chmod:
  group::rwx           ← base group has rwx
  mask::rwx            ← mask allows rwx
  → effective: rwx ✓

After someone runs: chmod 755 directory

AFTER chmod:
  group::rwx           ← UNCHANGED
  mask::r-x            ← chmod changed THIS, not group::!
  → effective: r-x ✗   ← write blocked!
```

**When ACLs exist, chmod changes the MASK, not the base group entry.**

This means:
```bash
chmod g+w file       # Changes mask, NOT group::
setfacl -m g::rw file  # Changes group:: directly ← USE THIS
```

## THE BIGGER TRAP: Owning Group vs Named Group

This is the hardest concept and the one that caused our sitemap bug:

```
File: sitemap.xml
  owner: deployer
  group: www-data        ← www-data is the OWNING group

ACL entries:
  group::r--             ← base group entry (for owning group)
  group:www-data:rwx     ← named group entry (for www-data)
  mask::rwx
```

**POSIX ACL rule:** If a user matches the **owning group**, Linux uses `group::` (base entry), NOT `group:www-data:` (named entry).

```
www-data checking access:
  1. Is www-data the owner? No (deployer is)
  2. Is www-data the owning group? YES
     → Use group::r--    ← READ ONLY!
     → Ignore group:www-data:rwx  ← NEVER CHECKED!

Result: www-data can't write, even though group:www-data:rwx says rwx!
```

**This is counterintuitive.** You'd expect `group:www-data:rwx` to give www-data rwx. But because www-data IS the owning group, Linux uses `group::r--` instead.

### The Fix:
```bash
# Set the BASE group entry to rwx (not just the named entry)
setfacl -m g::rwx /var/www/app/storage/file.txt

# For new files (default):
setfacl -d -m g::rwx /var/www/app/storage/
```

## Default ACLs and Inheritance

When default ACLs are set on a directory, new files/dirs created inside inherit them:

```
Parent directory default ACLs:        New file gets:
  default:user::rwx            →      user::rwx
  default:user:deployer:rwx    →      user:deployer:rwx
  default:group::rwx           →      group::rwx          ← THIS IS KEY!
  default:group:www-data:rwx   →      group:www-data:rwx
  default:mask::rwx            →      mask::rwx
  default:other::r-x           →      other::r-x
```

If you DON'T set `default:group::rwx`, new files get whatever the system default is (usually `r-x`), and the owning group can't write!

## setfacl Command Reference

```bash
# Set ACL for a user
setfacl -m u:username:rwx file

# Set ACL for a group
setfacl -m g:groupname:rwx file

# Set base group entry
setfacl -m g::rwx file

# Set mask
setfacl -m m::rwx file

# Set DEFAULT (for inheritance)
setfacl -d -m g::rwx directory
setfacl -d -m g:www-data:rwx directory
setfacl -d -m m::rwx directory

# Recursive
setfacl -R -m g::rwx directory      # all existing files/dirs
setfacl -R -d -m g::rwx directory   # set defaults on all dirs

# Remove all ACLs
setfacl -b file

# Remove specific entry
setfacl -x u:username file
```

## Ansible ACL Module

```yaml
# Named group entry
- name: Set ACL for www-data
  acl:
    path: "{{ laravel_project_path }}"
    entity: "{{ web_user }}"
    etype: group
    permissions: rwx
    state: present
    recursive: yes

# Default ACL (using entry format)
- name: Set default ACL
  acl:
    path: "{{ laravel_project_path }}"
    entry: "default:group::rwx"    # base group default
    state: present
    recursive: yes

# LIMITATION: Ansible's acl module can't set base group:: on existing files
# Use shell + setfacl instead:
- name: Fix base group ACL on existing files
  shell: |
    find {{ path }} -type d -exec setfacl -m g::rwx {} \;
    find {{ path }} -type f -exec setfacl -m g::rw {} \;
```

---

## Practice Exercises

**Setup:**
```bash
mkdir -p /tmp/permissions-lab/day5
cd /tmp/permissions-lab/day5
```

### Exercise 1: View ACLs
```bash
# Create a file and check — no ACLs yet
touch normal-file.txt
getfacl normal-file.txt
# Notice: no named entries, no mask, no defaults

# Now add an ACL
setfacl -m u:root:rwx normal-file.txt
getfacl normal-file.txt
# Notice: mask appeared! named user entry appeared!
```

### Exercise 2: The Mask Effect
```bash
touch mask-test.txt
setfacl -m g:root:rwx mask-test.txt
getfacl mask-test.txt
# group:root:rwx, mask::rwx → effective rwx

# Now change mask
setfacl -m m::r mask-test.txt
getfacl mask-test.txt
# group:root:rwx   #effective:r--  ← rwx limited to r-- by mask!
```

### Exercise 3: chmod vs setfacl
```bash
touch chmod-test.txt
setfacl -m g:root:rwx chmod-test.txt
getfacl chmod-test.txt
# mask::rwx, group:root:rwx → effective rwx

# Use chmod to "set group permissions"
chmod 644 chmod-test.txt
getfacl chmod-test.txt
# mask::r--  ← chmod changed the MASK, not group:root!
# group:root:rwx  #effective:r--  ← write blocked!

# Fix with setfacl
setfacl -m m::rwx chmod-test.txt
getfacl chmod-test.txt
# mask::rwx, group:root:rwx → effective rwx again
```

### Exercise 4: Default ACLs and Inheritance
```bash
mkdir inherit-test
setfacl -d -m g:root:rwx inherit-test
setfacl -d -m g::rwx inherit-test
setfacl -d -m m::rwx inherit-test

# Check defaults
getfacl inherit-test
# default:group::rwx
# default:group:root:rwx
# default:mask::rwx

# Create a file inside
touch inherit-test/child.txt
getfacl inherit-test/child.txt
# group::rw-     ← inherited from default:group::rwx (limited by umask for files)
# group:root:rw- ← inherited from default:group:root:rwx
# mask::rw-

# Create a directory inside
mkdir inherit-test/child-dir
getfacl inherit-test/child-dir
# group::rwx     ← inherited!
# default:group::rwx ← defaults also inherited to subdirs!
```

### Exercise 5: The Owning Group Trap
```bash
# This is the exact bug we hit
sudo bash -c '
  touch /tmp/permissions-lab/day5/trap-test.txt
  chown deployer:www-data /tmp/permissions-lab/day5/trap-test.txt

  # Set named group ACL for www-data
  setfacl -m g:www-data:rw /tmp/permissions-lab/day5/trap-test.txt

  # But leave base group as r--
  setfacl -m g::r /tmp/permissions-lab/day5/trap-test.txt
'

getfacl /tmp/permissions-lab/day5/trap-test.txt
# owner: deployer
# group: www-data
# group::r--             ← base entry
# group:www-data:rw-     ← named entry

# Q: Can www-data write? NO!
# Because www-data IS the owning group, it uses group::r-- not group:www-data:rw-

# Fix:
sudo setfacl -m g::rw /tmp/permissions-lab/day5/trap-test.txt
getfacl /tmp/permissions-lab/day5/trap-test.txt
# group::rw-  ← now www-data can write!
```

---

## Key Takeaways

1. ACLs add extra permission entries beyond owner/group/others
2. **Default ACLs** = inheritance for new files. Without them, new files don't get extra entries
3. **Mask** = ceiling for all group and named entries. `chmod` changes the mask, not base entries
4. **Owning group uses `group::`, not `group:name:`** — this is the #1 ACL trap
5. Use `setfacl -m g::rwx` to set the base group entry (chmod can't do this)
6. Always set `default:group::rwx` and `default:mask::rwx` for writable directories

---

## Quick Reference

```bash
getfacl file                         # View ACLs
setfacl -m u:user:rwx file           # Set user ACL
setfacl -m g:group:rwx file          # Set named group ACL
setfacl -m g::rwx file               # Set BASE group ACL
setfacl -m m::rwx file               # Set mask
setfacl -d -m g::rwx dir             # Set default base group
setfacl -R -m g::rwx dir             # Recursive
setfacl -R -d -m g::rwx dir          # Recursive defaults
setfacl -b file                      # Remove all ACLs

# The three things that must be rwx for writable dirs:
setfacl -m g::rwx dir                # base group on existing
setfacl -d -m g::rwx dir             # base group on new files
setfacl -m m::rwx dir                # mask (ceiling)
```
