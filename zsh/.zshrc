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
# PATH Configuration
# ==================================
export PATH="$PATH:/opt/nvim/"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

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
zinit light zsh-users/zsh-syntax-highlighting  # Must be last

# ==================================
# Tool Initializations
# ==================================
# FZF
command -v fzf &>/dev/null && source <(fzf --zsh)

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
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tff='terraform fmt -recursive'
alias tfv='terraform validate'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dex='docker exec -it'
alias dl='docker logs -f'
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
alias gb='git branch'
alias glog='git log --oneline --graph'

# General
alias v='nvim'
alias c='clear'
alias ll='ls -la'
alias ..='cd ..'
alias ...='cd ../..'

# ==================================
# Powerlevel10k Config
# ==================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
