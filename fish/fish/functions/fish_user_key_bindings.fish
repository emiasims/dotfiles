function fish_user_key_bindings
    bind -M insert jk "commandline -f cancel backward-char force-repaint; set fish_bind_mode default"
    bind -M default / "fzf_history; and set fish_bind_mode insert"
end
