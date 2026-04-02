
# Day 7: Putting It All Together — Ansible Automation

## Goal
Understand how to automate permissions with Ansible and design a permission model that never breaks.

## The Complete Permission Model

After Days 1-6, here's the full picture for a Laravel deployment:

```
┌────────────────────────────────────────────────────────────┐
│                   PERMISSION MODEL                          │
│                                                             │
│  Layer 1: OWNERSHIP        deployer:www-data on all files  │
│  Layer 2: UMASK 002        new files → 664, dirs → 775    │
│  Layer 3: SETGID 2775      new files inherit www-data group│
│  Layer 4: ACL group::rwx   base group can write            │
│  Layer 5: ACL defaults     new files inherit all ACLs      │
│  Layer 6: ACL mask::rwx    mask doesn't reduce permissions │
│                                                             │
│  All 6 layers work together. Remove any one and it breaks. │
└────────────────────────────────────────────────────────────┘
```

## Why Each Layer Exists

```
Q: "Can't we just use chmod 777 on everything?"
A: That gives EVERYONE write access — any compromised service can modify any file.

Q: "Can't we just use chown and chmod?"
A: chmod can't change base group ACL entries once ACLs exist.

Q: "Can't we just use ACLs without umask/setgid?"
A: ACLs only apply to existing files. New files need umask + setgid + default ACLs.

Q: "Why not just run as www-data?"
A: www-data is a system user (no home, no shell). If PHP is compromised,
   attacker gets deployment access. Separation of concerns.
```

## Ansible Permission Tasks — The Right Order

Order matters! Here's the correct sequence:

```
1. users.yml      → Create users, set groups, set umask
2. directories.yml → Create directory structure
3. permissions.yml → Set ownership and modes (deployer:www-data, 2775)
4. acl.yml         → Set ACLs (base group, named entries, defaults, mask)
5. git.yml         → Configure git shared permissions
```

## Task-by-Task Breakdown

### 1. users.yml — Umask Setup

```yaml
# WHY: Without umask 002, deployer creates files as 644 (group read-only)

- name: Set umask 002 for deployer
  lineinfile:
    path: "/home/deployer/.bashrc"
    line: "umask 002"
    regexp: "^umask"
    state: present
# WHAT THIS DOES:
# - Finds any line starting with "umask" in .bashrc
# - Replaces it with "umask 002" (or adds if not found)
# - Next time deployer logs in, new files will be 664
```

### 2. permissions.yml — Ownership and Modes

```yaml
# WHY: Ensures deployer:www-data ownership and setgid on all directories

- name: Set ownership on entire project directory
  file:
    path: "{{ laravel_project_path }}"
    state: directory
    owner: "{{ deployer_user }}"         # deployer
    group: "{{ web_user }}"              # www-data
    mode: '2775'                         # setgid + rwxrwxr-x
    recurse: yes                         # apply to ALL files inside

# WHAT THIS DOES:
# - chown -R deployer:www-data /var/www/qa-tripcart
# - chmod 2775 on all directories (setgid + full group access)
# - NOTE: also sets files to 2775 which gives execute bit — not ideal
#   but ACLs handle the fine-grained control

- name: Ensure runtime-writable directories exist
  file:
    path: "{{ laravel_project_path }}/{{ item }}"
    state: directory
    owner: "{{ deployer_user }}"
    group: "{{ web_user }}"
    mode: '2775'
    recurse: yes
  loop: "{{ laravel_writable_dirs }}"

# WHAT THIS DOES:
# - Creates directories if they don't exist (state: directory)
# - Fixes ownership and mode recursively
# - loop iterates: storage, bootstrap/cache, public/sitemap, public/uploads
```

### 3. acl.yml — ACL Configuration

```yaml
# --- NAMED ENTRIES (access for specific users/groups) ---

- name: Set explicit ACL for deployer on entire project
  acl:
    path: "{{ laravel_project_path }}"
    entity: "{{ deployer_user }}"
    etype: user
    permissions: rwx
    state: present
    recursive: yes
# WHAT: setfacl -R -m u:deployer:rwx /var/www/qa-tripcart
# WHY: Even if deployer isn't the owner of some files, it can still rwx

- name: Set explicit ACL for www-data on entire project
  acl:
    path: "{{ laravel_project_path }}"
    entity: "{{ web_user }}"
    etype: group
    permissions: rwx
    state: present
    recursive: yes
# WHAT: setfacl -R -m g:www-data:rwx /var/www/qa-tripcart
# WHY: Named group entry for www-data (used when www-data is NOT owning group)

# --- BASE GROUP FIX (the chmod can't do this) ---

- name: Fix base group ACL on writable directories
  shell: |
    find {{ laravel_project_path }}/{{ item }} -type d -exec setfacl -m g::rwx {} \;
    find {{ laravel_project_path }}/{{ item }} -type f -exec setfacl -m g::rw {} \;
  loop: "{{ laravel_writable_dirs }}"
# WHAT: Changes group:: entry directly
# WHY: When www-data IS the owning group, this is what determines access
#      Ansible's acl module can't set g:: (base group), only g:name:
#      So we use shell + setfacl

# --- DEFAULT ACLS (inheritance for new files) ---

- name: Set default ACL for deployer
  acl:
    path: "{{ laravel_project_path }}"
    entry: "default:user:{{ deployer_user }}:rwx"
    state: present
    recursive: yes
# WHAT: setfacl -R -d -m u:deployer:rwx /var/www/qa-tripcart
# WHY: New files inside will inherit user:deployer:rwx

- name: Set default ACL for www-data
  acl:
    path: "{{ laravel_project_path }}"
    entry: "default:group:{{ web_user }}:rwx"
    state: present
    recursive: yes
# WHAT: setfacl -R -d -m g:www-data:rwx /var/www/qa-tripcart
# WHY: New files inherit named group entry for www-data

- name: Set default base group ACL
  acl:
    path: "{{ laravel_project_path }}"
    entry: "default:group::rwx"
    state: present
    recursive: yes
# WHAT: setfacl -R -d -m g::rwx /var/www/qa-tripcart
# WHY: THE KEY FIX — new files get group::rwx for owning group

- name: Set default ACL mask
  acl:
    path: "{{ laravel_project_path }}"
    entry: "default:mask::rwx"
    state: present
    recursive: yes
# WHAT: setfacl -R -d -m m::rwx /var/www/qa-tripcart
# WHY: Mask ceiling doesn't reduce effective permissions
```

### 4. artisan.yml — Post-Command Cleanup

```yaml
- name: Fix permissions after artisan command
  shell: |
    chown -R deployer:www-data {{ laravel_project_path }}/{{ item }}
    find {{ laravel_project_path }}/{{ item }} -type d -exec chmod 2775 {} \;
    find {{ laravel_project_path }}/{{ item }} -type f -exec chmod 664 {} \;
  loop: "{{ laravel_writable_dirs }}"
# WHY: artisan commands (as deployer) might create files with wrong ownership
#      or permissions if umask isn't set in the current session
```

### 5. security/defaults — Sudo umask

```yaml
security_sudoers_configs:
  - name: "deployer-umask"
    priority: "15"
    content: "Defaults:deployer umask=0002"
# Creates: /etc/sudoers.d/15-deployer-umask
# Contains: Defaults:deployer umask=0002
# WHY: When gocd runs "sudo -u deployer", the umask is preserved
```

## The laravel_writable_dirs Variable

Single source of truth for all writable directories:

```yaml
# In roles/laravel/defaults/main.yml
laravel_writable_dirs:
  - storage
  - bootstrap/cache
  - public/sitemap
  - public/uploads
```

Used in:
- `permissions.yml` → ensure dirs exist with correct ownership
- `acl.yml` → set base group ACL on writable dirs
- `artisan.yml` → fix permissions after artisan commands

**To add a new writable directory, just add it to this list.** All tasks pick it up automatically.

## Testing After Deployment

```bash
# 1. Check umask
sudo -u deployer bash -c 'umask'
# Expected: 0002

# 2. Check ownership
ls -la /var/www/qa-tripcart/storage/
# Expected: deployer www-data on everything

# 3. Check setgid
stat -c "%a" /var/www/qa-tripcart/storage/
# Expected: 2775

# 4. Check ACLs
getfacl /var/www/qa-tripcart/storage/
# Expected:
# user::rwx
# user:deployer:rwx
# group::rwx          ← THIS IS KEY
# group:www-data:rwx
# mask::rwx
# other::r-x
# default:user::rwx
# default:user:deployer:rwx
# default:group::rwx  ← THIS IS KEY
# default:group:www-data:rwx
# default:mask::rwx
# default:other::r-x

# 5. Create test file as deployer
sudo -u deployer bash -c 'umask 002; echo "test" > /var/www/qa-tripcart/storage/test-perms.txt'
ls -la /var/www/qa-tripcart/storage/test-perms.txt
# Expected: deployer:www-data, mode includes group write
getfacl /var/www/qa-tripcart/storage/test-perms.txt
# Expected: group::rw-

# 6. Verify www-data can write
sudo -u www-data sh -c 'echo "www-data wrote this" >> /var/www/qa-tripcart/storage/test-perms.txt'
# Expected: SUCCESS (no permission denied)

# 7. Cleanup
sudo rm /var/www/qa-tripcart/storage/test-perms.txt
```

---

## Practice Exercises

### Exercise 1: Write an Ansible Task
Write an Ansible task that:
- Creates `/var/www/myapp/storage/logs`
- Owned by `deployer:www-data`
- Mode `2775`
- Has ACL `default:group::rwx`

```yaml
# Your answer:
- name: Create logs directory
  file:
    path: /var/www/myapp/storage/logs
    state: directory
    owner: deployer
    group: www-data
    mode: '2775'

- name: Set default base group ACL
  acl:
    path: /var/www/myapp/storage/logs
    entry: "default:group::rwx"
    state: present

- name: Set base group ACL on existing
  shell: setfacl -m g::rwx /var/www/myapp/storage/logs
```

### Exercise 2: Diagnose From getfacl Output
Given this output, explain why www-data can't write:

```
# file: var/www/app/public/sitemap/agency/sitemap.xml
# owner: deployer
# group: www-data
user::rw-
group::r--
group:developers:r-x
mask::rw-
other::r--
```

Answer:
```
1. www-data is the owning group
2. Owning group uses group::r-- (read only)
3. Even though mask is rw-, the base entry r-- is the limiter
4. Fix: setfacl -m g::rw /var/www/app/public/sitemap/agency/sitemap.xml
```

### Exercise 3: Design a Permission Model
You have a new app with:
- Deploy user: `release`
- Web server: `apache` (like www-data but for Apache)
- Writable dirs: `storage/`, `cache/`, `uploads/`

Write the complete permission setup commands:

```bash
# Your answer:
# 1. Add release to apache group
sudo usermod -aG apache release

# 2. Set umask
echo "umask 002" >> /home/release/.bashrc

# 3. Set ownership and setgid
sudo chown -R release:apache /var/www/myapp
sudo find /var/www/myapp -type d -exec chmod 2775 {} \;
sudo find /var/www/myapp -type f -exec chmod 664 {} \;

# 4. Set ACLs
for dir in storage cache uploads; do
  sudo setfacl -R -m g::rwx /var/www/myapp/$dir
  sudo find /var/www/myapp/$dir -type f -exec setfacl -m g::rw {} \;
  sudo setfacl -R -d -m g::rwx /var/www/myapp/$dir
  sudo setfacl -R -d -m m::rwx /var/www/myapp/$dir
done
```

### Exercise 4: Teaching Exercise
Explain to a junior developer why this command doesn't work:

```bash
chmod 664 /var/www/app/storage/logs/laravel.log
# www-data still can't write!
```

Your explanation:
```
The file has ACLs. When ACLs exist, chmod changes the MASK, not the
base group entry. The base group entry (group::r--) is what the owning
group (www-data) uses for access. To fix the base group entry, you need:

  setfacl -m g::rw /var/www/app/storage/logs/laravel.log

This changes group:: from r-- to rw-, and now www-data (as owning group)
can write.
```

---

## Summary: The 6 Concepts You Mastered

| Day | Concept | One-Liner |
|-----|---------|-----------|
| 1 | Basic Permissions | `rwx` = read/write/execute, `chmod 664` sets rw-rw-r-- |
| 2 | Ownership | `chown deployer:www-data` sets who owns the file |
| 3 | Umask | `umask 002` makes new files group-writable by default |
| 4 | setgid | `chmod 2775` makes new files inherit the directory's group |
| 5 | ACLs | `setfacl -m g::rwx` sets the real group permission that chmod can't |
| 6 | Debugging | WHO + WHAT + CURRENT + WHY + FIX = solved |
| 7 | Automation | Ansible ties all 6 layers together, runs on every deployment |

## You Can Now Teach This

When someone asks "why can't PHP write to this file?", you know to check:

```
1. Is www-data in the file's group?              → chown / usermod -aG
2. Does the group have write permission?          → ls -la
3. Is umask creating files without group write?   → umask
4. Is setgid making files inherit the right group? → chmod 2775
5. Is the ACL base group entry writable?          → getfacl → setfacl -m g::rw
6. Is the ACL mask reducing effective permissions? → setfacl -m m::rwx
```

If the answer to ANY of these is "no", that's your bug.
