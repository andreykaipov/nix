#!/bin/sh
#
# This script builds our resume by symlinking the files at the resume root into
# the moderncv submodule. Why a submodule? Because Tectonic doesn't pull the
# latest moderncv. Even though I probably don't need the latest... why not?

set -eu

if [ -z "${CI-}" ] && [ -z "${IN_NIX_SHELL-}" ]; then
	nix-shell --run "$0"
	exit
fi

printf "\e[1;33m%s\e[0m\n" "Running in nix-shell or in CI"

root="$(git rev-parse --show-toplevel)"
cd "$root"
git submodule update --init resume/moderncv
cd resume/moderncv
ln -sf ../resume.tex ../patches -t .
tectonic resume.tex -o "$root/site"
git clean -f
