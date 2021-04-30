#!/bin/sh

set -eu

if [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "echo resume.tex | entr -cap ./$0"
fi

git submodule update --init moderncv
ln -f ../resume.tex -t moderncv
cd moderncv
tectonic resume.tex -o ../
