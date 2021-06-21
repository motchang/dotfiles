#!/usr/bin/env zsh
if [ `uname` = "Darwin" ]
then
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
    if [ -d /usr/local/sbin ]
    then
        PATH=/usr/local/sbin:${PATH}
    fi
    # git diff
    if [ -d /usr/local/share/git-core/contrib/diff-highlight ]
    then
	PATH=${PATH}:/usr/local/share/git-core/contrib/diff-highlight
    fi
fi

if [ `uname` = "Linux" ]
then
    # Linux
    export LANG=ja_JP.utf8
    export LC_CTYPE=ja_JP.utf8
fi

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

# if [ -d /usr/local/mysql/bin ]
# then
#     PATH=${PATH}:/usr/local/mysql/bin
# fi

# if [ -d /usr/local/mysql/lib ]
# then
#     export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:${DYLD_LIBRARY_PATH}
# fi

if [ -d /usr/local/heroku/bin ]
then
    PATH=${PATH}:/usr/local/heroku/bin
fi

export PATH

# git
unset SSH_ASKPASS

# export JAVA_HOME=`/usr/libexec/java_home -v 9`
source "$HOME/.cargo/env"
