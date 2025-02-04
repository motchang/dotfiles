#!/usr/bin/env zsh
# -*- mode: shell-script -*-
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

setopt appendhistory autocd extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${PATH}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

#
# User specific aliases and functions
#
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias emacs-simple='emacs --no-init-file'
# alias ssh='ssh -o ServerAliveCountMax=5 -o ServerAliveInterval=60'
alias tmux='tmux -2'
alias history='history -E 1'
alias ocaml='rlwrap ocaml'
# alias git='gh'
# alias cleanupbranches='git branch --format "%(refname:short) %(upstream:track)" | grep "\[gone\]" | awk "{print $1}" | xargs -I{} git branch -D {}'
alias cleanupbranches='git branch --format "%(refname:short) %(upstream:track)" | grep "\[gone\]" | awk "{print $1}" | xargs -I{} git branch -D {}'

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ `uname` = "Darwin" ]
then
    alias ls='gls -G --color'
    # alias emacs='emacsclient -nw'
    alias emacs='/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -nw'
fi

if [ `uname` = "Linux" ]
then
    alias ls='ls --color'
fi

#
# Use single socket file in ssh agent forwarding
# ------------------------------------------------------------------------------
# if [ ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock" ] ; then
#     unlink "$HOME/.ssh/agent_sock" 2>/dev/null
#     ln -s "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
#     export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
# 	eval `ssh-agent`
# 	ssh-add
# fi

export EDITOR='emacsclient'

# TAB 補完時に大文字小文字無視
compctl -M 'm:{a-z}={A-Z}'

# ignore C-d
setopt IGNOREEOF

#
# prompting
#
zinit light mafredri/zsh-async

autoload -Uz colors
colors

autoload -Uz add-zsh-hook
setopt prompt_subst

# Git情報を取得する関数
function async_git_info() {
    cd -q "$1"
    if ! git rev-parse --git-dir &>/dev/null; then
        echo ""
        return
    fi

    local git_status="$(git status --porcelain 2>/dev/null)"
    local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
    local result=""

    if [[ -n "$branch" ]]; then
        result="%F{green}"
        if [[ -n "$(echo "$git_status" | grep '^[MADRCU]')" ]]; then
            result+="%F{yellow}!"
        fi
        if [[ -n "$(echo "$git_status" | grep '^.[MADRCU]')" ]]; then
            result+="%F{red}+"
        fi
        result+="($branch)%f"
    fi

    echo "$result"
}

# 非同期ワーカーの初期化
async_init

# グローバル変数の初期化
typeset -g ASYNC_PROMPT_INFO=""

# コールバック関数
function prompt_callback() {
    ASYNC_PROMPT_INFO="$3"
    zle reset-prompt
}

# 非同期ワーカーの設定
async_start_worker prompt_worker -n
async_register_callback prompt_worker prompt_callback

# プロンプト更新関数
function precmd() {
    async_job prompt_worker async_git_info "$PWD"
}

# プロンプトの設定
PROMPT='%D %t job:%F{green}%j%f wd:%~ ${ASYNC_PROMPT_INFO}
%n %# '

# PROMPT='%D %t job:%F{green}%j%f wd:%~ ${ASYNC_PROMPT_INFO}
# (๑•̀ㅂ•́)و✧ '

export WORDCHARS='*?_.[]~-=&;!#$%^(){}<>'

# https://qiita.com/strsk/items/9151cef7e68f0746820d
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# http://qiita.com/uchiko/items/f6b1528d7362c9310da0
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# https://github.com/rhysd/zsh-bundle-exec
#. ~/src/dotfiles/zsh-bundle-exec/zsh-bundle-exec.zsh

function peco-git-branch () {
    local selected_branch=$(git branch -a | sed 's/^\*\s*//' | sort | uniq | \
                          peco --prompt="Switch branch > " | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [ -n "$selected_branch" ]; then
        # remotes/origin/プレフィックスを削除
        local branch_name=$(echo $selected_branch | sed 's|^remotes/origin/||')
        BUFFER="git switch $branch_name"
        CURSOR=$#BUFFER
    fi
    zle reset-prompt
}

zle -N peco-git-branch
bindkey '^xb' peco-git-branch

# ------------------------------------------------------------------------------
# anyenv
# ------------------------------------------------------------------------------
# eval "$(anyenv init -)"

# ------------------------------------------------------------------------------
# mise
# ------------------------------------------------------------------------------
eval "$(${HOME}/.local/bin/mise activate zsh)"

# ------------------------------------------------------------------------------
# python
# ------------------------------------------------------------------------------
export PATH="${HOME}/.local/bin:$PATH"

# ------------------------------------------------------------------------------
# direnv
# ------------------------------------------------------------------------------
eval "$(direnv hook zsh)"

# ------------------------------------------------------------------------------
# golang
# ------------------------------------------------------------------------------
if [ ! -d ${HOME}/.go ]
then
    mkdir ${HOME}/.go
fi
export GOPATH=${HOME}
export PATH=${GOPATH}/bin:${PATH}

# ------------------------------------------------------------------------------
# Java
# ------------------------------------------------------------------------------
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export ES_JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"

# ------------------------------------------------------------------------------
# Rust
# ------------------------------------------------------------------------------
. ${HOME}/.cargo/env


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/motchang/src/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/motchang/src/google-cloud-sdk/path.zsh.inc'; fi

if [ -d "$(brew --prefix)/share/google-cloud-sdk/" ]
then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# ------------------------------------------------------------------------------
# Rust
# ------------------------------------------------------------------------------
. ${HOME}/.cargo/env

export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

# ------------------------------------------------------------------------------
# drienv
# ------------------------------------------------------------------------------
eval "$(direnv hook zsh)"

# ------------------------------------------------------------------------------
# terraform
# ------------------------------------------------------------------------------
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform


# for signed commit
export GPG_TTY=$(tty)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
