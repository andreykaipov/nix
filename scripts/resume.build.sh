#!/bin/sh
#
# This script builds our resume by symlinking the files at the resume root into
# the moderncv submodule. Why a submodule? Because Tectonic doesn't pull the
# latest moderncv. Even though I probably don't need the latest... why not?
#
# The output resume.pdf pops out at the root of this repo and is then moved to
# website/static.

set -eu
root="$(git rev-parse --show-toplevel)"
cd "$root"

if ! command -v tectonic >/dev/null; then
        printf "\e[1;35m%s\e[0m\n" "Will invoke Tectonic via Nix..."
        tectonic() { nix run nixpkgs.tectonic -c tectonic "$@"; }
fi

printf "\e[1;36m%s\e[0m\n" "Building our resume..."
git submodule update --init resume/moderncv
cd resume/moderncv
ln -sf ../resume.tex ../patches -t .
export SOURCE_DATE_EPOCH=1
tectonic resume.tex -o "$root"
git clean -f
cd -

printf "\e[1;36m%s\e[0m\n" "Moving resume.pdf to website/static"
mv resume.pdf website/static
