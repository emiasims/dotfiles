function fzf_history -d "Show command history"
  history -z | fzf_pipe --read0 --print0 -q '(commandline)' | read -l cmd
  if test -n "$cmd"
    commandline -- $cmd
  end
  commandline -f repaint
end
