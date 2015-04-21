#!/usr/bin/env zsh
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

setopt HIST_IGNORE_DUPS SHARE_HISTORY
autoload colors

if [ ! -f /usr/bin/vim ]
then
    alias vim='vi'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias emacs-simple='emacs --no-init-file'
alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'
alias tmux='tmux -2'
alias history='history -E 1'

if [ `uname` = "Darwin" ]
then
    alias ls='ls -G --color'
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
