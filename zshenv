function getos() {
  os=`uname -s`
  if [ $os = "linux" -o $os = "Linux" ]; then echo "linux"
  elif [ $os = "darwin" -o $os = "Darwin" ]; then echo "darwin"
  else echo "nt"
  fi
}
export OS=`getos`
function getdistro()
{
  if type lsb_release >/dev/null; then
    rv=$(lsb_release -i | sed 's,.*:\s,,')
  elif [ -e /etc/redhat-release ]; then
    rv=$(cat /etc/redhat-release | sed 's@ \(Server \)\{0,1\}release .*@@')
  else
    rv="Unknown"
  fi
  echo $rv
}
DISTRO=`getdistro`

export MICROSOFT=
uname -r | grep Microsoft &>/dev/null && export MICROSOFT=1

function varset()
{
  if [ $# -ne 1 ]; then
    echo "Usage: $0 <variable>"
    return
  fi
  [ ${(P)1:+1}1 = "11" ]
}
function prepend() {
  if [ $# -lt 2 -o $# -gt 3 ]; then
    echo "Usage: $0 <variable> <value> [<separator>=:]"
    return
  fi
  sep=':'
  [ $# -eq 3 ] && sep=$3
  eval export $1="$(echo ${(P)1} | awk -F${sep} -v path="$2" -v sep=${sep} -v nada=\"\" '{ printf "\""path"\""; for (i = 1; i <= NF; ++i) { if ($i != path) { printf sep; printf "\""$i"\""; } } print nada; }')"
}
function postpend() {
  if [ $# -lt 2 -o $# -gt 3 ]; then
    echo "Usage: $0 <variable> <value> [<separator=:>]"
    return
  fi
  sep=':'
  [ $# -eq 3 ] && sep=$3
  eval export $1="$(echo ${(P)1} | awk -F${sep} -v path="$2" -v sep=${sep} '{ for (i = 1; i <= NF; ++i) { if ($i != path) { printf "\""$i"\""; printf sep; } } print "\""path"\""; }')"
}

function prePATH() { prepend PATH $1 ':' }
function postPATH() { postpend PATH $1 ':' }
function prePYTHONPATH() { prepend PYTHONPATH $1 ':' }
function postPYTHONPATH() { postpend PYTHONPATH $1 ':' }

export EDITOR=vi
export WORDCHARS=',*?_-.~=&;!#$%^(){}<>'

if [[ ! -z $MICROSOFT ]]; then
  export PEOPLE_DIR=/mnt/c/people/feds
elif [ $OS = "linux" ]; then
  function preLD_LIBRARY_PATH { prepend LD_LIBRARY_PATH $1 ':' }
  function postLD_LIBRARY_PATH { postpend LD_LIBRARY_PATH $1 ':' }
  export PEOPLE_DIR=/usr/people/feds
  export EDITOR="geany -imnst"
elif [ $OS = "darwin" ]; then
  function preDYLD_LIBRARY_PATH { prepend DYLD_LIBRARY_PATH $1 ':' }
  function postDYLD_LIBRARY_PATH { postpend DYLD_LIBRARY_PATH $1 ':' }
  export PEOPLE_DIR=~/people/feds
  export EDITOR='/usr/bin/open -n -W -e'
fi

# BULLETTRAIN_PROMPT_ORDER=( custom time status context dir git hg cmd_exec_time perl ruby virtualenv nvm aws go elixir )
if [[ -z $MICROSOFT ]]; then BULLETTRAIN_PROMPT_ORDER=( mytime mycontext myenv cmd_exec_time mygit status dir )
else BULLETTRAIN_PROMPT_ORDER=( mytime mycontext myenv cmd_exec_time mygit status dir ); fi
BULLETTRAIN_PROMPT_CHAR=""
BULLETTRAIN_DIR_EXTENDED=1
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
function prompt_myenv()
{
  local venv=
  [[ ! -z $VIRTUAL_ENV ]] && venv=$(basename $VIRTUAL_ENV)
  local modules="$(module list |& tail -n +2 | sed 's, .),,g' | tr -s " " | paste -sd ' ' -)"
  local prompt=
  [[ ! -z $venv ]] && prompt="$venv "
  prompt+="|"
  [[ ! -z $modules ]] && prompt+=" $modules"
  [[ $prompt != "|" ]] && prompt_segment $BULLETTRAIN_myenv_BG $BULLETTRAIN_myenv_FG "$prompt"
}
function prompt_mytime()
{
  [ ! $BULLETTRAIN_TIME_SUPPRESS ] && prompt_segment $BULLETTRAIN_TIME_BG $BULLETTRAIN_TIME_FG "%D{%H:%M}"
}
mycontext()
{
  local user="$(whoami)"
  if [[ $user != $BULLETTRAIN_CONTEXT_DEFAULT_USER || -n $BULLETTRAIN_IS_SSH_CLIENT ]]; then
    if [ ! -z ${BULLETTRAIN_CONTEXT_LENGTH+x} ]; then
      if [ $BULLETTRAIN_CONTEXT_LENGTH -gt 0 ]; then
        local suser=`echo $user | cut -b 1-$BULLETTRAIN_CONTEXT_LENGTH`
        local host=`hostname -s`
        local shost=`echo $host | cut -b 1-$BULLETTRAIN_CONTEXT_LENGTH`
        if [[ $user != $suser ]]; then suser="$suser*"; fi
        if [[ $host != $shost ]]; then shost="$shost*"; fi
        echo -n "${suser}@$shost"
      fi
    else
      echo -n "${user}@$BULLETTRAIN_CONTEXT_HOSTNAME"
    fi
  fi
}
function prompt_mycontext()
{
  local _context="$(mycontext)"
  [[ -n "$_context" ]] && prompt_segment $BULLETTRAIN_CONTEXT_BG $BULLETTRAIN_CONTEXT_FG "$_context"
}
mygit()
{
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    url=.
    git remote get-url origin >/dev/null 2>&1 && url=$(basename $(git remote get-url origin))
    branch=.
    git rev-parse --abbrev-ref HEAD >/dev/null 2>&1 && branch="$(git rev-parse --abbrev-ref HEAD)"
    [ "$branch" = "master" -o "$branch" = "main" ] && branch=""
    echo ${url/.git/}@$branch
  fi
}
function prompt_mygit()
{
  local _context="$(mygit)"
  [[ -n "${_context}" ]] && prompt_segment $BULLETTRAIN_GIT_BG $BULLETTRAIN_GIT_FG "$_context"
}
BULLETTRAIN_myenv_BG=magenta
BULLETTRAIN_myenv_FG=white
BULLETTRAIN_TIME_BG=green
BULLETTRAIN_TIME_FG=black
BULLETTRAIN_CONTEXT_BG=cyan
BULLETTRAIN_CONTEXT_FG=black

if [ $OS = "linux" ]; then
  case "$DISTRO" in
    Alma*)
      ;&
    CentOS*)
      ;&
    Red*)
      source /usr/share/Modules/init/zsh
      ;;
    Ubuntu*)
      source /usr/share/modules/init/zsh
      ;;
    *)
      echo No environment modules!
      ;;
  esac
elif [ $OS = "darwin" ]; then
  if [ -e /opt/homebrew/opt/modules/init/zsh ]; then source /opt/homebrew/opt/modules/init/zsh;
  else source /usr/local/opt/modules/init/zsh; fi
fi
postpend MODULEPATH $MODULESHOME/modulefiles ':'
postpend MODULEPATH ~/zsh/modulefiles ':'

export LESS=-SRFXx4
export PAGER=
# export GIT_PAGER=less
export MANPAGER=less

export AUTOENV_FILE_ENTER=.autoenv.zsh
export AUTOENV_FILE_LEAVE=.autoenv.zsh
export AUTOENV_HANDLE_LEAVE=1

# Also in zprofile
prePATH /usr/local/bin
if [[ ! -z $MICROSOFT ]]; then
  true
elif [ $OS = "linux" ]; then
  true
elif [ $OS = "darwin" ]; then
  prePATH ~/Library/Python/3.9/bin
  prePATH /opt/homebrew/bin
fi
prePATH ~/bin

ZSHENV_LOCAL=~/.zshenv.local
[[ -f $ZSHENV_LOCAL ]] && source $ZSHENV_LOCAL
