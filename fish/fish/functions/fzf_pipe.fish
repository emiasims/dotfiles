function fzf_pipe --wraps='fzf' -d "Sets sane args"
  test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
  set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m"
  cat | eval (__fzfcmd) $argv
end

function __fzfcmd
  test -n "$FZF_TMUX"; or set FZF_TMUX 0
  test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
  if [ -n "$FZF_TMUX_OPTS" ]
    echo "fzf-tmux $FZF_TMUX_OPTS -- "
  else if [ $FZF_TMUX -eq 1 ]
    echo "fzf-tmux -d$FZF_TMUX_HEIGHT -- "
  else
    echo "fzf"
  end
end
