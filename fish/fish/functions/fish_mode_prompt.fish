function fish_mode_prompt
  if not set -q fish_bind_mode
    or set -q fish_mode_hide
    set -e fish_mode_hide
    return
  end
  switch $fish_bind_mode
    case default
      set -f color $fish_color_vimode_normal 'n'
    case insert
      set -f color $fish_color_vimode_insert 'i'
    case replace_one
      set -f color $fish_color_vimode_replace_one 'r'
    case replace
      set -f color $fish_color_vimode_replace 'R'
    case visual
      set -f color $fish_color_vimode_visual 'v'
    case '*'
      set -f color 'red' $fish_bind_mode
  end
  printf '[%s%s%s] ' (set_color --bold $color[1]) $color[2] (set_color normal)
end

