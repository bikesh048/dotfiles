#############
# Basic PATH
#############
export PATH="$PATH:/opt/nvim/"
export TERM="xterm-256color"

# Node Version Manager
source $(brew --prefix nvm)/nvm.sh

# Tmuxifier
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"

#############################
# Powerlevel10k Instant Prompt
#############################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#############################
# Oh-My-Zsh (no plugins here)
#############################
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=()   # Disable OMZ plugin loading (handled by Zinit)
source $ZSH/oh-my-zsh.sh

#############################
# Conda
#############################
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

#############################
# iTerm2 integration
#############################
test -e "${HOME}/.iterm2_shell_integration.zsh" && \
  source "${HOME}/.iterm2_shell_integration.zsh"

#############################
# Zinit Bootstrapping
#############################
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit \
      "$HOME/.local/share/zinit/zinit.git"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#########################################
# FZF bindings
#########################################
source <(fzf --zsh)

#########################################
# Zinit Plugins (Order Matters!)
#########################################

# Powerlevel10k
zinit light romkatv/powerlevel10k

# fzf-tab
zinit light Aloxaf/fzf-tab

# vi-mode
zinit light jeffreytse/zsh-vi-mode

# Autosuggestions (must be near end)
zinit light zsh-users/zsh-autosuggestions

# Syntax highlighting (MUST BE LAST)
zinit light zsh-users/zsh-syntax-highlighting

#########################################
# Keybindings
#########################################
bindkey -v
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

#########################################
# Powerlevel10k Config
#########################################
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

########################################
# nvm - node version manager 
########################################
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
