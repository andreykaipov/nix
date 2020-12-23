#!/bin/sh

set -e

# see https://nixos.org/manual/nix/stable/#sect-multi-user-installation
# and https://nixos.org/manual/nix/stable/#sect-macos-installation

nixprofiles=/nix/var/nix/profiles
usernixchannels="$nixprofiles/per-user/$USER/channels"

# Install Nix

if ! [ -L "$usernixchannels/manifest.nix" ]; then
    curl -sL https://nixos.org/nix/install | sh -s -- --daemon --darwin-use-unencrypted-nix-store-volume
    . "$nixprofiles/default/etc/profile.d/nix-daemon.sh"
    nix-shell -p nix-info --run "nix-info -m"
fi

# Install Nix modules for macOS

if ! [ -L "$usernixchannels/darwin" ]; then
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    yes | ./result/bin/darwin-installer

    # manual workaround for https://github.com/LnL7/nix-darwin/issues/149
    sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.backup-before-nix-darwin

    . /etc/static/bashrc
    darwin-rebuild switch -I "darwin-config=$HOME/.config/nix/config.nix"

    # delete default location of the nix-darwin config
    rm -rf ~/.nixpkgs
fi
