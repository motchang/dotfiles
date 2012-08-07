# .bash_profile

export LANG=ja_JP.utf8

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$HOME/bin:$PATH
export GEM_HOME=${HOME}/rubygem_repository

export PATH

export LC_CTYPE=ja_JP.utf8

if [ "$TERM" = 'xterm' -o "$TERM" = 'linux' ]; then
	export TERM=xterm-256color
#	$HOME/bin/emacs --daemon
	screen -rx || screen -D -RR
NOP='NOP'
fi

