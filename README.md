# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Target | Description |
|---------|--------|-------------|
| `nvim` | `~/.config/nvim` | Neovim config (Lazy.nvim, LSP, Treesitter) |
| `zsh` | `~/.zshrc` | Zsh with Zinit, fzf, zoxide + DevOps aliases |
| `wezterm` | `~/.config/wezterm` | WezTerm terminal config |
| `zellij` | `~/.config/zellij` | Zellij terminal multiplexer |

## Quick Start

```bash
# Install stow
brew install stow

# Clone and stow
git clone <repo> ~/dotfiles
cd ~/dotfiles
stow nvim zsh wezterm zellij
```

## Key Features

### Neovim
- **LSP**: TypeScript, ESLint, Terraform, Docker, YAML, Ansible
- **Formatting**: Prettier, Stylua, Beautysh
- **Linting**: ESLint, Yamllint, Ansible-lint
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
- [Shell Aliases](docs/shell-aliases.md) - DevOps aliases
- [LSP & Tools](docs/lsp-tools.md) - Language servers, formatters, linters

## Requirements

```bash
brew install neovim stow fzf ripgrep lazygit zoxide
brew install bat eza delta fd tldr direnv lazydocker
brew install yamllint ansible-lint  # For YAML/Ansible linting
```
