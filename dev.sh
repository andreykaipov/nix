#!/bin/sh

set -eu

if [ -z "${IN_NIX_SHELL-}" ]; then
	f="find resume.tex custom/ -name '*.tex' | entr -cap ./$0"
	nix-shell --run "$f"
fi

git submodule update --init moderncv
cd moderncv
ln -sf ../resume.tex ../custom -t .
tectonic resume.tex -o ../out
