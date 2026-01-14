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
export ZSH="$HOME/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"

# ==================================
# PATH Configuration
# ==================================
export PATH="$PATH:/opt/nvim/"
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# ==================================
# Oh-My-Zsh
# ==================================
ZSH_THEME=""  # Disabled - using Zinit for Powerlevel10k
plugins=()    # Disabled - using Zinit for plugins
source $ZSH/oh-my-zsh.sh

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
source <(fzf --zsh)

# Tmuxifier
eval "$(tmuxifier init -)"

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
# Powerlevel10k Config
# ==================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
