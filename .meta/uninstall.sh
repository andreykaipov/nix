#!/bin/sh

# Uninstall Nix modules for macOS

nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
yes | ./result/bin/darwin-uninstaller

# Uninstall Nix

sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
sudo rm -rf /etc/nix /nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.nixpkgs

# Delete the APFS volume created by the macOS installation for the Nix store at /nix

diskutil unmountDisk force /nix
diskutil apfs deleteVolume 'Nix Store'

if grep -q LABEL=Nix /etc/fstab; then
    echo "Hey! Remove the Nix Store entry from /etc/fstab using 'sudo vifs'"
fi

if grep -q ^nix$ /etc/synthetic.conf; then
    echo "Hey! Remove the nix entry from /etc/synthetic.conf"
fi

sudo rm -rf /nix
