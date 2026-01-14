# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Target | Description |
|---------|--------|-------------|
| `nvim` | `~/.config/nvim` | Neovim configuration (Lazy.nvim) |
| `zsh` | `~/.zshrc` | Zsh config with Zinit + Powerlevel10k |
| `wezterm` | `~/.config/wezterm` | WezTerm terminal config |
| `zellij` | `~/.config/zellij` | Zellij terminal multiplexer |
| `tmux` | `~/.tmux.conf` | Tmux configuration |

## Installation

### Install Stow

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow
```

### Stow Packages

```bash
cd ~/dotfiles

stow nvim     # creates ~/.config/nvim
stow zsh      # creates ~/.zshrc
stow wezterm  # creates ~/.config/wezterm
stow zellij   # creates ~/.config/zellij
stow tmux     # creates ~/.tmux.conf
```

### Unstow

```bash
stow -D nvim  # removes symlinks
```
