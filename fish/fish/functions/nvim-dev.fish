set -l CONFIG "$(set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo ~/.config)/nvim"

function __nvim-dev-clean --description 'Setup nvim-dev env' -V CONFIG
  echoc -c param "Cleaning and setting up nvim-dev environment..."

  set -l STATE "$(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo ~/.local/state)/nvim"
  set -l SHARE "$(set -q XDG_SHARE_HOME; and echo $XDG_SHARE_HOME; or echo ~/.local/share)/nvim"

  rm -rf $STATE-dev
  cp -r $STATE $STATE-dev

  rm -rf $SHARE-dev
  cp -r $SHARE $SHARE-dev

  pushd $CONFIG >/dev/null

  if test -d $CONFIG-dev
    git worktree remove -f $CONFIG-dev 2>/dev/null
  end

  if git show-ref --verify --quiet refs/heads/dev
    git fetch . HEAD:dev 2>/dev/null
    or echoc -c error "Failed to fast-forward dev branch."
  else
    git branch dev
  end

  rm -rf $CONFIG-dev

  git worktree prune
  git worktree add $CONFIG-dev dev

  cp -r $CONFIG/mia_plugins $CONFIG-dev/mia_plugins

  popd >/dev/null
end

function nvim-dev -V CONFIG --wraps='nvim' --description 'Development setup for nvim'
  if test "$argv[1]" = clean
    or not test -d $CONFIG-dev
    __nvim-dev-clean
    return
  end
  echo $CONFIG-dev

  set -x NVIM_APPNAME nvim-dev
  nvim $argv
end
