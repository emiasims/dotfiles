function config --wraps='git' --description 'git for HOME config'
  command git --git-dir=$HOME/.cfg --work-tree=$HOME $argv;
end
