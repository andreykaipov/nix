
# e.g. open textbook.pdf
alias open='gnome-open'

# Typical ll, but show dot files first.
alias ll='LC_COLLATE=C ls -alF'

# Allows the creation of nested directories.
alias mkdir='mkdir -p'

# Less with line numbers.
alias less='less -N'

# Gotta stay safe!
alias rm='rm -i'

# View data written (in GB) to /dev/sda1.
# This is only for certain SSDs.
# See http://serverfault.com/a/571741.
alias vdw="sudo smartctl -A /dev/sda1 | awk '/^241/ { print \"GBW: \"(\$10 * 512) * 1.0e-9, \"GB\" }'"

# Easy way to view permissions of things.
alias getperms='stat --format %a'

# Give good permissions to files and dirs accordingly in the working directory.
# 755 to dirs and 644 to files.
alias restorewdperms='find . -type d -exec chmod 755 {} \; &&
                    find . -type f -exec chmod 644 {} \;'

# What is python2?
alias python=python3

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

