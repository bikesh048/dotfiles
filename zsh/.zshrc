# ==================================
# Powerlevel10k Instant Prompt
# ==================================
# Must stay at the top of .zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==================================
# Environment Variables
# ==================================
export TERM="xterm-256color"
export NVM_DIR="$HOME/.nvm"

# ==================================
# PATH Configuration (consolidated)
# ==================================
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:/opt/homebrew/opt/openjdk/bin:/opt/nvim:$PATH"

# ==================================
# Zinit Plugin Manager
# ==================================
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit \
      "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ==================================
# Zinit Plugins (Order Matters!)
# ==================================
zinit light romkatv/powerlevel10k
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light wfxr/forgit
zinit light zsh-users/zsh-syntax-highlighting  # Must be last

# ==================================
# Tool Initializations
# ==================================
# FZF
command -v fzf &>/dev/null && source <(fzf --zsh)

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Direnv (auto-load .envrc)
eval "$(direnv hook zsh)"

# NVM
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Conda
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# ==================================
# iTerm2 Integration
# ==================================
test -e "${HOME}/.iterm2_shell_integration.zsh" && \
  source "${HOME}/.iterm2_shell_integration.zsh"

# ==================================
# Keybindings
# ==================================
bindkey -v
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

# ==================================
# DevOps Aliases
# ==================================
# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kgaa='kubectl get all -A'
alias kgd='kubectl get deployments'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias krr='kubectl rollout restart'
alias krs='kubectl rollout status'
alias ktop='kubectl top'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tff='terraform fmt -recursive'
alias tfv='terraform validate'
alias tfo='terraform output'
alias tfs='terraform state list'

# Docker
alias d='docker'
alias dc='docker compose'
alias dcd="docker compose -f docker-compose.yml -f docker-compose.dev.yml"
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dex='docker exec -it'
alias dl='docker logs -f'
alias dimg='docker image ls'
alias dbn='docker build -t'
alias dprune='docker system prune -af'

# Git shortcuts
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gst='git status'
alias gd='git diff'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias glog='git log --oneline --graph'
alias gr='git rebase'
alias gm='git merge'
alias gfa='git fetch --all'
alias gsta='git stash'
alias gstp='git stash pop'

# Zellij shortcuts
alias ztc='zellij action query-tab-names | wc -l | tr -d " "'
zt() {
    zellij action dump-layout 2>/dev/null \
        | grep -oE 'name="[^"]+"( focus=true)?' \
        | awk -F'"' '{ printf "%s%s\n", $2, ($3 ~ /focus/ ? "  *" : "") }'
}

# General
alias v='nvim'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Modern CLI replacements
alias cat='bat'
alias ls='eza'
alias ll='eza -la --git'
alias tree='eza --tree'
alias find='fd'
alias lzd='lazydocker'

alias cc-alok="CLAUDE_CONFIG_DIR=~/.claude-account-alok claude"

# ==================================
# Powerlevel10k Config
# ==================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$(npm config get prefix)/bin:$PATH"

