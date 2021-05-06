#!/bin/sh
#
# This script builds our resume by symlinking the files at the root into the
# moderncv submodule. Why use a submodule? Because we're bleeding edge dude.

set -eu

if [ -z "${CI-}" ] && [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "$0"
	exit
fi

printf "\e[1;33m%s\e[0m\n" "Running in nix-shell or in CI"

mkdir -p out
git submodule update --init moderncv
cd moderncv
ln -sf ../resume.tex ../patches -t .
tectonic resume.tex -o ../out
