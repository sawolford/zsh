# load zgen
source ~/.zgen/zgen.zsh

export WORDCHARS=',*?_-.~=&;!#$%^(){}<>'

# if the init scipt doesn't exist
if ! zgen saved; then

  # specify plugins here
  zgen oh-my-zsh
#  zgen oh-my-zsh themes/arrow
#  zgen oh-my-zsh themes/agnoster
#  zgen oh-my-zsh themes/jreese
#  zgen oh-my-zsh themes/muse
#  zgen oh-my-zsh themes/nebirhos
#  zgen oh-my-zsh themes/pygmalion
#  zgen oh-my-zsh themes/myagnoster

  # generate the init script from plugins above
  zgen save
fi
 
builtin alias bullettrain='zgen load caiogondim/bullet-train-oh-my-zsh-theme bullet-train'
function() grepr() { grep -nrHIE $@ . }
builtin alias greprh='grepr --include="*.h"'
builtin alias greprch='greprh --include="*.c*"'
builtin alias df='df -k'
builtin alias du='du -k'
builtin alias ls='ls -F'
builtin alias ll='ls -l'
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
builtin alias diff='diff -w'
function h1() { if [ $# -eq 0 ]; then history; else history | grep $1; fi }
function pkfindi() { if [ $# -eq 0 ]; then find .; else find . -name "$@"; fi }
function pkfind() { if [ $# -eq 0 ]; then find .; else find . -iname "$@"; fi }
#builtin alias pkfind='find . -name'
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

if [ $OS = "linux" ]; then
  builtin alias ls='ls -F --color=tty'
  builtin alias ee=code
  builtin alias usr='cd /usr/people/feds'
elif [ $OS = "darwin" ]; then
  builtin alias ls='gls -F --color=tty'
  builtin alias usr='cd ~/people/feds'
  function ee() { open -a /Applications/Visual\ Studio\ Code.app $1 }
fi

# setopt
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

# HISTORY
# don't insert lines beginning with a space into history list
# don't insert duplicates into history list
HISTCONTROL="ignoreboth"
HISTIGNORE="bg:fg"

ps -p$PPID | grep gnome-terminal 2>&1 >/dev/null
gt=$?
ps -p$PPID | grep wslbridge 2>&1 >/dev/null
wslb=$?
# ps -p$PPID | grep konsole 2>&1 >/dev/null
# ko=$?
ps -p$PPID | grep /Applications/Visual 2>&1 >/dev/null
vsc=$?
if [ -n "$SSH_TTY" ]; then export BULLETTRAIN_IS_SSH_CLIENT=1; fi
if [ ${TERM_PROGRAM-x} = "iTerm.app" -o $gt -eq 0 -o $wslb -eq 0 -o $vsc -eq 0 ]; then
  bullettrain
else
  zgen oh-my-zsh themes/jreese
fi

ZSHRC_HOSTNAME=~/.zshrc.`hostname -s`
[[ -f $ZSHRC_HOSTNAME ]] && source $ZSHRC_HOSTNAME
