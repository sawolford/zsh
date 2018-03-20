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

if [ $OS = "linux" ]; then
  function preLD_LIBRARY_PATH { prepend LD_LIBRARY_PATH $1 ':' }
  function postLD_LIBRARY_PATH { postpend LD_LIBRARY_PATH $1 ':' }
elif [ $OS = "darwin" ]; then
  function preDYLD_LIBRARY_PATH { prepend DYLD_LIBRARY_PATH $1 ':' }
  function postDYLD_LIBRARY_PATH { postpend DYLD_LIBRARY_PATH $1 ':' }
fi

# BULLETTRAIN_PROMPT_ORDER=( custom time status context dir git hg cmd_exec_time perl ruby virtualenv nvm aws go elixir )
if [[ -z $MICROSOFT ]]; then BULLETTRAIN_PROMPT_ORDER=( mytime mycontext module_list cmd_exec_time status dir )
else BULLETTRAIN_PROMPT_ORDER=( mytime module_list dir ); fi
BULLETTRAIN_PROMPT_CHAR=""
BULLETTRAIN_DIR_EXTENDED=2
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
function prompt_module_list()
{
  local prompt="$(module list |& tail -n +2 | sed 's, .),,g' | tr -s " " | paste -sd ' ' -)"
  [[ ! -z $prompt ]] && prompt_segment $BULLETTRAIN_MODULE_LIST_BG $BULLETTRAIN_MODULE_LIST_FG "$prompt"
}
function prompt_mytime()
{
  prompt_segment $BULLETTRAIN_TIME_BG $BULLETTRAIN_TIME_FG "%D{%H:%M %m/%d}"
}
mycontext()
{
  local user="$(whoami)"
  if [[ "$user" != "$BULLETTRAIN_CONTEXT_DEFAULT_USER" || -n "$BULLETTRAIN_IS_SSH_CLIENT" ]]; then
    if [[ ! -z ${BULLETTRAIN_CONTEXT_LENGTH+x} ]]; then
      user=`echo $user | cut -b 1-$BULLETTRAIN_CONTEXT_LENGTH`
      local host=`hostname | cut -b 1-$BULLETTRAIN_CONTEXT_LENGTH`
      echo -n "${user}*@${host}*"
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
export PAGER=
export GIT_PAGER=less
export MANPAGER=less

ZSHENV_HOSTNAME=~/.zshenv.`hostname -s`
[[ -f $ZSHENV_HOSTNAME ]] && source $ZSHENV_HOSTNAME
