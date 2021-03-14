#!/bin/sh
# shellcheck disable=SC1090

set -e

main() {
    echo "Running within a WSL distro"
    fix_resolvconf
    prep_nix
    echo "WSL configuration good"
}

fix_resolvconf() {
    if grep -q '# added by install.wsl.sh' /etc/resolv.conf; then return; fi
    if grep -q 'generateResolvConf = false' /etc/wsl.conf; then return; fi

    sudo chattr -i /etc/resolv.conf 2>/dev/null || true
    sudo rm /etc/resolv.conf
    sudo tee /etc/resolv.conf <<EOF
# added by install.wsl.sh
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    sudo chattr +i /etc/resolv.conf

    sudo tee -a /etc/wsl.conf <<EOF
[network]
generateResolvConf = false
EOF
}

# for some reason network configuration on WLS goes out for custom nixpkgs
# without sandbox disabled, whatever that is. see the following only
# semi-related threads:
# https://nathan.gs/2019/04/12/nix-on-windows
# https://github.com/NixOS/nix/issues/2472
# https://github.com/NixOS/nix/issues/2651
prep_nix() {
    if grep -q '^sandbox = false' /etc/nix/nix.conf; then return; fi

    sudo mkdir -p /etc/nix
    sudo tee /etc/nix/nix.conf <<EOF
sandbox = false
EOF
}

main "$@"
