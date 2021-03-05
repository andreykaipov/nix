#!/bin/sh
# shellcheck disable=SC1090

set -e

nl="$(printf '\nx')"; nl="${nl%x}"

main() {
    ensure_nix
    ensure_apps
    ensure_nvim
    ensure_tpm
    echo "Done"
}

# see https://nixos.org/manual/nix/stable/#sect-single-user-installation
# and https://nixos.org/manual/nix/stable/#sect-macos-installation
ensure_nix() {
    echo "Ensuring Nix"

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

    nix-channel --update     # update
    nix-env -iA nixpkgs.mine # install
    nix-collect-garbage -d   # cleanup
}

ensure_apps() {
    echo "Ensuring apps"

    IFS="$nl"
    hashApp() {
        path="$1/Contents/MacOS"; shift
        find "$path" -perm +111 -type f -maxdepth 1 2>/dev/null | while read -r bin; do
            md5sum "$bin" | cut -b-32
        done | md5sum | cut -b-32
    }

    mkdir -p ~/Applications/Nix\ Apps

    find /nix/store/*my-packages/Applications/*.app -maxdepth 1 -type l | while read -r app; do
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

ensure_nvim() {
    echo "Ensuring Neovim plugins"

    # nvim itself is installed through nix

    nvim +PlugInstall +qa
}

ensure_tpm() {
    echo "Ensuring TPM for Tmux"

    tpm="$HOME/.tmux/plugins/tpm"
    if [ -d "$tpm" ]; then
        cd "$tpm"
        git pull
    else
        mkdir -p "$tpm"
        git clone https://github.com/tmux-plugins/tpm "$tpm"
    fi

    "$tpm/bin/install_plugins"
}

main
