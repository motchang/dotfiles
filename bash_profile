#!/bin/bash
# Get the aliases and functions

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# ------------------------------------------------------------------------------
# User specific environment and startup programs
# ------------------------------------------------------------------------------
#mac用のコード
if [ `uname` = "Darwin" ]
then
    if [ -x /usr/bin/ssh-agent -a -f ~/.ssh/id_rsa ]
    then
        eval `/usr/bin/ssh-agent`
        # ssh-add ~/.ssh/id_rsa
    fi
    # bash compiletion
    if [ -x /usr/local/bin/brew -a -f $(brew --prefix)/etc/bash_completion ]
    then
	. $(brew --prefix)/etc/bash_completion
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
    # python
    if [ -d /usr/local/share/python ]
    then
	PATH=/usr/local/share/python:$PATH
    fi
fi

if [ `uname` = "Linux" ]
then
    # Linux
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

if [ -d /usr/local/heroku/bin ]
then
   PATH=${PATH}:/usr/local/heroku/bin
fi

export PATH

if [ -d /usr/local/mysql/lib ]
then
    export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:${DYLD_LIBRARY_PATH}
fi

# git
unset SSH_ASKPASS
type __git_ps1 2>/dev/null | grep '__git_ps1 is a function' 2>&1 >/dev/null
if [ $? -eq 0 ]
then
    export PS1='\u@\e[0;36m\h\e[0m \t job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w\033[32m\]$(__git_ps1)\[\033[00m\]\nbash-\v \$ '
fi

# svn
export SVN_EDITOR='emacs --no-init-file -nw'

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
    source $(brew --prefix nvm)/nvm.sh
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/motchang/.sdkman"
[[ -s "/Users/motchang/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/motchang/.sdkman/bin/sdkman-init.sh"


export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
