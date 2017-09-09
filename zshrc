#!/usr/bin/env zsh
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory autocd extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${PATH}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

#
# User specific aliases and functions
#
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
autoload colors

if [ ! -f /usr/bin/vim ]
then
    alias vim='vi'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias emacs-simple='emacs --no-init-file'
# alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'
alias tmux='tmux -2'
alias history='history -E 1'

if [ `uname` = "Darwin" ]
then
    alias ls='gls -G --color'
    alias emacs='emacsclient -nw'
fi

if [ `uname` = "Linux" ]
then
    alias ls='ls --color'
fi

#
# use single socket file in ssh agent forwarding
#
if [ ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock" ] ; then
    unlink "$HOME/.ssh/agent_sock" 2>/dev/null
    ln -s "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
    export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi

export EDITOR='emacsclient -nw'

# TAB 補完時に大文字小文字無視
compctl -M 'm:{a-z}={A-Z}'

# ignore C-d
setopt IGNOREEOF

#
# prompting
#
autoload -Uz colors
colors

# http://tkengo.github.io/blog/2013/05/12/zsh-vcs-info/
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats '(%b|%a)'
precmd () { vcs_info }

# PROMPT='[${vcs_info_msg_0_}]:%~/%f '
PROMPT='%F{cyan}%M%f %D %t job:%F{green}%j%f wd:%~ ${vcs_info_msg_0_}
%n %# '

export WORDCHARS='*?_.[]~-=&;!#$%^(){}<>'

# http://qiita.com/uchiko/items/f6b1528d7362c9310da0
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# https://github.com/rhysd/zsh-bundle-exec
#. ~/src/dotfiles/zsh-bundle-exec/zsh-bundle-exec.zsh

# ------------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------------
which rbenv >> /dev/null 2>&1
if [ $? -eq 0 ]
then
    eval "$(rbenv init -)"
fi

# ------------------------------------------------------------------------------
# node
# ------------------------------------------------------------------------------
if [ -d ${HOME}/.nvm ]
then
    export NVM_DIR=~/.nvm
    # source $(brew --prefix nvm)/nvm.sh
fi

eval "$(nodenv init -)"
export PATH="$PATH:`yarn global bin`"

# ------------------------------------------------------------------------------
# golang
# ------------------------------------------------------------------------------
if [ ! -d ${HOME}/.go ]
then
    mkdir ${HOME}/.go
fi

export GOPATH=${HOME}/.go
export PATH=${GOPATH}/bin:${PATH}

export GHQ_ROOT="${HOME}/src/"

# ------------------------------------------------------------------------------
# tmux
# ------------------------------------------------------------------------------
function ssh() {
    local window_name=$(tmux display -p '#{window_name}')
    command ssh $@
    tmux rename-window $window_name
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/motchang/.sdkman"
[[ -s "/Users/motchang/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/motchang/.sdkman/bin/sdkman-init.sh"
