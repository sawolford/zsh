function getos() {
  os=`uname -s`
  if [ $os = "linux" -o $os = "Linux" ]; then echo "linux"
  elif [ $os = "darwin" -o $os = "Darwin" ]; then echo "darwin"
  else echo "nt"
  fi
}
export OS=`getos`
function getdistro() { lsb_release -i | sed 's,.*:\s,,' }

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
  echo ${(P)1} | grep -- ${2} 2>&1 >/dev/null
  st=$?
  if [ $st -eq 0 ]; then
    export $1=`echo $PATH | awk -F${sep} -v x=$2 '{ printf x; for (i = 1; i <= NF; ++i) { if ($i != x) printf ":"$i; } printf "\n"; }'`
  else
    if varset ${1}; then
      export $1="$2${sep}${(P)1}"
    else
      export $1="$2"
    fi
  fi
}
function postpend() {
  if [ $# -lt 2 -o $# -gt 3 ]; then
    echo "Usage: $0 <variable> <value> [<separator=:>]"
    return
  fi
  sep=':'
  [ $# -eq 3 ] && sep=$3
  echo ${(P)1} | grep -- ${2} 2>&1 >/dev/null
  st=$?
  if [ $st -eq 0 ]; then
    export $1=`echo $PATH | awk -F${sep} -v x=$2 '{ for (i = 1; i <= NF; ++i) { if ($i != x) printf $i":"; } printf x"\n"; }'`
  else
    if varset ${1}; then
      export $1="${(P)1}${sep}$2"
    else
      export $1="$2"
    fi
  fi
}

function prePATH() { prepend PATH $1 ':' }
function postPATH() { postpend PATH $1 ':' }
function prePYTHONPATH() { prepend PYTHONPATH $1 ':' }
function postPYTHONPATH() { postpend PYTHONPATH $1 ':' }

if [ $OS = "linux" ]; then
  function preLD_LIBRARY_PATH { prepend LD_LIBRARY_PATH $1 ':' }
  function postLD_LIBRARY_PATH { postpend LD_LIBRARY_PATH $1 ':' }
elif [ $OS = "darwin" ]; then
  function preDYLD_LIBRARY_PATH { prepend DYLD_LIBRARY_PATH $1 ':' }
  function postDYLD_LIBRARY_PATH { postpend DYLD_LIBRARY_PATH $1 ':' }
fi

# BULLETTRAIN_PROMPT_ORDER=( custom time status context dir git hg cmd_exec_time perl ruby virtualenv nvm aws go elixir )
if [[ -z $MICROSOFT ]]; then BULLETTRAIN_PROMPT_ORDER=( mytime context module_list cmd_exec_time status dir )
else BULLETTRAIN_PROMPT_ORDER=( mytime module_list dir ); fi
BULLETTRAIN_PROMPT_CHAR=""
BULLETTRAIN_DIR_EXTENDED=2
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
function module_list() { echo 'echo %! $(module list -t |& tail -n +2)' }
function prompt_module_list()
{
  local prompt="$(module list -t |& tail -n +2 | paste -sd ' ' -)"
  [[ ! -z $prompt ]] && prompt_segment $BULLETTRAIN_MODULE_LIST_BG $BULLETTRAIN_MODULE_LIST_FG "$prompt"
}
function prompt_mytime()
{
  prompt_segment $BULLETTRAIN_TIME_BG $BULLETTRAIN_TIME_FG "%D{%H:%M %m/%d} `date +%a`"
}
BULLETTRAIN_MODULE_LIST_BG=magenta
BULLETTRAIN_MODULE_LIST_FG=white
BULLETTRAIN_TIME_BG=green
BULLETTRAIN_TIME_FG=black
BULLETTRAIN_CONTEXT_BG=cyan
BULLETTRAIN_CONTEXT_FG=black

if [ $OS = "linux" ]; then
  if [ `getdistro` = "CentOS" ]; then
    source /usr/share/Modules/init/zsh
  else
    source /usr/share/modules/init/zsh
  fi
elif [ $OS = "darwin" ]; then
  source /usr/local/opt/modules/init/zsh
fi
postpend MODULEPATH $MODULESHOME/modulefiles ':'
postpend MODULEPATH ~/zsh ':'

export EDITOR=vi

ZSHENV_HOSTNAME=~/.zshenv.`hostname -s`
[[ -f $ZSHENV_HOSTNAME ]] && source $ZSHENV_HOSTNAME
