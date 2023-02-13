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

ZPROFILELOCAL=~/.zprofile.local
[[ -f $ZPROFILELOCAL ]] && source $ZPROFILELOCAL
