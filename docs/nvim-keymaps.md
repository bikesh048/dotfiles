# Neovim Keymaps

Leader key: `<Space>`

## General

| Keymap | Description |
|--------|-------------|
| `<leader><leader>` | Source current file |
| `<leader>q` | Close buffer |
| `<leader>w` | Close buffer, retain split |
| `<leader>x` | Make file executable |
| `-` | Open Oil file explorer |
| `df` | Exit insert mode (alternative to Esc) |
| `Y` | Yank to end of line |
| `==` | Select all |

## LSP

| Keymap | Description |
|--------|-------------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>vca` | Code action |
| `<leader>vrr` | References |
| `<leader>vd` | Open diagnostic float |
| `<leader>li` | Auto import (TypeScript) |
| `<leader>la` | Apply quickfix |
| `<leader>lw` | Workspace diagnostics |
| `[d` / `]d` | Next/prev diagnostic |
| `<C-h>` | Signature help (insert mode) |

## Formatting & Linting

| Keymap | Description |
|--------|-------------|
| `<leader>l` | Format file/selection |
| `<leader>ll` | Trigger linting |

## Git

| Keymap | Description |
|--------|-------------|
| `<leader>gs` | Git status (Fugitive) |
| `<leader>gg` | Open Lazygit |

## Trouble (Diagnostics)

| Keymap | Description |
|--------|-------------|
| `<leader>xx` | Toggle all diagnostics |
| `<leader>xX` | Toggle buffer diagnostics |
| `<leader>xl` | Toggle location list |
| `<leader>xq` | Toggle quickfix list |

## Navigation

| Keymap | Description |
|--------|-------------|
| `<C-j>` | Previous buffer |
| `<C-k>` | Next buffer |
| `<leader>h` | Next quickfix item |
| `<leader>;` | Previous quickfix item |
| `<S-h>` | Jump to beginning of line |
| `<S-l>` | Jump to end of line |

## Telescope

| Keymap | Description |
|--------|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |

## Visual Mode

| Keymap | Description |
|--------|-------------|
| `J` | Move block down |
| `K` | Move block up |
| `<` / `>` | Indent and stay in visual |
| `p` | Paste without overwriting register |
| `//` | Search highlighted text |

## Copy/Yank

| Keymap | Description |
|--------|-------------|
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to system clipboard |
| `<leader>d` | Delete to void register |
| `<leader>cf` | Copy filename |
| `<leader>cp` | Copy full path |

## Tests (Neotest)

| Keymap | Description |
|--------|-------------|
| `<leader>t` | Run test |
| `<leader>tf` | Run test file |
| `<leader>td` | Run test directory |
| `<leader>tl` | Run last test |
| `<leader>ts` | Toggle test summary |
| `<leader>tp` | Toggle test output panel |

## Window Management

| Keymap | Description |
|--------|-------------|
| `<C-S-Up>` | Resize horizontal split up |
| `<C-S-Down>` | Resize horizontal split down |
| `<C-Left>` | Resize vertical split left |
| `<C-Right>` | Resize vertical split right |

## Terminal

| Keymap | Description |
|--------|-------------|
| `<C-t>` | Exit terminal mode |
| `<leader>tc` | Run TypeScript check |
