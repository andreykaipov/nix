#!/bin/sh
set -eu

if [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "$0"
	exit
fi

find resume.tex custom/ -name '*.tex' | entr -cap "./scripts/build.sh"
