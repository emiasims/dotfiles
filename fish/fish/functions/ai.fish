function ai --description 'ai; with -c the suggested command lands on the command line'
  if not status is-interactive; or not contains -- -c $argv
    command ai $argv
    return
  end

  set -l cmd (command ai -n $argv | string collect)
  if test -z "$cmd"
    return 1
  end

  commandline -r -- $cmd
  commandline -f repaint
end
