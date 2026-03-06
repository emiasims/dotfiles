#!/usr/bin/zsh

CONF_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}

source $HOME/.profile
source $CONF_HOME/zsh/zshrc

# >>> conda initialize >>>
# <<< conda initialize <<<

if pgrep tmux &> /dev/null; then
  conda activate $(tmux display-message -p '#S') &> /dev/null
else
  [ -n "$KITTY_WINDOW_ID" ] && command -v setup_tmux_sessions &> /dev/null && setup_tmux_sessions
fi
