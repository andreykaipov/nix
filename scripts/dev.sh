#!/bin/sh
#
# Rebuilds our resume whenever any matching .tex file changes. If paired with
# a PDF viewer that automatically reloads modified documents, we've got one
# spicy IDE cooking!

set -eu

if [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "$0"
	exit
fi

find resume.tex patches/ -name '*.tex' | entr -cap "./scripts/build.sh"
