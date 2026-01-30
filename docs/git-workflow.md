# Git Workflow in Neovim

Complete guide to all git integrations in your Neovim setup.

## Overview

Your setup includes:
- ✅ **GitSigns** - Inline git operations, blame, staging hunks
- ✅ **Fugitive** - Full git command interface
- ✅ **Diffview** - Visual diff viewer and file history
- ✅ **Lazygit** - Interactive TUI git client
- ✅ **Telescope** - Search commits and file history
- ✅ **Advanced Git Search** - Search through git history
- ✅ **Forgit** - FZF-based git commands (shell)

---

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [GitSigns - Inline Git Operations](#gitsigns---inline-git-operations)
3. [Git Blame](#git-blame)
4. [Diffview - Visual Diffs](#diffview---visual-diffs)
5. [Lazygit - Full Git UI](#lazygit---full-git-ui)
6. [Fugitive - Git Commands](#fugitive---git-commands)
7. [Telescope - Search Git History](#telescope---search-git-history)
8. [Advanced Git Search](#advanced-git-search)
9. [Complete Workflows](#complete-workflows)

---

## Quick Reference

### Most Used Commands

| Keymap | Action | Tool |
|--------|--------|------|
| `<leader>gg` | Open Lazygit | Lazygit |
| `<leader>gs` | Git status | Fugitive |
| `<leader>gd` | Show diff | Diffview |
| `<leader>gh` | File history | Diffview |
| `<leader>hb` | Blame line | GitSigns |
| `<leader>htb` | Toggle inline blame | GitSigns |
| `]c` / `[c` | Next/prev change | GitSigns |
| `<leader>gc` | Search commits | Telescope |
| `<leader>fi` | Advanced git search | AdvancedGitSearch |

---

## GitSigns - Inline Git Operations

**Plugin:** `lewis6991/gitsigns.nvim`
**Purpose:** Show git changes, stage hunks, navigate changes

### Features

**Visual indicators:**
- Green `+` - Added lines
- Blue `~` - Modified lines
- Red `-` - Deleted lines

### Navigation

| Keymap | Action |
|--------|--------|
| `]c` | Jump to next change (hunk) |
| `[c` | Jump to previous change (hunk) |

**Usage:**
```vim
" In a modified file:
]c    → Jump to next change
[c    → Jump back
```

### Staging & Resetting

| Keymap | Action |
|--------|--------|
| `<leader>hs` | Stage hunk under cursor |
| `<leader>hr` | Reset hunk (discard changes) |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hu` | Undo stage hunk |

**Visual mode:**
- Select lines → `<leader>hs` - Stage selection
- Select lines → `<leader>hr` - Reset selection

**Workflow:**
```vim
" 1. Make changes to file
" 2. Navigate to change
]c

" 3. Preview change
<leader>hp

" 4. Stage if good
<leader>hs

" 5. Or discard if bad
<leader>hr
```

### Preview & Diff

| Keymap | Action |
|--------|--------|
| `<leader>hp` | Preview hunk (show change in popup) |
| `<leader>hd` | Diff this file |
| `<leader>hD` | Diff this file (alternate) |
| `<leader>htd` | Toggle deleted lines view |

### Text Objects

| Keymap | Action |
|--------|--------|
| `ih` | Select hunk (use in visual/operator mode) |

**Examples:**
```vim
vih    → Select hunk
dih    → Delete hunk
yih    → Yank hunk
```

---

## Git Blame

### 1. Blame Current Line (`<leader>hb`)

**Keymap:** `Space + h + b`

Shows popup with:
- Author name and email
- Commit hash
- Commit date
- Full commit message

**Example:**
```
Cursor on line → Space + h + b

Popup shows:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
John Doe <john@example.com>
2 days ago (Tue Jan 28 2025)

abc1234 fix: update authentication

This commit fixes the OAuth flow
by adding proper token validation.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. Toggle Inline Blame (`<leader>htb`)

**Keymap:** `Space + h + t + b`

Shows blame info at end of every line as you navigate.

**Example:**
```php
// Before toggle
public function test() {
    return true;
}

// After toggle
public function test() {                    John Doe, 2d ago • fix: update logic
    return true;                             Jane Smith, 1w ago • add return
}
```

**Great for:** Code review, understanding who wrote what

### 3. Fugitive Blame (Full File)

**Command:** `:Git blame`

Opens split view with:
- Blame info for every line
- Press `Enter` on line to see full commit
- Press `o` to open commit in split
- Press `q` to close

**Navigation in blame view:**
- `j/k` - Move up/down
- `Enter` - Show commit details
- `o` - Open commit in split
- `-` - Reblame at previous commit

---

## Diffview - Visual Diffs

**Plugin:** `sindrets/diffview.nvim`
**Purpose:** Beautiful diff viewer and file history

### Commands

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gd` | `:DiffviewOpen` | Show all changes in project |
| `<leader>gh` | `:DiffviewFileHistory %` | Show history for current file |
| `<leader>gH` | `:DiffviewFileHistory` | Show branch history |
| `<leader>gq` | `:DiffviewClose` | Close diffview |

### 1. View Changes (`<leader>gd`)

**Usage:** `Space + g + d`

Shows side-by-side diff of all modified files.

**Layout:**
```
┌─────────────┬─────────────┐
│ File List   │ Diff View   │
│             │             │
│ ▸ modified  │ - old code  │
│   file1.php │ + new code  │
│   file2.js  │             │
│   file3.lua │             │
└─────────────┴─────────────┘
```

**Navigation:**
- `j/k` - Navigate files in left panel
- `Enter` - Open file's diff
- `]c` / `[c` - Next/prev change in diff
- `<leader>gq` - Close diffview

### 2. File History (`<leader>gh`)

**Usage:** `Space + g + h`

Shows commit history for current file.

**Features:**
- See all commits that touched this file
- View each commit's changes
- Navigate through history

**Layout:**
```
┌─────────────┬─────────────┐
│ Commits     │ Changes     │
│             │             │
│ abc1234     │ - old code  │
│ fix: auth   │ + new code  │
│             │             │
│ def5678     │             │
│ add login   │             │
└─────────────┴─────────────┘
```

**Navigation:**
- `j/k` - Move through commits
- `Enter` - View commit changes
- `<Tab>` - Toggle between panels
- `<leader>gq` - Close

### 3. Branch History (`<leader>gH`)

**Usage:** `Space + g + Shift+h`

Shows all commits in branch with files changed.

**Use case:** Review entire branch before merge

---

## Lazygit - Full Git UI

**Plugin:** Floaterm integration
**Keymap:** `<leader>gg` (Space + g + g)

Opens full-screen interactive git interface.

### Features

- ✅ Visual git status
- ✅ Stage/unstage files
- ✅ Commit with editor
- ✅ Push/pull
- ✅ Branch management
- ✅ Merge conflicts
- ✅ Stash management
- ✅ Rebase interactive
- ✅ View logs/diffs

### Navigation in Lazygit

| Key | Panel |
|-----|-------|
| `1` | Status (files) |
| `2` | Branches |
| `3` | Commits |
| `4` | Stash |
| `5` | Files |

**Within panels:**
- `j/k` or `↑/↓` - Navigate
- `Enter` - View details
- `Space` - Stage/unstage
- `a` - Stage all
- `c` - Commit
- `P` - Push
- `p` - Pull
- `d` - Delete/discard
- `?` - Help menu
- `q` - Quit

### Common Workflows

**1. Stage and commit:**
```
Space + g + g    → Open lazygit
Space            → Stage file
c                → Commit
Type message → Enter
P                → Push
```

**2. Branch management:**
```
Space + g + g    → Open lazygit
2                → Branches panel
n                → New branch
c                → Checkout branch
```

**3. View history:**
```
Space + g + g    → Open lazygit
3                → Commits panel
Enter            → View commit
```

---

## Fugitive - Git Commands

**Plugin:** `tpope/vim-fugitive`
**Purpose:** Run git commands from Neovim

### Main Commands

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gs` | `:Git` | Git status window |
| - | `:Git commit` | Commit staged changes |
| - | `:Git push` | Push to remote |
| - | `:Git pull` | Pull from remote |
| - | `:Git blame` | Full file blame |
| - | `:Git log` | View commit log |

### Git Status Window (`<leader>gs`)

**Usage:** `Space + g + s`

Opens interactive status panel.

**In status window:**
- `s` - Stage file under cursor
- `u` - Unstage file
- `-` - Stage/unstage toggle
- `=` - Show inline diff
- `cc` - Commit (opens commit message editor)
- `ca` - Amend last commit
- `dd` - Show full diff
- `Enter` - Open file
- `dv` - Diff in vertical split
- `q` - Close

**Workflow:**
```vim
" 1. Open status
Space + g + s

" 2. Stage files
Move to file → press s

" 3. Commit
cc → Type message → :wq

" 4. Push
:Git push
```

### Other Fugitive Commands

```vim
:Git diff              " Show unstaged changes
:Git diff --staged     " Show staged changes
:Git log               " View commit history
:Git blame             " Full file blame (alternative to GitSigns)
:Git checkout <branch> " Switch branch
:Git merge <branch>    " Merge branch
:Git rebase <branch>   " Rebase onto branch
```

---

## Telescope - Search Git History

### Search Commits

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gc` | `:Telescope git_commits` | Search all commits |
| `<leader>gb` | `:Telescope git_bcommits` | Search commits for current file |

### Usage

**1. Search All Commits (`<leader>gc`)**

```vim
Space + g + c
Type: "fix auth"
```

Shows commits matching search:
```
abc1234 fix: authentication bug
def5678 fix: auth token validation
```

**Actions:**
- `Enter` - View commit diff
- `Ctrl-q` - Send to quickfix
- `Ctrl-v` - Open in vsplit

**2. Search File Commits (`<leader>gb`)**

```vim
" In a file
Space + g + b
Type: "refactor"
```

Shows commits that modified current file.

---

## Advanced Git Search

**Plugin:** `aaronhallaert/advanced-git-search.nvim`
**Keymap:** `<leader>fi` (Space + f + i)

### Features

Opens menu with options:

1. **Search log** - Find commits by message
2. **Search log for word** - Find when code was added/removed
3. **Diff commit** - View specific commit
4. **Diff commit file** - View how file changed in commit
5. **Diff branch file** - Compare file across branches
6. **Changed files on branch** - See all modified files

### Common Use Cases

**Use Case 1: When was this bug introduced?**

```vim
Space + f + i
Select: "Search log for word"
Type: function name or code snippet
Browse commits that touched it
```

**Use Case 2: Compare file across branches**

```vim
Space + f + i
Select: "Diff branch file"
Select branch: main
See what changed in this file
```

**Use Case 3: View specific commit**

```vim
Space + f + i
Select: "Diff commit"
Type/select commit hash
See full commit changes
```

---

## Complete Workflows

### Workflow 1: Review Before Commit

```vim
" 1. See what changed
Space + g + d          " Diffview all changes

" 2. Navigate files
j/k → Enter            " Open file diffs

" 3. Check blame for context
Space + h + b          " Who wrote this?

" 4. Stage good changes
Space + g + s          " Fugitive status
s                      " Stage files

" 5. Commit via lazygit
Space + g + g
c                      " Commit
Type message
P                      " Push
```

### Workflow 2: Code Review

```vim
" 1. See branch changes
Space + g + Shift+h    " Branch history

" 2. Enable inline blame
Space + h + t + b      " See who wrote what

" 3. Navigate changes
]c / [c                " Jump between changes

" 4. Check commit context
Space + g + c          " Search commits
Type author/message

" 5. Review specific commits
Space + f + i          " Advanced search
Select commit → view
```

### Workflow 3: Debug - When Was This Added?

```vim
" 1. Find when code appeared
Space + f + i
Select: "Search log for word"
Type: buggy_function

" 2. View commit that added it
Select commit → Enter

" 3. See full file history
Space + g + h          " File history

" 4. Check blame
Space + h + b          " Blame line
```

### Workflow 4: Feature Branch Work

```vim
" 1. Create branch in lazygit
Space + g + g
2                      " Branches
n                      " New branch

" 2. Make changes...

" 3. View what changed
Space + g + d          " See all diffs

" 4. Stage selectively
]c                     " Next change
Space + h + s          " Stage hunk
OR
Space + g + s          " Fugitive status
s                      " Stage files

" 5. Commit & push
Space + g + g
c → P                  " Commit & push
```

### Workflow 5: Fix Merge Conflicts

```vim
" 1. See conflicts
Space + g + g          " Lazygit
OR
Space + g + s          " Fugitive

" 2. Open conflicted file
Navigate → Enter

" 3. Resolve conflicts
Edit file manually
(Future: will show conflict markers)

" 4. Stage resolved
Space + g + s
s                      " Stage

" 5. Continue merge
:Git merge --continue
```

---

## Cheat Sheet

### Quick Actions

```vim
" Stage & Commit
Space + g + g          → Lazygit (full UI)
Space + g + s          → Fugitive status
Space + h + s          → Stage hunk

" View Changes
Space + g + d          → Diffview changes
Space + h + p          → Preview hunk
]c / [c                → Navigate changes

" Blame
Space + h + b          → Blame line
Space + h + t + b      → Toggle inline blame
:Git blame             → Full file blame

" History
Space + g + h          → File history
Space + g + c          → Search commits
Space + f + i          → Advanced search

" Diff
Space + g + d          → Diffview
Space + h + d          → GitSigns diff
Space + g + q          → Close diffview
```

### Tool Selection Guide

| Need | Use | Keymap |
|------|-----|--------|
| Quick status & commit | Lazygit | `<leader>gg` |
| Stage hunks | GitSigns | `<leader>hs` |
| View diffs | Diffview | `<leader>gd` |
| File history | Diffview | `<leader>gh` |
| Blame line | GitSigns | `<leader>hb` |
| Full blame | Fugitive | `:Git blame` |
| Search commits | Telescope | `<leader>gc` |
| Debug history | Advanced Search | `<leader>fi` |
| Git commands | Fugitive | `:Git <cmd>` |

---

## Configuration Files

- **GitSigns:** `nvim/.config/nvim/lua/plugins/gitsigns.lua`
- **Diffview:** `nvim/.config/nvim/lua/plugins/diffview.lua`
- **Fugitive:** `nvim/.config/nvim/lua/plugins.lua:65-72`
- **Lazygit:** `nvim/.config/nvim/lua/core/keymaps.lua:235`
- **Telescope Git:** `nvim/.config/nvim/lua/plugins/telescope.lua:34-38`

---

## Troubleshooting

### Issue: GitSigns not showing

**Check if in git repo:**
```bash
git status
```

**Restart GitSigns:**
```vim
:Gitsigns refresh
```

### Issue: Lazygit not opening

**Check if installed:**
```bash
which lazygit
lazygit --version
```

**Install if missing:**
```bash
brew install lazygit
```

### Issue: Diffview not showing changes

**Check git status first:**
```bash
git status
```

**Restart Neovim** if no changes detected.

### Issue: Fugitive commands not working

**Check plugin loaded:**
```vim
:scriptnames | grep fugitive
```

**Should see:** `.../vim-fugitive/plugin/fugitive.vim`

---

## Tips & Tricks

### 1. Stage hunks visually

```vim
" Select lines in visual mode
V
jjj
Space + h + s    " Stage only selected lines
```

### 2. Compare with other branch

```vim
:Git diff main..feature-branch
```

### 3. Interactive rebase (Lazygit)

```vim
Space + g + g
3                " Commits panel
e                " Edit commit (reword)
s                " Squash commits
d                " Drop commit
```

### 4. Stash workflow

```vim
Space + g + g
4                " Stash panel
s                " Stash changes
Space            " Apply stash
d                " Drop stash
```

### 5. View commit under cursor

In Lazygit or Fugitive log:
```vim
Enter    " View commit details
```

---

## Related Documentation

- [Neovim Keymaps](./nvim-keymaps.md) - All keybindings
- [Telescope Guide](./telescope-guide.md) - Search features
- [Shell Aliases](./shell-aliases.md) - Git aliases in shell

---

## External Resources

- [Lazygit Docs](https://github.com/jesseduffield/lazygit)
- [Fugitive Help](https://github.com/tpope/vim-fugitive) - `:help fugitive`
- [GitSigns Help](https://github.com/lewis6991/gitsigns.nvim) - `:help gitsigns`
- [Diffview Help](https://github.com/sindrets/diffview.nvim) - `:help diffview`
