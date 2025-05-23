abbr --add l 'ls -lh'
abbr --add la 'ls -Alh'
abbr --add lx 'ls -lXh'
abbr --add --set-cursor lt 'ls -lth %| head'
abbr --add --set-cursor lm 'ls -lh %| more'
abbr --add lb "ls -lh -I'*-bak'"
abbr --add cl 'clear; ls -lh'
abbr --add cls 'clear; ls'
abbr --add fg 'fg'
abbr --add md 'mkdir -p'
abbr --add rd 'rmdir'
abbr --add which 'type -a'
abbr --add whomst 'type -a'
abbr --add d cdh
abbr --add path 'string replace --all : \n "$PATH"'
abbr --add du 'du -sh'
abbr --add crontab 'VIM_CRONTAB=true crontab'
abbr --add vi 'nvim'
abbr --add vid 'nvim-dev'
abbr --add vif 'nvim +"Telescope fd"'
abbr --add vis 'nvim -S (git rev-parse --show-toplevel)/Session.vim'
abbr --add nev 'nvim'
abbr --add nevs 'nvim -S (git rev-parse --show-toplevel)/Session.vim'
abbr --add please 'sudo'
abbr --add np 'numpy'
abbr --add wget 'wget'
abbr --add tls 'tmux ls'
abbr --add tns 'tmux new -s'
abbr --add tat 'tmux attach -t'
abbr --add org 'nvim +OrgAgenda'

if string match -rq -- "kitty" "$TERM"
  abbr --add ssh 'kitty +kitten ssh'
  abbr --add icat 'kitty +kitten icat'
end

abbr --add gst 'git status'
abbr --add gpl 'git pull'
abbr --add gpu 'git push'
abbr --add gad 'git add'
abbr --add gap 'git add --patch'
abbr --add gau 'git add --update'
abbr --add gaup 'git add --update --patch'
abbr --add gd 'git diff'
abbr --add gdc 'git diff --cached'
abbr --add gwd 'git diff --color-words'
abbr --add grh 'git reset HEAD --'
abbr --add gcim 'git commit -m'
abbr --add gbr 'git branch'
abbr --add gco 'git checkout'
abbr --add grih 'git rebase -i (git rev-parse --short origin/HEAD)'
abbr --add glo 'git log --all --oneline --decorate --graph -n 20'

# config defined in functions
abbr --add cst 'config status'
abbr --add cpl 'config pull'
abbr --add cpu 'config push'
abbr --add cad 'config add'
abbr --add cap 'config add --patch'
abbr --add cau 'config add --update'
abbr --add caup 'config add --update --patch'
abbr --add cdf 'config diff'
abbr --add cdc 'config diff --cached'
abbr --add crh 'config reset HEAD --'
abbr --add ccim 'config commit -m'
abbr --add cbr 'config branch'
abbr --add cco 'config checkout'
abbr --add clo 'config log --all --oneline --decorate --graph -n 20'

abbr --add pd prevd
abbr --add nd nextd
