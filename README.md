# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Target | Description |
|---------|--------|-------------|
| `nvim` | `~/.config/nvim` | Neovim config (Lazy.nvim, LSP, Treesitter) |
| `zsh` | `~/.zshrc` | Zsh with Zinit, fzf, zoxide + DevOps aliases |
| `wezterm` | `~/.config/wezterm` | WezTerm terminal config |
| `zellij` | `~/.config/zellij` | Zellij terminal multiplexer |
| `claude` | `~/.claude/*` | Personal Claude Code config (agents, commands, skills, hooks, scripts) |

## Quick Start

```bash
# Install stow
brew install stow

# Clone and stow
git clone <repo> ~/dotfiles
cd ~/dotfiles
stow --no-folding nvim zsh wezterm zellij claude
```

### Claude Code

Personal Claude Code config complements the team config from [TripcartHQ/claude-config](https://github.com/TripcartHQ/claude-config).

**Install order** (team config wins on conflicts):
```bash
# 1. Team config first
cd ~/projects/claude-config && ./install.sh --global --machine=mac

# 2. Personal config on top (--no-folding = file-level symlinks)
cd ~/dotfiles && stow --no-folding claude
```

Includes: 14 agents, 58 commands, 26 skills, 8 language rule sets, hooks, scripts, statusline.

## Key Features

### Neovim
- **LSP**: TypeScript, PHP, ESLint, Terraform, Docker, YAML, Ansible
- **Formatting**: Prettier, PHP-CS-Fixer, Stylua, Beautysh
- **Linting**: ESLint, PHPCS, Yamllint, Ansible-lint
- **Plugins**: Telescope, Harpoon, Oil, Fugitive, Trouble

### Shell Aliases
```bash
# Kubernetes
k, kgp, kgs, kga, kd, kl, kx, kns, kctx

# Terraform
tf, tfi, tfp, tfa, tfd, tff, tfv

# Docker
d, dc, dps, dex, dl, dprune

# Git
g, ga, gc, gp, gl, gst, gd, gco, glog
```

## Documentation

- [Neovim Keymaps](docs/nvim-keymaps.md) - Complete keymap reference
- [Telescope Guide](docs/telescope-guide.md) - Search, find & replace, extensions
- [Git Workflow](docs/git-workflow.md) - Git operations, blame, diffview, lazygit
- [PHP Setup](docs/php-setup.md) - PHP development setup and navigation
- [Shell Aliases](docs/shell-aliases.md) - DevOps aliases
- [LSP & Tools](docs/lsp-tools.md) - Language servers, formatters, linters

## Requirements

```bash
brew install neovim stow fzf ripgrep lazygit zoxide
brew install bat eza delta fd tldr direnv lazydocker
brew install yamllint ansible-lint  # For YAML/Ansible linting
```
