#!/bin/sh
#
# Serves our Hugo site locall.y

# Quicker to use our shell.nix instead of the adhoc 'nix run' like in build.sh.
if [ -z "$IN_NIX_SHELL" ]; then
        printf "\e[1;35m%s\e[0m\n" "Starting a Nix shell"
        nix-shell --run "$0"
        exit
fi

set -eu
root="$(git rev-parse --show-toplevel)"
cd "$root"

printf "\e[1;36m%s\e[0m\n" "Watching our resume for changes..."
hugo serve --source website
