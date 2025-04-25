set -l venv_dirs $HOME/.local/share/venv

function __venv_exists -V venv_dirs -a name
  test -d "$venv_dirs/$name"
  and test -f "$venv_dirs/$name/bin/activate.fish"
  return $status
end

function uvenv-create -V venv_dirs -a name
  set env_path "$venv_dirs/$name"

  fcolor comment
  uv venv --seed --no-project --color never $env_path
  and echoc "Created:" -c param $name -c comment "($env_path)"
  or echoc -c error "Failed to create venv '$name'" && return 1

  source $env_path/bin/activate.fish
  and echoc "Activated:" -c param $name
  or echoc -c error "Failed to activate '$name' after creation" && return 1

  set -e argv[1] # name
  if test -n "$argv"
    fcolor comment
    if test "$argv[1]" = "-r"
      pip install --no-color $argv
      and echoc "Installed from requirements:" -c host $argv[2]
      or echoc "Failed to install from " -c error $argv[2]
    else
      pip install --no-color $argv
      and echoc "Installed:" -c host (string join "$(fcolor reset), $(fcolor host)" $argv)
      or echoc "Failed to install" -c error $argv
    end
  end
end

function uvenv-copy -V venv_dirs -a src dest
  if test -z "$dest"
    set dest $src
    set src $VIRTUAL_ENV_PROMPT
  end
  set dest_path $venv_dirs/$dest
  set src_path $venv_dirs/$src

  if not __venv_exists $src
    set emsg "src not found: $src" -c comment "($src_path)"
  else if __venv_exists $dest
    set emsg "dest already exists: $dest" -c comment "($dest_path)"
  else if test "$src" = "$dest"
    set emsg "Nothing to do."
  end
  set -q emsg
  and echoc -c error $emsg && return 1

  set requirements (mktemp --suffix=.txt)
  $src_path/bin/pip freeze > $requirements
  or echoc -c error "Failed to freeze requirements" && return 1

  uvenv-create $dest -r $requirements
  return $status
end

function uvenv-list -V venv_dirs
  for venv in (ls $venv_dirs/*/pyvenv.cfg)
    set pyversion "python=$(grep version_info $venv | cut -d' ' -f3)"
    set venv (basename (dirname $venv))
    echo $venv\t$pyversion
  end
end

function uvenv-remove -V venv_dirs -a name
  set env_path "$venv_dirs/$name"
  if test "$VIRTUAL_ENV_PROMPT" = "$name"
    uvenv activate base
  end

  if not test -d $env_path
    echoc -c error "venv not found: $name" -c comment "($env_path)"
    return 1
  end

  rm -rf $env_path
  echoc "Removed:" -c param $name -c comment "($env_path)"
end

function uvenv-activate -V venv_dirs -a name
  if test "$name" = "$VIRTUAL_ENV_PROMPT"
    return
  end
  if not __venv_exists $name
    echoc -c error "venv not found: $name" -c comment "($venv_dirs/$name)"
    return 1
  end
  source $venv_dirs/$name/bin/activate.fish
end

function uvenv-rename -V venv_dirs -a src dest
  if test -z "$dest"
    set dest $src
    set src $VIRTUAL_ENV_PROMPT
  end
  set dest_path $venv_dirs/$dest
  set src_path $venv_dirs/$src

  test "$src" = "base"
  and echoc -c error "Cannot rename base venv" && return 1

  uvenv-copy $src $dest
  and uvenv-remove $src
  or echoc -c comment "During renaming '$src' -> '$dest'"

  echoc "Renamed:" -c param $src -c reset to -c param $dest -c comment "($dest_path)"
end

alias uvenv-new uvenv-create
alias uvenv-rm uvenv-remove
alias uvenv-go uvenv-activate
alias uvenv-mv uvenv-rename
alias uvenv-move uvenv-rename
alias uvenv-cp uvenv-copy
alias uvenv-deactivate='uvenv-activate base'

function uvenv -a cmd
  if test -z $cmd
    uvenv pick
    return $status
  end
  set -e argv[1] # cmd

  switch $cmd
    case "-h" "--help"

      echo "Usage: uvenv [cmd] [<args>]"
      echo "cmds:"
      echo "  pick (with fzf, activates), ls, list, deactivate"\n
      echo "manipulate (src defaults to current if dest not provided):"
      echo "  copyr, cp          <src> [<dest>]"
      echo "  rename, mv, move   <src> [<dest>]"\n
      echo "  remove, rm         <name>"
      echo "  activate, go       <name>"
      echo \n"Create a new venv:"
      echo "  create, new <name> [<pip install args>]"

    case new create rm remove go activate mv move rename cp copy deactivate
      uvenv-$cmd $argv

    case pick
      # color :)
      uvenv list | fzf_pipe --height=~20% --ansi | read -l venv
      set name (echo $venv | sed -e 's/\x1b\[[0-9;]*m//g' -e 's/^. //' | cut -f1)

      test -n $name
      and uvenv activate $name
      or echoc -c error "No venv selected"

    case ls list
      for venv in (uvenv-list)
        set env (string split \t $venv)  # name	version
        test "$env[1]" = "$VIRTUAL_ENV_PROMPT"
        and echoc -s -c param "> $env[1]"\t -c comment $env[2]
        or echoc -s "  $env[1]"\t -c comment $env[2]
      end

    case "*"
      echo "Usage: uvenv [create|activate|pick|rename|remove|list] ..."
  end
end
