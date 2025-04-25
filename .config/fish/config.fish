set -x LESS_TERMCAP_mb (printf "\033[01;31m")      # begin blinkin
set -x LESS_TERMCAP_md (printf "\033[01;31m")      # begin bold
set -x LESS_TERMCAP_me (printf "\033[0m")          # end mode
set -x LESS_TERMCAP_se (printf "\033[0m")          # end standout-mode
set -x LESS_TERMCAP_so (printf "\033[01;44;33m")   # begin standout-mode - info box
set -x LESS_TERMCAP_ue (printf "\033[0m")          # end underline
set -x LESS_TERMCAP_us (printf "\033[01;32m")      # begin underline

set EDITOR nvim

fish_add_path -g ~/.local/bin
fish_add_path -g ~/local/bin
fish_add_path -g ~/bin
fish_add_path -g ./node_modules/.bin
fish_add_path -g ~/.cargo/bin

fish_vi_key_bindings

set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
uvenv activate base

# insert space with a S-space or C-space (esc code sent via kitty, see conf)
bind -M insert \e\[32\;2u 'commandline -i " "'
bind -M insert \e\[32\;5u 'commandline -i " "'

# S-Cr, add line under current line
bind -M insert \e\[13\;2u insert-line-under
# C-Cr, add line above current line
bind -M insert \e\[13\;5u insert-line-over

if test -n "$SSH_CLIENT"
  set -g fish_color_host $fish_color_host_remote
end
