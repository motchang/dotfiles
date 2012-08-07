# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

if [ ! -f /usr/bin/vim ]
then
	alias vim='vi'
fi
alias ls='ls --color'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
#alias emacs='/usr/local/bin/emacs'
#alias emacs='emacsclient -c -nw'
alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'

alias screen='LANG=ja_JP.UTF-8 screen'

export PS1='\u@\e[0;36m\h\e[0m \t \d job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w \nbash-\v \$ '
export PATH=$PATH":/usr/share/php/ZendFramework/bin/"

#export SVN_EDITOR='~/bin/emacs --no-init-file -nw'
export SVN_EDITOR='vi'
export GEM_HOME=${HOME}/rubygem_repository

# if [ "$TERM" = 'xterm' -o "$TERM" = 'linux' ]; then
#   screen -rx || screen -D -RR
# fi

export HISTSIZE=100000000
export HISTFILE=~/.bash_history
export HISTFILESIZE=100000000

umask 000
