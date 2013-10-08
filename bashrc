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
    alias ls='ls -G'
fi

if [ `uname` = "Linux" ]
then
    #Linux用のコード
    alias ls='ls --color'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
#alias emacs='/usr/local/bin/emacs'
#alias emacs='emacsclient -c -nw'
alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'
# alias screen='LANG=ja_JP.UTF-8 screen'

# if [ "$TERM" = 'xterm' -o "$TERM" = 'linux' ]; then
#   screen -rx || screen -D -RR
# fi

export PS1='\u@\e[0;36m\h\e[0m \t \d job(s):\[\033[0;32m\]\j\[\033[0m\] wd:\w \nbash-\v \$ '
export PROMPT_COMMAND='echo -n -e "\033]0;${HOSTNAME%%.*}:${PWD/$HOME/~}\007"; history -a; history -c; history -r;'
export HISTSIZE=100000
export HISTFILE=~/.bash_history
export HISTFILESIZE=100000
# Don't put duplicate lines in the history and don't save
export HISTCONTROL="ignoredups"
# .bash_history追記モードは不要なのでOFFに
shopt -u histappend
