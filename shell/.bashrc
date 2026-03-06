source $HOME/.profile

# Color definitions
CBLK='\[\e[0;30m\]' # Black - Regular
CRED='\[\e[0;31m\]' # Red
CGRN='\[\e[0;32m\]' # Green
CYLW='\[\e[0;33m\]' # Yellow
CBLU='\[\e[0;34m\]' # Blue
cpur='\[\e[0;35m\]' # Purple
CCYN='\[\e[0;36m\]' # Cyan
CWHT='\[\e[0;37m\]' # White
BBLK='\[\e[1;30m\]' # Black - Bold
BRED='\[\e[1;31m\]' # Red
BGRN='\[\e[1;32m\]' # Green
BYLW='\[\e[1;33m\]' # Yellow
BBLU='\[\e[1;34m\]' # Blue
BPUR='\[\e[1;35m\]' # Purple
BCYN='\[\e[1;36m\]' # Cyan
BWHT='\[\e[1;37m\]' # White
UBLK='\[\e[4;30m\]' # Black - Underline
URED='\[\e[4;31m\]' # Red
UGRN='\[\e[4;32m\]' # Green
UYLW='\[\e[4;33m\]' # Yellow
UBLU='\[\e[4;34m\]' # Blue
UPUR='\[\e[4;35m\]' # Purple
UCYN='\[\e[4;36m\]' # Cyan
UWHT='\[\e[4;37m\]' # White
KBLK='\[\e[40m\]'   # Black - Background
KRED='\[\e[41m\]'   # Red
KGRN='\[\e[42m\]'   # Green
KYLW='\[\e[43m\]'   # Yellow
KBLU='\[\e[44m\]'   # Blue
KPUR='\[\e[45m\]'   # Purple
KCYN='\[\e[46m\]'   # Cyan
KWHT='\[\e[47m\]'   # White
NC='\[\e[0m\]'    # Text Reset

# Prompt
if [ x$TERM == xdumb ]; then
  PS1="\u@\h:\w \$ "
else
  PS1="\n${CCYN}\u${NC}@${CGRN}\h${NC}:${BYLW}\w ${NC}\n\$ "
fi

case "$TERM" in
  *-256color)
    alias ssh='TERM=${TERM%-256color} ssh'
    ;;
  *)
    POTENTIAL_TERM=${TERM}-256color
    POTENTIAL_TERMINFO=${TERM:0:1}/$POTENTIAL_TERM

    # better to check $(toe -a | awk '{print $1}') maybe?
    BOX_TERMINFO_DIR=/usr/share/terminfo
    [[ -f $BOX_TERMINFO_DIR/$POTENTIAL_TERMINFO ]] && \
      export TERM=$POTENTIAL_TERM

    HOME_TERMINFO_DIR=$HOME/.terminfo
    [[ -f $HOME_TERMINFO_DIR/$POTENTIAL_TERMINFO ]] && \
      export TERM=$POTENTIAL_TERM
    ;;
esac

export EDITOR=$(which vim)

if [ $(uname -s) == "Darwin" ]; then
  export LSCOLORS=exfxcxdxbxegedabagacad
else
  export LSCOLORS=Gxfxcxdxbxegedabagacad # Maybe?
fi

# [[ -f /usr/share/bash-completion/bash_completion ]] && \
#   source /usr/share/bash-completion/bash_completion

#------------------------------------------////
# bash options
#------------------------------------------////
export HISTCONTROL=erasedups
export HISTSIZE=5000
export HISTIGNORE="&:[ ]*:clear:l{,s,a}:exit"

# useful things..
shopt -s histappend histreedit histverify
shopt -s cdspell
shopt -s extglob # extended bash completion
shopt -s checkwinsize
shopt -s no_empty_cmd_completion
shopt -s cmdhist


#------------------------------------------////
# Aliases
#------------------------------------------////
pushd()
{
  if [ $# -eq 0 ]; then
    DIR="${HOME}"
  else
    DIR="$1"
  fi

  builtin pushd "${DIR}" > /dev/null
}

alias cd='pushd'

#------------------------------------------////
# Color man pages:
#------------------------------------------////

export LESS_TERMCAP_mb=$'\E[01;31m'      # begin blinkin
export LESS_TERMCAP_md=$'\E[01;31m'      # begin bold
export LESS_TERMCAP_me=$'\E[0m'          # end mode
export LESS_TERMCAP_se=$'\E[0m'          # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'   # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'          # end underline
export LESS_TERMCAP_us=$'\E[01;32m'      # begin underline

# If we have a machine specific thing to source, do et.
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
# [ -d $HOME/miniconda3/bin ] && export PATH=$HOME/miniconda3/bin:$PATH
[ -d "$HOME/local/src/fzf" ] && source "$HOME/local/src/fzf/shell/key-bindings.bash"

# >>> conda initialize >>>
# <<< conda initialize <<<
