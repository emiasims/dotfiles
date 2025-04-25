function fcolor --wraps=set_color -d "set_color with fish_color_* variables"
  if test "$argv[1]" = "reset"
    printf "%s" (set_color normal)
    return $status
  end
  set -l color $argv[-1]

  # check if the last arg is a fish_color_* variable, and replace the color with
  # the value of that variable if it exists
  set c fish_color_$color
  set -q $c
  and set argv[-1] $$c

  printf "%s" (set_color $argv)
  return $status
end
