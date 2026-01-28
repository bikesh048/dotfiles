# Telescope Guide

Complete reference for Telescope fuzzy finder and all extensions.

## Table of Contents
- [Basic Search](#basic-search)
- [Find & Replace](#find--replace)
- [Git Integration](#git-integration)
- [Extensions](#extensions)
- [Advanced Usage](#advanced-usage)

---

## Basic Search

### Find Files by Name

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>ff` | `:Telescope find_files` | Find files by name (respects .gitignore) |
| `<leader>fo` | `:Telescope oldfiles` | Recently opened files |
| `<leader>fb` | `:Telescope buffers` | Search open buffers |

**Usage:**
1. Press `Space + f + f`
2. Type filename (fuzzy matching: "nvpl" finds "nvim/lua/plugins/...")
3. Press `Enter` to open file

---

### Search Text in Project

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>fg` | `:Telescope live_grep` | Search text across all files |
| `<leader>fc` | `:Telescope live_grep` | Search code (excludes test files) |
| `<leader>fw` | `:Telescope grep_string` | Search word under cursor |
| `<leader>/` | Custom | Fuzzy search in current buffer |

**Usage:**
```
Space + f + g
Type: "function setup"
Results update as you type
```

---

## Find & Replace

### Project-Wide Replace

**Step 1: Search**
```
Space + f + g
Type your search term
```

**Step 2: Send to Quickfix**
- **`Ctrl + q`** - Send ALL results to quickfix
- **`Tab` + `Ctrl + w`** - Select specific files, then send

**Step 3: Replace**
```vim
:cfdo %s/old_text/new_text/g | update
```

### Replace with Confirmation
```vim
:cfdo %s/old/new/gc | update
```
Press `y` (yes), `n` (no), `a` (all), `q` (quit) for each match

### Replace Only in Selected Files
```vim
# 1. In Telescope: Tab to select files
# 2. Ctrl + w to send selected
# 3. Replace:
:cfdo %s/old/new/g | update
```

### Examples

**Example 1: Rename function across project**
```
1. Space + f + g
2. Search: "oldFunctionName"
3. Ctrl + q
4. :cfdo %s/oldFunctionName/newFunctionName/g | update
```

**Example 2: Update import paths**
```
1. Space + f + g
2. Search: from "./old-path"
3. Ctrl + q
4. :cfdo %s/from "\.\/old-path"/from ".\/new-path"/g | update
```

---

## Git Integration

### Search Git History

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>gc` | `:Telescope git_commits` | Search all commits |
| `<leader>gb` | `:Telescope git_bcommits` | Search commits for current file |
| `<leader>fi` | `:AdvancedGitSearch` | Advanced git search (see below) |

### Advanced Git Search

Press `<leader>fi` to open menu:

- **Search log** - Find commits by message
- **Search log for word** - Find when code was added/removed
- **Diff commit** - View specific commit changes
- **Diff branch file** - Compare file across branches
- **Changed files on branch** - See all modified files

**Use Case:** "When was this bug introduced?"
```
1. Space + f + i
2. Select "Search log for word"
3. Type the function/variable name
4. Browse commits that touched it
```

---

## Extensions

### 1. Clipboard History (neoclip)

**Command:** `:Telescope neoclip`

**Add keymap (optional):**
```lua
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope neoclip<CR>", { desc = "Clipboard History" })
```

**Usage:**
- See everything you've yanked/copied
- Paste from history

---

### 2. Undo History

**Command:** `:Telescope undo`

**Add keymap (optional):**
```lua
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<CR>", { desc = "Undo History" })
```

**Usage:**
- Browse all your edits
- Jump back to any previous state
- Search through changes

**In undo window:**
- `Enter` - Restore that state
- `Ctrl + Enter` - Yank additions
- `Shift + Enter` - Yank deletions

---

### 3. Color Picker

**Keymap:** `<leader>uC`
**Command:** `:Telescope colors`

**Usage:**
- Browse installed colorschemes
- Live preview as you navigate
- Press Enter to apply

---

### 4. Find Keymaps

**Keymap:** `<leader>fk`
**Command:** `:Telescope keymaps`

**Usage:**
- Search all configured keybindings
- Type a key sequence to find what it does
- Great for discovering keymaps

---

### 5. Help Tags

**Keymap:** `<leader>fh`
**Command:** `:Telescope help_tags`

**Usage:**
- Search Neovim documentation
- Fuzzy find help topics

---

### 6. LSP Symbols

**Keymap:** `<leader>fs`
**Command:** `:Telescope lsp_document_symbols`

**Usage:**
- Jump to functions/classes in current file
- Quick navigation alternative to file search

---

### 7. Diagnostics

**Keymap:** `<leader>wd`
**Command:** `:Telescope diagnostics`

**Usage:**
- See all errors/warnings across workspace
- Jump to problematic files

---

### 8. Resume Last Search

**Keymap:** `<leader>fr`
**Command:** `:Telescope resume`

**Usage:**
- Reopen your last Telescope search
- Continue where you left off

---

## Advanced Usage

### Telescope Keybindings (Inside Telescope)

**Insert Mode (while searching):**
| Key | Action |
|-----|--------|
| `Ctrl + j` | Next result |
| `Ctrl + k` | Previous result |
| `Ctrl + q` | Send ALL to quickfix |
| `Ctrl + w` | Send SELECTED to quickfix |
| `Ctrl + s` | Next previewer |
| `Ctrl + a` | Previous previewer |
| `Ctrl + Shift + d` | Delete buffer (in buffer search) |
| `Tab` | Select/deselect item |
| `Enter` | Open file |
| `Esc` | Close Telescope |

**Normal Mode (press Esc first):**
| Key | Action |
|-----|--------|
| `j/k` | Navigate results |
| `gg/G` | First/last result |
| `Ctrl + q` | Send ALL to quickfix |
| `Ctrl + w` | Send SELECTED to quickfix |
| `dd` | Delete buffer (in buffer search) |

---

### Quickfix List Commands

After sending to quickfix (`Ctrl + q`):

```vim
:copen          # Open quickfix window
:cclose         # Close quickfix window
:cnext          # Next item (<leader>h)
:cprev          # Previous item (<leader>;)
:cfdo <cmd>     # Run command on each FILE
:cdo <cmd>      # Run command on each LINE
```

---

### Search Tips

**Fuzzy Matching Examples:**
- `nvpl` matches `nvim/lua/plugins/`
- `tlua` matches `telescope.lua`
- `kmp` matches `keymaps.lua`

**Exclude Patterns:**
```
Space + f + g
Type: !test pattern    (excludes files with "test")
```

**Include Hidden Files:**
Already configured! Searches `.config`, `.env`, etc. (but excludes `.git/`)

---

## Configuration Location

- **Telescope config:** `nvim/.config/nvim/lua/plugins/telescope.lua`
- **Keymaps:** `nvim/.config/nvim/lua/core/keymaps.lua`
- **Extensions:** Loaded in `telescope.lua:122-135`

---

## Troubleshooting

### Issue: Telescope slow

**Solution:** Make sure fzf extension is enabled
```vim
:Telescope extensions
# Should see "fzf" in the list
```

### Issue: No results in live_grep

**Check ripgrep:**
```bash
which rg
rg --version
```

### Issue: Extension not loading

**Check if installed:**
```vim
:Lazy
# Search for the extension
```

**Reload plugins:**
```vim
:Lazy sync
```

---

## Quick Reference Card

### Most Used Commands

```
Space + f + f   → Find files
Space + f + g   → Search text (then Ctrl+q for replace)
Space + f + b   → Open buffers
Space + f + w   → Search word under cursor
Space + f + h   → Help docs
Space + f + k   → Find keymaps
Space + f + r   → Resume last search

# In Telescope:
Ctrl + q        → Send all to quickfix
Tab             → Select items
Ctrl + w        → Send selected to quickfix

# Replace:
:cfdo %s/old/new/g | update
```

---

## Next Steps

1. **Try basic search:** `Space + f + g`
2. **Practice find & replace:** Search + `Ctrl + q` + `:cfdo`
3. **Explore extensions:** `:Telescope neoclip`, `:Telescope undo`
4. **Add custom keymaps:** Edit `telescope.lua` to add shortcuts

For more keybindings, see: `docs/nvim-keymaps.md`
