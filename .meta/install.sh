#!/bin/bash

set -e

main() {
    ensure_nix
    nix-env -iA nixpkgs.mine
    nvim +PlugInstall +qa
    ensure_apps
    echo "Done"
}

# see https://nixos.org/manual/nix/stable/#sect-single-user-installation
# and https://nixos.org/manual/nix/stable/#sect-macos-installation
ensure_nix() {
    case "$(uname -s)" in
        Linux)  os=linux ;;
        Darwin) os=darwin ;;
        *)      >&2 echo "Unknown OS"; exit 1;;
    esac

    if [ "$os" = darwin ]; then
        nixargs="--darwin-use-unencrypted-nix-store-volume";
    fi

    nixsh="$HOME/.nix-profile/etc/profile.d/nix.sh"

    if [ -n "$FORCE_REINSTALL" ]; then
        nix-env -e '*'
        rm -f "$nixsh"
    fi

    if ! command -v nix >/dev/null || ! [ -r "$nixsh" ]; then
        export NIX_INSTALLER_NO_MODIFY_PROFILE=1
        curl -sL https://nixos.org/nix/install | sh -s -- --no-daemon $nixargs
        . "$nixsh"
        nix-shell -p nix-info --run "nix-info -m"
    fi

    echo "Nix is installed"
}

ensure_apps() {
    echo "Ensuring apps"

    nix-collect-garbage -d

    IFS=$'\n'
    hashApp() {
        path="$1/Contents/MacOS"; shift
        for bin in $(find "$path" -perm +111 -type f -maxdepth 1 2>/dev/null); do
            md5sum "$bin" | cut -b-32
        done | md5sum | cut -b-32
    }

    mkdir -p ~/Applications/Nix\ Apps

    for app in $(find /nix/store/*my-packages/Applications/*.app -maxdepth 1 -type l); do
        echo "$app"
        name="$(basename "$app")"
        src="$(/usr/bin/stat -f%Y "$app")"
        dst="$HOME/Applications/Nix Apps/$name"
        hash1="$(hashApp "$src")"
        hash2="$(hashApp "$dst")"
        if [ "$hash1" != "$hash2" ]; then
            echo "Current hash of '$name' differs than the Nix store's. Overwriting..."
            sudo rm -rf "$dst"
            cp -R "$src" ~/Applications/Nix\ Apps
        fi
    done
}

main
