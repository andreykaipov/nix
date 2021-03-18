#!/bin/sh
# shellcheck disable=SC2024

set -e

main() {
    echo "Running macOS configuration"
    enable_remote_login
    fix_dns
    fix_hosts
    augment_sudoers
    # augment_pamd_sudo
    echo "macOS configuration good"
}

enable_remote_login() {
    if nc -z localhost 22 >/dev/null; then return; fi

    sudo systemsetup -getremotelogin
    sudo systemsetup -setremotelogin on || {
        >&2 echo "You have to go to Security & Privacy and grant iTerm (or whatever you're using) full disk access"
    }
}

fix_dns() {
    if [ "$(scutil --dns | grep -E '1.1.1.1|8.8.8.8' | sort | uniq | wc -l)" -eq 2 ]; then return; fi

    # networksetup -listallnetworkservices
    sudo networksetup -setsearchdomains Wi-Fi empty
    sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
}

fix_hosts() {
    if grep -q '# added by install.macos.sh' /etc/hosts; then return; fi

    sudo tee /etc/hosts >/dev/null <<EOF
# added by install.macos.sh

# localhost
127.0.0.1	localhost
255.255.255.255	broadcasthost
::1             localhost

# Docker desktop
127.0.0.1 kubernetes.docker.internal
EOF
}

augment_sudoers() {
    if [ -r /etc/sudoers.d/extra ] && [ -z "$FORCE_REINSTALL" ]; then return; fi

    tee /tmp/sudoers.augment >/dev/null <<EOF
# added by install.macos.sh

# passwordless sudo things
$(if [ -r ~/.config/sh/env.work ]; then echo '
%admin ALL=(ALL:ALL) NOPASSWD: ALL'; else echo "
%admin ALL=(ALL:ALL) NOPASSWD: \\
                               $(command -v pmset) ,\\
                               $(command -v cat)   ,\\
                               $(command -v grep)  ,\\
                               $(command -v rm) -rf $HOME/Applications/Nix Apps/*
"; fi)
EOF
    visudo -cf /tmp/sudoers.augment || exit 1

    # check if no conflicts with existing sudoers file
    sudo cat /etc/sudoers /tmp/sudoers.augment > /tmp/sudoers.full
    visudo -cf /tmp/sudoers.full || exit 1

    sudo mv /tmp/sudoers.augment /etc/sudoers.d/extra
    sudo chown root /etc/sudoers.d/extra
}

augment_pamd_sudo() {
    if grep -q '# added by install.macos.sh' /etc/pam.d/sudo; then return; fi

    sudo tee -a /etc/pam.d/sudo >/dev/null <<EOF
# added by install.macos.sh
# use touch ID for sudo
auth sufficient pam_tid.so
EOF
}

main "$@"
