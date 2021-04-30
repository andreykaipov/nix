#!/bin/sh

set -eu

if [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "echo resume.tex | entr -cap ./$0"
fi

git submodule update --init moderncv
cd moderncv
ln -sf ../resume.tex -t .
tectonic resume.tex -o ../out
