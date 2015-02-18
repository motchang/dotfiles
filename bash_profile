#!/bin/sh
# Get the aliases and functions

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# ------------------------------------------------------------------------------
# User specific environment and startup programs
# ------------------------------------------------------------------------------
if [ `uname` = "Darwin" ]
then
    #mac用のコード
    if [ -f /usr/bin/ssh-agent -a -f ~/.ssh/id_rsa ]
    then
        eval `/usr/bin/ssh-agent`
        ssh-add ~/.ssh/id_rsa
    fi
    # coreutils
    if [ -d /usr/local/opt/coreutils/libexec/gnubin ]
    then
	PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
    fi
    if [ -d /usr/local/opt/coreutils/libexec/gnuman ]
    then
	MANPATH=/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}
	export MANPATH
    fi
fi

if [ `uname` = "Linux" ]
then
    #Linux用のコード
    export LANG=ja_JP.utf8
    export LC_CTYPE=ja_JP.utf8
fi

# PATH
PATH=${HOME}/bin:/usr/local/bin:${PATH}

if [ -d /usr/share/php/ZendFramework/bin/ ]
then
    PATH=${PATH}:/usr/share/php/ZendFramework/bin/
fi
if [ -d ${HOME}/src/Behat/bin/ ]; then
    PATH=${PATH}:${HOME}/src/Behat/bin/
fi

if [ -d ${HOME}/bin/android-sdks/tools ]
then
    PATH=${PATH}:${HOME}/bin/android-sdks/tools
fi

if [ -d ${HOME}/bin/android-sdks/platform-tools ]
then
    PATH=${PATH}:${HOME}/bin/android-sdks/platform-tools
fi

if [ -d /usr/local/mysql/bin ]
then
    PATH=${PATH}:/usr/local/mysql/bin
fi

export PATH

if [ -d /usr/local/mysql/lib ]
then
    export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:${DYLD_LIBRARY_PATH}
fi

# git
unset SSH_ASKPASS

# svn
export SVN_EDITOR='emacs --no-init-file -nw'

# ------------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------------
if [ -d ${HOME}/.rbenv/bin ]
then
    export PATH=${HOME}/.rbenv/bin:${PATH}
    eval "$(rbenv init -)"
fi

# ------------------------------------------------------------------------------
# docker
# ------------------------------------------------------------------------------
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
