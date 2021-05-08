#!/bin/sh
#
# Rebuilds our resume whenever any matching .tex file changes. If paired with
# a PDF viewer that automatically reloads modified documents, we've got one
# spicy IDE cooking!

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
cd resume
find resume.tex patches/ -name '*.tex' | entr -cap "$root/scripts/resume.build.sh"
