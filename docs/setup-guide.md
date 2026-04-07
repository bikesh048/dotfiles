# Dotfiles Setup & Workflow Guide

Complete development environment for DevOps/full-stack work on macOS, powered by GNU Stow + oh-my-claudecode.

## Quick Start

```bash
# 1. Clone
git clone git@github.com:bikesh048/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install dependencies
brew install neovim stow fzf ripgrep lazygit zoxide yamllint ansible-lint
brew install bat eza delta fd tldr direnv lazydocker

# 3. Stow packages
stow nvim zsh wezterm zellij

# 4. Claude Code config (personal layer on top of team config)
cd ~/dotfiles && stow --no-folding claude
```

## What's Included

### Shell (Zsh + Zinit)

**Plugin stack:** Powerlevel10k, fzf-tab, zsh-vi-mode, autosuggestions, syntax-highlighting, forgit

**Alias cheatsheet:**

| Category | Aliases |
|----------|---------|
| Kubernetes | `k`, `kgp`, `kgs`, `kgn`, `kga`, `kgaa`, `kgd`, `kaf`, `kdel`, `krr`, `krs`, `ktop`, `kns`, `kctx` |
| Terraform | `tf`, `tfi`, `tfp`, `tfa`, `tfaa`, `tfd`, `tff`, `tfv`, `tfo`, `tfs` |
| Docker | `d`, `dc`, `dcd`, `dps`, `dpsa`, `dex`, `dl`, `dimg`, `dbn`, `dprune` |
| Git | `g`, `ga`, `gc`, `gp`, `gl`, `gst`, `gd`, `gco`, `gsw`, `gb`, `glog`, `gr`, `gm`, `gfa`, `gsta`, `gstp` |
| General | `v` (nvim), `c` (clear), `cat` (bat), `ls` (eza), `ll`, `tree`, `find` (fd), `lzd` |

### Neovim

**LSP servers:** TypeScript, ESLint, Lua, YAML (with k8s/GHA/Ansible schemas), Ansible, Terraform, Docker, Docker Compose, PHP, Python (pyright), Go (gopls)

**Formatters:** prettier, stylua, beautysh, black (Python), goimports + gofmt (Go), buf (protobuf), taplo (TOML)

**Linters:** eslint_d, yamllint, ansible_lint, shellcheck, hadolint (Dockerfile), tflint (Terraform), ruff (Python)

**Key bindings:**
- `Space` = leader
- `gd` = go to definition
- `K` = hover docs
- `<leader>l` = format
- `<leader>ll` = lint
- `<leader>vca` = code actions
- `<leader>vrn` = rename
- `<leader>gg` = lazygit
- `s` = flash jump
- `<leader>a` = harpoon menu

### Claude Code (OMC)

**Orchestration layer:** oh-my-claudecode with multi-agent routing, persistent modes, and keyword-triggered skills.

**Custom slash commands:**
- `/deploy-check` — pre-deployment readiness audit
- `/incident` — incident triage and response template
- `/infra-check` — IaC security and best-practices audit
- `/pr-review` — structured code review

**OMC skills (keyword-triggered):**
- `autopilot` — full autonomous execution
- `ralph` — persistent mode until task completion
- `ultrawork` / `ulw` — maximum parallel execution
- `ultrathink` — extended deep reasoning
- `deepsearch` — comprehensive codebase search
- `tdd` — test-driven development mode
- `deslop` — AI slop cleanup

**Config layering:** Team config from `TripcartHQ/claude-config` (real files) + personal config from `dotfiles/claude/` (symlinks via stow). Team always wins on conflicts.

## Adding a New Stow Package

```bash
# 1. Create directory structure mirroring home
mkdir -p ~/dotfiles/mytool/.config/mytool

# 2. Add config files
cp ~/.config/mytool/config.toml ~/dotfiles/mytool/.config/mytool/

# 3. Stow it
cd ~/dotfiles && stow mytool
```

## Maintenance

```bash
# Update all plugins
nvim --headless "+Lazy sync" +qa    # Neovim plugins
zinit update --all                   # Zsh plugins
brew upgrade                         # CLI tools

# Re-stow after changes
cd ~/dotfiles && stow -R nvim zsh wezterm zellij
```
