function __ai_inline
  set prompt_text (commandline -b)
  if test -z "$prompt_text"
    return
  end

  set prompt (fish_mode_prompt)(fish_prompt)

  set response_file (mktemp)
  ai "$prompt_text" >$response_file 2>/dev/null &
  set ai_pid $last_pid

  # erase prompt text char by char. breaks on multiline commands. that's fine.
  set len (string length $prompt_text)
  for n in (seq $len)
    printf '\b \b' >&2
    sleep 0.005
  end

  function _spin -S
    for frame in $argv
      printf '\r%s%s' $prompt $frame >&2
      sleep 0.05
    end
  end

  _spin "⠂" "⠃"
  while kill -0 $ai_pid 2>/dev/null
    _spin "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
  end
  _spin "⠋" "⠉" "⠈"
  printf '\b \b' >&2  # remove the spinner character

  wait $ai_pid # should be very done by now
  set exit_status $status

  # get response, if it worked
  set response (string trim (cat $response_file))
  rm -f $response_file

  if test $exit_status -ne 0 -o -z "$response"
    set response "$prompt_text"
  end

  # type out response
  set chars (string split '' $response)
  for c in $chars
    sleep 0.02
    printf '%s' $c >&2
  end

  commandline -r "$response"
  commandline -f repaint
end

bind -M insert \cg __ai_inline
