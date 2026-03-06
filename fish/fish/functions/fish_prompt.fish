function fish_prompt --description 'Screen Savvy prompt'
  set -l venv $VIRTUAL_ENV_PROMPT
  set -l venv_color $fish_color_param
  if test -z $venv
    set venv 'none'
    set venv_color $fish_color_error
  end

  printf "(%s) %s@%s %s%s%s❯ " \
    (set_color $venv_color)$venv(set_color normal) \
    (set_color $fish_color_user)$USER(set_color normal) \
    (set_color $fish_color_host)(prompt_hostname) \
    (set_color $fish_color_cwd)(prompt_pwd) \
    (set_color $fish_color_host_remote)(fish_git_prompt) \
    (set_color normal)
end
