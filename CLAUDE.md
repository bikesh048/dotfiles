# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for macOS managed with GNU Stow. Provides a complete development environment for DevOps/cloud infrastructure work and full-stack development.

## Installation

```bash
brew install stow
cd ~/dotfiles
stow nvim zsh wezterm zellij
```

Required dependencies:
```bash
brew install neovim stow fzf ripgrep lazygit zoxide yamllint ansible-lint
```

## Architecture

### Stow Packages

Each top-level directory is a stow package that symlinks to the home directory:
- `nvim/` → `~/.config/nvim`
- `zsh/` → `~/.zshrc`
- `wezterm/` → `~/.config/wezterm`
- `zellij/` → `~/.config/zellij`

### Neovim Structure

Entry point: `nvim/.config/nvim/init.lua`

```
lua/
├── core/
│   ├── globals.lua    # Leader key (Space)
│   ├── keymaps.lua    # All keybindings
│   └── options.lua    # Vim options + autocmds
├── config/
│   └── lazy.lua       # Lazy.nvim bootstrap
└── plugins/           # One file per plugin
    ├── lsp.lua        # LSP configuration
    ├── mason.lua      # Tool installer
    ├── conform.lua    # Code formatting
    ├── lint.lua       # Linting setup
    └── ...
```

**Key behaviors:**
- Auto-save on insert mode leave (`InsertLeave` autocmd)
- Virtual text diagnostics disabled (uses underlines + gutter signs)
- Ansible files detected by path patterns (`*/playbooks/*`, `*/roles/*`, etc.)

### Shell Configuration

`zsh/.zshrc` uses Zinit plugin manager with:
- Powerlevel10k prompt
- zsh-vi-mode (Vi keybindings)
- fzf-tab (fuzzy completions)
- zsh-completions (extra completions for 200+ tools)
- forgit (interactive git with fzf)
- zoxide (smart directory jumping)
- DevOps aliases for k8s, terraform, docker, git

## LSP & Tooling

**Language servers** (installed via Mason):
- TypeScript: `ts_ls` with auto-import
- YAML: `yamlls` with schema validation (k8s, GitHub Actions, Docker Compose)
- Ansible: `ansiblels` with custom filetype detection
- Terraform: `terraformls`
- Docker: `dockerls`, `docker_compose_language_service`

**Formatters** (via Conform):
- JS/TS: prettier
- Lua: stylua
- Shell: beautysh
- YAML: prettier

**Linters** (via nvim-lint):
- JS/TS: eslint_d
- YAML: yamllint
- Ansible: ansible_lint

## Key Neovim Commands

```vim
:Mason              " Manage LSP/formatters/linters
:LspInfo            " Show active LSPs
:ConformInfo        " Show formatter for current file
:Lazy               " Plugin manager
```

## Documentation

Detailed documentation in `docs/`:
- `nvim-keymaps.md` - Complete keymap reference
- `shell-aliases.md` - DevOps alias documentation
- `lsp-tools.md` - Language servers, formatters, linters
