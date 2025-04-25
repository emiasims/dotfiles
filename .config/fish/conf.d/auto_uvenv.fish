function __auto_venv_base --on-event fish_postexec -d "Activate base venv if necessary"
  if not set -q VIRTUAL_ENV
    uvenv activate base
    set -g _auto_venv base
  end
end

function __auto_venv_selection --on-event fish_prompt -d "Auto-select project venv if appropriate"
  set -l project (string match -rg 'Projects/([^/]+)' (pwd))
  if test -z "$project"
    or test "$project" = "$_auto_venv"
    return
  end

  set -l path (string match -rg '(.*/Projects/[^/]+)' (pwd))
  if test -d $path/.venv
    source $path/.venv/bin/activate.fish
    set msg -c $fish_pager_color_progress ".venv in:" -c comment $path/
  else if __venv_exists $project
    uvenv activate $project
    set msg $project
  else if __venv_exists (string lower $project)
    uvenv activate (string lower $project)
    set msg (string lower $project)
  else
    return
  end
  echoc -c $fish_pager_color_progress "== Activated" -c comment $msg
  set -g _auto_venv $project
end
