#!/bin/bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]
then
    . /etc/bashrc
fi

# User specific aliases and functions
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

export PS1='\u@\e[0;36m\h\e[0m \t job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w \nbash-\v \$ '
export PROMPT_COMMAND='echo -n -e "\033]0;${HOSTNAME%%.*}:${PWD/$HOME/~}\007"; history -a; history -c; history -r;'
export HISTSIZE=100000
export HISTFILE=~/.bash_history
export HISTFILESIZE=100000
# Don't put duplicate lines in the history and don't save
export HISTCONTROL="ignoredups"
# .bash_history 追記モードは不要なのでOFFに
shopt -u histappend
if [ ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock" ] ; then
    unlink "$HOME/.ssh/agent_sock" 2>/dev/null
    ln -s "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
    export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi

if [ `uname` = "Darwin" ]
then
    alias ls='ls -G --color'
    alias emacs='emacsclient -nw'
fi

if [ `uname` = "Linux" ]
then
    alias ls='ls --color'
fi


export HISTFILESIZE=100000

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/motchang/.sdkman"
[[ -s "/Users/motchang/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/motchang/.sdkman/bin/sdkman-init.sh"

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
