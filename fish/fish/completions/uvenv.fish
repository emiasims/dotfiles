complete -f -c uvenv
complete -f -c uvenv -n '__fish_use_subcommand' -a "new create" -d "Create a new uv venv"
complete -f -c uvenv -n '__fish_use_subcommand' -a "go activate" -d "Activate an existing uv venv"
complete -f -c uvenv -n '__fish_use_subcommand' -a deactivate -d "Deactivate the current uv venv (to base)"
complete -f -c uvenv -n '__fish_use_subcommand' -a "rm remove" -d "Remove an existing uv venv"
complete -f -c uvenv -n '__fish_use_subcommand' -a "mv move rename" -d "Rename an existing uv venv"
complete -f -c uvenv -n '__fish_use_subcommand' -a "ls list" -d "List all uv venvs"
complete -f -c uvenv -n '__fish_use_subcommand' -a "pick" -d "Pick an existing uv venv with fzf"
complete -f -c uvenv -n '__fish_seen_subcommand_from go activate rm remove mv move rename' -a "(uvenv-list)"
