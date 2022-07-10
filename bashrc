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

peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi

    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}

bind '"\C-r":"peco-history\n"'


export PATH="$(brew --prefix qt@5.5)/bin:$PATH"
. "$HOME/.cargo/env"
