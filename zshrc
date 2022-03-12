. ~/.zinit/zinit.zsh

zinit light "caiogondim/bullet-train.zsh"
zinit light "zsh-users/zsh-history-substring-search"
zinit light "Tarrasch/zsh-autoenv"

zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit for OMZL::prompt_info_functions.zsh

autoload -Uz compinit
compinit

KEYTIMEOUT=1
bindkey -e
if where history-substring-search-up &>/dev/null; then
  [[ ! -z "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
  [[ ! -z "$key[Up]" ]] && bindkey "$key[Up]" history-substring-search-up
  bindkey '^[[A' history-substring-search-up
  [[ ! -z "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down
  [[ ! -z "$key[Down]" ]] && bindkey "$key[Down]" history-substring-search-down
  bindkey '^[[B' history-substring-search-down
fi
[[ ! -z "$terminfo[kLFT5]" ]] && bindkey "$terminfo[kLFT5]" backward-word
[[ ! -z "$terminfo[kRIT5]" ]] && bindkey "$terminfo[kRIT5]" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[\"" quote-region
bindkey "^[W" copy-region-as-kill
bindkey "^[w" kill-region

export SAVEHIST=100000
export HISTSIZE=$SAVEHIST
export HISTFILE=~/.zsh_history

function exists { which $1 &> /dev/null }
builtin alias bullettrain='SEGMENT_SEPARATOR=""'
builtin alias nobullettrain='SEGMENT_SEPARATOR=" "'
function() grepr() { grep -nrHIE $@ . }
function() agrepr() { grep -nrHIE $@ ${PWD} }
function() wagrepr() { agrepr --color=always $@ | sed 's,/mnt/\(.\)/,\1:/,' }
function() aack() { ack --nogroup $@ ${PWD} }
function() lag() { ag --pager less --nogroup $@ }
function() pag() { lag $@ ${PWD} }
builtin alias greprh='grepr --include="*.h"'
builtin alias greprch='greprh --include="*.c*"'
builtin alias ngrep='grep -n'
builtin alias df='df -k'
builtin alias du='du -k'
builtin alias ls='ls -F'
builtin alias ll='ls -l'
builtin alias lt='ls -lrt'
builtin alias lh='ls -lrhtd'
builtin alias rm='rm -i'
builtin alias mv='mv -i'
builtin alias cp='cp -i'
builtin alias ln='ln -i'
builtin alias rmf='command rm'
builtin alias mvf='command mv'
builtin alias cpf='command cp'
builtin alias lnf='command ln'
builtin alias wcl='wc -l'
builtin alias mkdir='nocorrect mkdir -p'
function hh1() { if [ $# -eq 0 ]; then fc -l 1; else fc -l 1 | grep $1; fi }
function hl1() { if [ $# -eq 0 ]; then fc -lI 1; else fc -lI 1 | grep $1; fi }
function pkfindi() { if [ $# -eq 0 ]; then find .; else find . -name "$@"; fi }
function pkfind() { if [ $# -eq 0 ]; then find .; else find . -iname "$@"; fi }
function find0() { find . "$@" -print0 }
builtin alias xargs0='xargs -0'
function md5txt() { if [ $# -eq 0 ]; then find0 -type f | xargs0 md5sum | tee md5.txt; else md5sum "$@" | tee md5.txt; fi }
builtin alias more='less'
builtin alias sl='ls'
builtin alias dc='cd'
function setenv() { if [ $# -eq 2 ]; then export $1=$2; else echo "Usage: setenv <variable> <value>"; fi }
function alias() { if [ $# -eq 2 ]; then builtin alias $1=$2; elif [ $# -eq 1 ]; then builtin alias $1; elif [ $# -eq 0 ]; then builtin alias; else echo "Usage: alias [<alias> [<value>]]"; fi }
builtin alias balias='builtin alias'
builtin alias seq='seq -w'
builtin alias hashd='hash -d'
function makel() { make $* |& less }
builtin alias makev='make VERBOSE=1'
function makevl() { makev $* |& less }
builtin alias makej='make -kj$(nproc) $*; make -kj$(nproc); make'
function killcode() { kill `ps -eo pid,command | grep code/code$ | awk '{print $1}'` }
builtin alias gove='cd $VIRTUAL_ENV'
function gousr() { cd $PEOPLE_DIR/.. }
function stmux() { ssh -t $@ "tmux new -A -s tmux" }
builtin alias ltmux='tmux new -A -s tmux'
function fixssh() { eval $(tmux show-env | sed -n 's/^\(SSH_[^=]*\)=\(.*\)/export \1="\2"/p') }
function calc() { bc -l <<< "$@" }
export NNN_TMPFILE="/tmp/nnn"
nn() {
	export NNN_CONTEXT_COLORS='4321'
        PAGER=less LESS=-RX nnn "$@"

        if [ -f $NNN_TMPFILE ]; then
                . $NNN_TMPFILE
                command rm -f $NNN_TMPFILE
        fi
}
builtin alias genautoenv="printf 'if [[ \$autoenv_event == \"enter\" ]]; then\nelse\nfi\n' | tee -a $AUTOENV_FILE_LEAVE"
builtin alias cmakedebug='cmake -DCMAKE_BUILD_TYPE=Debug'
builtin alias cmakerelease='cmake -DCMAKE_BUILD_TYPE=Release'
function makeall()
{
  if (( ${+SYSTEMROOT} )); then
    fargs=VS16
    if [ $# -gt 0 ]; then; set -A fargs $@; fi
    for i in $fargs; do
      cmake.exe --build $i --config Debug
      cmake.exe --build $i --config Release
    done
  else
    bargs=
    if [ $# -gt 0 ]; then; set -A bargs --target $@; fi
    for i in DebugGcc DebugClang ReleaseGcc ReleaseClang; do
      cmake --build $i --target depend
      cmake --build $i -j$(nproc) $bargs
    done
  fi
}
if exists percol; then
    function percol_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }
    zle -N percol_select_history
    bindkey '^[r' percol_select_history

    function percol_select_local_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -I -l -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }
    zle -N percol_select_local_history
    bindkey '^[s' percol_select_local_history
fi
if exists jump; then eval "$(jump shell zsh --bind=jj)"; fi
if ! exists pixz; then builtin alias pixz='xz -T 0'; fi
tpxz() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <file> [<file> ...]"
        echo
        echo "       $0 <file>"
        echo "           Writes <file.xz>"
        echo "       $0 <file> <file> [<file> ...]"
        echo "           Writes to stdout: tar cf - <file> [<file> ...] | pixz -9"
        return
    fi
    if [ $# -eq 1 -a -f "$1" ]; then
        file="$1"
        if [ -e "$file.xz" ]; then echo "$file.xz" exists; return; fi
        if pv "$file" | pixz -9 > "$file.xz"; then
            rm -f "$file"
        else
            rm -f "$file.xz"
        fi
    else
        size=`du -sbc "$@" | tail -1 | cut -f1`
        tar cf - "$@" | pv -s $size | pixz -9
    fi
}
function ctpxz() {
    (fpath="$(pwd)"
    folder="$(basename $fpath)"
    cd ..
    tpxz "$folder" > "$folder.txz")
}
function myscp() {
    local args dest
    while (($#)); do
        case $1 in
            -t) dest="$2"
                shift
                ;;
            * ) args+=("$1")
                ;;
        esac
        shift
    done
    echo scp $args $dest
    scp $args $dest
}

if [ $OS = "linux" ]; then
  builtin alias ls='ls -F --color=tty'
  if [[ -z $MICROSOFT ]]; then
    EECMD="code"
    builtin alias ee="${EECMD}"
    builtin alias ex='xargs ${EECMD}'
  else
    EECMD="Code.exe"
    function ee() { if [ $# -lt 1 ]; then echo "Usage: $0 <filename> [<filename> ...]" ; else eval ${EECMD} $*; AutoIt3.exe /AutoIt3ExecuteLine "If AutoItSetOption('WinTitleMatchMode', 2) Then WinActivate('Visual Studio Code')"; fi }
  fi
elif [ $OS = "darwin" ]; then
  builtin alias ls='gls -F --color=tty'
  builtin alias md5sum=gmd5sum
  builtin alias nproc=gnproc
  EECMD="code"
  builtin alias ee="${EECMD}"
  builtin alias ex='xargs ${EECMD}'
  function growl() { osascript -e "display notification \"$1\" with title \"${2:-Title}\"" }
  function growlsound() { osascript -e "display notification \"$1\" sound name \"Glass\" with title \"${2:-Title}\"" }
fi
function findee() { if [ $# -eq 0 ]; then echo "Usage: $0 <predicates>"; else find0 -name "$@" | eval xargs -0 ${EECMD}; fi }

# setopt
setopt no_global_rcs # don't load /etc/*
setopt auto_list # list choices on ambiguous completions
unsetopt auto_menu # "
setopt ignore_eof # eof(^D) doesn't quit shell
setopt interactive_comments # allow comments in interactive shell
setopt numeric_glob_sort # sort numerically rather than lexically in globs
setopt no_beep # turn off that incessant beeping
#setopt cdable_vars # try to prepend ~ for cd's
#setopt print_exit_value # print non-zero exit status
#setopt list_types # show types when listing ambiguous completions
#setopt no_match # seems just like bad_pattern
#setopt auto_name_dirs # make params of directories like ~ completions
#setopt auto_param_slash # completions of directories add /'s
#setopt auto_remove_slash # trailing /'s in completions are removed
#setopt bad_pattern # indicate message for bad filename generation
#setopt correct_all # correct everything on the command line
#setopt function_argzero # set $0 to name of function or script
#setopt hash_cmds # hash commands as they are run
#setopt hist_beep # beep when history can not be completed
#setopt hist_ignore_dups # do not put duplicate commands into history list
#setopt hist_ignore_space # commands which begin w/ spaces are not in history
#setopt complete_in_word # complete in the middle of a word
#setopt extended_glob # for globs with exclusions
#setopt always_to_end # move cursor to end of word on matches
setopt prompt_subst # make sure prompt is able to be generated properly
setopt inc_append_history # append every command to the history file
setopt share_history # reload history when you start a shell

# HISTORY
# don't insert lines beginning with a space into history list
# don't insert duplicates into history list
HISTCONTROL="ignoreboth"
HISTIGNORE="bg:fg"

ps -p$PPID | grep gnome-terminal 2>&1 >/dev/null
gt=$?
ps -p$PPID | grep wslbridge 2>&1 >/dev/null
wslb=$?
ps -p$PPID | grep /Applications/Visual 2>&1 >/dev/null
vsc=$?
ps -p$PPID | grep init 2>&1 >/dev/null
init=$?
ps -p$PPID | grep Code 2>&1 >/dev/null
code=$?
ps -p$PPID | grep tmux 2>&1 >/dev/null
tmux=$?
if [ -n "$SSH_TTY" ]; then export BULLETTRAIN_IS_SSH_CLIENT=1; fi
if [ ${TERM_PROGRAM-x} = "iTerm.app" -o $gt -eq 0 -o $wslb -eq 0 -o $vsc -eq 0 -o $init -eq 0 -o $code -eq 0 -o $tmux -eq 0 ]; then
  bullettrain
else
  nobullettrain
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit && compinit

ZSHRC_LOCAL=~/.zshrc.local
[[ -f $ZSHRC_LOCAL ]] && source $ZSHRC_LOCAL
