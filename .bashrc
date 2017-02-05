
# enable programmable completion features if it's not enabled already
if ! shopt -oq posix; then
  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -r /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

# if xterm, set title to user@host:dir (branch)
case "$TERM" in xterm*|rxvt*)
        PS1="\n\`if [ \$? = 0 ]; then echo '\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;32m\]\H'; else echo '\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;31m\]\H'; fi\`\[\e[0m\]:\[\e[1;33m\]\w \[\e[1;36m\]$(__git_ps1 '(%s)') \[\e[0;39m\]\n$ "
        ;;
esac

# enable colors for ls and grep
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=yes'
    alias grep='grep --color=auto'
fi

# yellow directories 8-)
LS_COLORS=$LS_COLORS:'di=1;33'

# other aliases
[[ -r "$HOME/.bash_aliases" ]] && . "$HOME/.bash_aliases"

# set the right umask for creating 755 dirs and 644 files
# sometimes it's not set by default...?
umask 0022

