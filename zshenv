function getos() {
  os=`uname -s`
  if [ $os = "linux" -o $os = "Linux" ]; then echo "linux"
  elif [ $os = "darwin" -o $os = "Darwin" ]; then echo "darwin"
  else echo "nt"
  fi
}
export OS=`getos`

export MICROSOFT=
uname -r | grep Microsoft &>/dev/null && export MICROSOFT=1

function varset() { [ ${(P)+1} = "1" ] }
function prepend() { if varset ${1}; then export $1="$2$3${(P)1}"; else export $1="$2"; fi }
function postpend() { if varset ${1}; then export $1="${(P)1}$3$2"; else export $1="$2"; fi }

function prePATH() { prepend PATH $1 ':' }
function postPATH() { postpend PATH $1 ':' }

if [ $OS = "darwin" ]; then
  function preDYLD_LIBRARY_PATH { prepend DYLD_LIBRARY_PATH $1 ':' }
  function postDYLD_LIBRARY_PATH { postpend DYLD_LIBRARY_PATH $1 ':' }
elif [ $OS = "linux" ]; then
  function preLD_LIBRARY_PATH { prepend LD_LIBRARY_PATH $1 ':' }
  function postLD_LIBRARY_PATH { postpend LD_LIBRARY_PATH $1 ':' }
fi

if [ $OS = "darwin" -o $OS = "linux" ]; then
  function prePYTHONPATH() { prepend PYTHONPATH $1 ':' }
  function postPYTHONPATH() { postpend PYTHONPATH $1 ':' }
elif [ $OS = "nt" ]; then
  function prePYTHONPATH() { prepend PYTHONPATH $1 ';' }
  function postPYTHONPATH() { postpend PYTHONPATH $1 ';' }
fi

# BULLETTRAIN_PROMPT_ORDER=( custom time status context dir git hg cmd_exec_time perl ruby virtualenv nvm aws go elixir )
if [[ -z $MICROSOFT ]]; then BULLETTRAIN_PROMPT_ORDER=( custom status context dir cmd_exec_time )
else BULLETTRAIN_PROMPT_ORDER=( custom dir ); fi
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_CUSTOM_MSG="%!"
BULLETTRAIN_CUSTOM_BG=green
BULLETTRAIN_CUSTOM_FG=white
BULLETTRAIN_PROMPT_CHAR=""
BULLETTRAIN_DIR_EXTENDED=2
BULLETTRAIN_CONTEXT_DEFAULT_USER=scott

ZSHENV_HOSTNAME=~/.zshenv.`hostname`
[[ -f $ZSHENV_HOSTNAME ]] && source $ZSHENV_HOSTNAME
