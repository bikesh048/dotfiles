# Shell Aliases

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
| `ll` | `ls -la` | List with details |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
