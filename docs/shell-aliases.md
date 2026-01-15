# Shell Aliases & Tools

## Kubernetes

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Main kubectl command |
| `kgp` | `kubectl get pods` | List pods |
| `kgs` | `kubectl get svc` | List services |
| `kgn` | `kubectl get nodes` | List nodes |
| `kga` | `kubectl get all` | List all resources |
| `kgaa` | `kubectl get all -A` | List all resources in all namespaces |
| `kd` | `kubectl describe` | Describe resource |
| `kl` | `kubectl logs -f` | Follow logs |
| `kx` | `kubectl exec -it` | Exec into pod |
| `kns` | `kubectl config set-context --current --namespace` | Set namespace |
| `kctx` | `kubectl config use-context` | Switch context |

### Examples
```bash
kgp                    # Get pods in current namespace
kgp -n production      # Get pods in production namespace
kl my-pod              # Follow logs of my-pod
kx my-pod -- /bin/sh   # Exec into my-pod
kns production         # Switch to production namespace
kctx my-cluster        # Switch to my-cluster context
```

## Terraform

| Alias | Command | Description |
|-------|---------|-------------|
| `tf` | `terraform` | Main terraform command |
| `tfi` | `terraform init` | Initialize |
| `tfp` | `terraform plan` | Plan changes |
| `tfa` | `terraform apply` | Apply changes |
| `tfaa` | `terraform apply -auto-approve` | Apply without confirmation |
| `tfd` | `terraform destroy` | Destroy resources |
| `tff` | `terraform fmt -recursive` | Format all files |
| `tfv` | `terraform validate` | Validate configuration |

### Examples
```bash
tfi                    # Initialize terraform
tfp                    # Show planned changes
tfa                    # Apply with confirmation
tfaa                   # Apply without confirmation (careful!)
tff                    # Format all .tf files recursively
```

## Docker

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Main docker command |
| `dc` | `docker compose` | Docker compose |
| `dps` | `docker ps` | List running containers |
| `dpsa` | `docker ps -a` | List all containers |
| `dex` | `docker exec -it` | Exec into container |
| `dl` | `docker logs -f` | Follow logs |
| `dprune` | `docker system prune -af` | Clean up everything |

### Examples
```bash
dps                         # List running containers
dex my-container /bin/bash  # Exec into container
dl my-container             # Follow container logs
dc up -d                    # Start docker-compose services
dc down                     # Stop docker-compose services
dprune                      # Clean up unused resources
```

## Git

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Main git command |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gst` | `git status` | Show status |
| `gd` | `git diff` | Show diff |
| `gco` | `git checkout` | Checkout branch/files |
| `gb` | `git branch` | List/create branches |
| `glog` | `git log --oneline --graph` | Pretty log |

### Examples
```bash
ga .                   # Stage all changes
gc -m "feat: message"  # Commit with message
gco -b feature/new     # Create and checkout new branch
glog                   # View commit history
```

## General

| Alias | Command | Description |
|-------|---------|-------------|
| `v` | `nvim` | Open Neovim |
| `c` | `clear` | Clear terminal |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |

## Modern CLI Replacements

| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat` | Cat with syntax highlighting |
| `ls` | `eza` | Modern ls with git status |
| `ll` | `eza -la --git` | Detailed list with git status |
| `tree` | `eza --tree` | Tree view |
| `find` | `fd` | Fast, user-friendly find |
| `lzd` | `lazydocker` | Docker TUI |

### Tools Overview

| Tool | What it does |
|------|--------------|
| `bat` | Cat with syntax highlighting, line numbers, git integration |
| `eza` | Modern ls with colors, icons, git status, tree view |
| `delta` | Beautiful git diffs (auto-configured as git pager) |
| `fd` | Fast find alternative with intuitive syntax |
| `tldr` | Simplified man pages with examples |
| `direnv` | Auto-load `.envrc` files when entering directories |
| `lazydocker` | Terminal UI for Docker (like lazygit for containers) |

### Examples
```bash
bat file.txt           # View file with syntax highlighting
ll                     # List files with git status
tree                   # Show directory tree
fd "*.lua"             # Find all lua files
fd -e js -x prettier   # Find js files and run prettier
tldr tar               # Quick examples for tar command
lzd                    # Open lazydocker TUI
```

## Direnv

Auto-loads environment variables from `.envrc` files when you cd into a directory.

```bash
# Create .envrc in project directory
echo 'export API_KEY="xxx"' > .envrc
direnv allow           # Approve the .envrc file

# Now API_KEY is auto-loaded when you enter the directory
```

## Zsh Plugins (Zinit)

| Plugin | Purpose |
|--------|---------|
| `powerlevel10k` | Fast, customizable prompt with git status |
| `fzf-tab` | Fuzzy search in tab completions |
| `zsh-vi-mode` | Vim keybindings in terminal |
| `zsh-autosuggestions` | Ghost text suggestions from history |
| `zsh-completions` | Extra completions for 200+ tools |
| `forgit` | Interactive git commands with fzf |
| `zsh-syntax-highlighting` | Colors commands as you type |

## FZF (Fuzzy Finder)

Interactive fuzzy search for any list.

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Search files, insert path |
| `Alt+C` | Search directories, cd into selected |

### Examples
```bash
fzf                    # Interactive file finder
cat file | fzf         # Fuzzy search through file
v $(fzf)               # Find and open file in nvim
kill $(ps | fzf)       # Interactive process kill
```

## Zoxide (Smart cd)

Tracks your most used directories and lets you jump to them with partial names.

| Command | Action |
|---------|--------|
| `z <query>` | Jump to best matching directory |
| `zi <query>` | Interactive selection with fzf |
| `z -` | Jump to previous directory |

### Examples
```bash
z dotfiles             # Jump to ~/dotfiles (or similar)
z nvim                 # Jump to nvim config directory
zi                     # Interactive directory picker
z proj api             # Jump to directory matching both words
```

## Forgit (Interactive Git)

Git commands with fzf preview. Aliases provided by the plugin:

| Alias | Command | Description |
|-------|---------|-------------|
| `ga` | `forgit::add` | Interactive stage files |
| `glo` | `forgit::log` | Browse commits with preview |
| `gd` | `forgit::diff` | Interactive diff viewer |
| `grh` | `forgit::reset::head` | Interactive unstage |
| `gcf` | `forgit::checkout::file` | Checkout files interactively |
| `gcb` | `forgit::checkout::branch` | Checkout branch interactively |
| `gss` | `forgit::stash::show` | Browse stashes |
| `gclean` | `forgit::clean` | Interactive clean untracked |

### Examples
```bash
glo                    # Browse git log with diff preview
gd                     # Interactive diff viewer
gcb                    # Fuzzy checkout branch
gss                    # Browse and apply stashes
```
