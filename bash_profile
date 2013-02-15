# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# ------------------------------------------------------------------------------
# User specific environment and startup programs
# ------------------------------------------------------------------------------
export GEM_HOME=${HOME}/rubygem_repository
if [ `uname` = "Darwin" ]
then
    #mac用のコード
    # ssh agent forwarding
    if [ -f /usr/bin/ssh-agent ]
    then
        eval `/usr/bin/ssh-agent`

        if [ -f ~/.ssh/id_rsa ]
        then
            ssh-add ~/.ssh/id_rsa
        fi

        if [ -f ~/Dropbox/ssh/id_rsa ]
        then
            ssh-add ~/Dropbox/ssh/id_rsa
        fi
    fi
fi

if [ `uname` = "Linux" ]
then
    #Linux用のコード
    export LANG=ja_JP.utf8
    export LC_CTYPE=ja_JP.utf8
fi

#export SVN_EDITOR='~/bin/emacs --no-init-file -nw'
export SVN_EDITOR='vi'
# PATH
PATH=$HOME/bin:/usr/local/bin:$PATH

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

if [ -d ${HOME}/rubygem_repository/bin/ ]; then
	export PATH=${HOME}/rubygem_repository/bin/:${PATH}
fi

export PATH

# ------------------------------------------------------------------------------
# GNU SCREEN
# ------------------------------------------------------------------------------
if [ "$TERM" = 'xterm' -o "$TERM" = 'linux' ]; then
	export TERM=xterm-256color
#	$HOME/bin/emacs --daemon
	screen -rx || screen -D -RR
	NOP='NOP'
fi

# ------------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------------
if [ -d ${HOME}/rubygem_repository ]
then
    export GEM_HOME=${HOME}/rubygem_repository
fi

if [ -d ${HOME}/.rbenv/bin ]
then
    export PATH=${HOME}/.rbenv/bin:${PATH}
    eval "$(rbenv init -)"
fi

# これがあたしの全力全開ッ
# umask 000

# git コマンドがイカれるので変数を握りつぶす
unset SSH_ASKPASS
