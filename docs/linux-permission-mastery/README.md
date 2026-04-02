# Linux Permissions Mastery — 7-Day Study Plan

A hands-on guide to mastering Linux file permissions, from basics to ACL debugging. Built from real production bugs in the Tripcart infrastructure.

## Schedule

| Day | Topic | Time | File |
|-----|-------|------|------|
| **1** | Permission Basics | 45 min | [day-1-basics.md](day-1-basics.md) |
| **2** | Ownership (chown, groups) | 45 min | [day-2-ownership-chown-chgrp.md](day-2-ownership-chown-chgrp.md) |
| **3** | Umask | 30 min | [day-3-umask.md](day-3-umask.md) |
| **4** | setgid, setuid, Sticky Bit | 45 min | [day-4-setgid-sticky-bit.md](day-4-setgid-sticky-bit.md) |
| **5** | ACLs (Access Control Lists) | 60 min | [day-5-acl.md](day-5-acl.md) |
| **6** | Real-World Debugging | 60 min | [day-6-real-world-debugging.md](day-6-real-world-debugging.md) |
| **7** | Ansible Automation | 45 min | [day-7-ansible-automation.md](day-7-ansible-automation.md) |

## How to Study

1. Read the concept section first (don't skip the examples)
2. Do EVERY practice exercise on a real Linux server (use staging or a VM)
3. After each day, try to explain the concept to someone (or write it down)
4. Day 6 ties everything together — spend extra time here
5. Day 7 shows how Ansible automates what you learned

## Prerequisites

- SSH access to a Linux server (Ubuntu recommended)
- Basic terminal knowledge (cd, ls, cat, echo)
- sudo access for practice exercises

## After Completing

You will be able to:
- Read any `ls -la` output and understand who can do what
- Debug any "Permission denied" error in under 5 minutes
- Explain the difference between chmod and setfacl (and when each fails)
- Design a permission model for any web application deployment
- Teach these concepts to other developers

