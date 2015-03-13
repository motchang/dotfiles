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

if [ `uname` = "Darwin" ]
then
    #mac用のコード
    alias ls='ls -G --color'
    alias emacs='emacsclient -nw'
fi

if [ `uname` = "Linux" ]
then
    #Linux用のコード
    alias ls='ls --color'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias emacs-simple='emacs --no-init-file'
alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'

# brew install bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]
then
    . $(brew --prefix)/etc/bash_completion
    # brew install git
    type __git_ps1 2>/dev/null | grep '__git_ps1 is a function' 2>&1 >/dev/null
    if [ $? -eq 0 ]
    then
	export PS1='\u@\e[0;36m\h\e[0m \t job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w\033[32m\]$(__git_ps1)\[\033[00m\]\nbash-\v \$ '
    else
	export PS1='\u@\e[0;36m\h\e[0m \t job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w \nbash-\v \$ '
    fi
fi

export PROMPT_COMMAND='echo -n -e "\033]0;${HOSTNAME%%.*}:${PWD/$HOME/~}\007"; history -a; history -c; history -r;'
export HISTSIZE=100000
export HISTFILE=~/.bash_history
export HISTFILESIZE=100000
# Don't put duplicate lines in the history and don't save
export HISTCONTROL="ignoredups"
# .bash_history追記モードは不要なのでOFFに
shopt -u histappend
if [ ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock" ] ; then
    unlink "$HOME/.ssh/agent_sock" 2>/dev/null
    ln -s "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
    export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
