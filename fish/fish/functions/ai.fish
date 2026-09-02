function ai --description 'ai; with -c the suggested command lands on the command line'
  if status is-interactive; and contains -- -c $argv
    set -l cmd (command ai -n $argv | string collect)
    test -n "$cmd"; or return 1
    commandline -r -- $cmd
    commandline -f repaint
    return
  end

  if type -q streamd; and not contains -- -c $argv
    command ai $argv | streamd --style tokyo-night
  else
    command ai $argv
  end
end
