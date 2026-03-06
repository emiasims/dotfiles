if [[ -f /etc/profile ]] && [[ -x /usr/libexec/path_helper ]]; then
    PATH=""
    source /etc/profile
fi

function addpath() {
  local newpath=$1
  if [[ -d $newpath ]] && [[ "$PATH" != *"$(readlink -f $newpath)"* ]]; then
    echo $(readlink -f $newpath):$PATH
  else
    echo $PATH
  fi
}

export PATH=$(addpath "$HOME/.local/bin")
export PATH=$(addpath "$HOME/miniconda3/bin")
export PATH=$(addpath "$HOME/local/bin")
export PATH=$(addpath "$HOME/.scripts/bin")

export PATH=$(addpath "$HOME/.yarn/bin")
export PATH=$(addpath "$HOME/.config/yarn/global/node_modules/.bin")

if [[ -f $HOME/.alias ]]; then
  source $HOME/.alias
fi

if [[ -f $HOME/.local/dot/alias ]]; then
    source $HOME/.local/dot/alias
fi
