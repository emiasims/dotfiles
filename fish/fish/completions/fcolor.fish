complete --keep-order -c fcolor -a "(set --names | sed -n 's/fish_color_\(.*\)/\1\t&/p')"
complete --keep-order -c fcolor -a '(set_color --print-colors)' -d 'builtin'
complete --keep-order -c fcolor -a reset -d 'set_color normal'
