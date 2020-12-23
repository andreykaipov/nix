{ config, pkgs, ... }:

{
  # Use a custom darwin-configuration.nix location
  environment.darwinConfig = "$HOME/.config/nix/config.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  environment.etc = {
    "sudoers.d/10-nix-commands".text = ''
      %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild, \
                                     /run/current-system/sw/bin/nix*, \
                                     /run/current-system/sw/bin/ln, \
                                     /nix/store/*/activate, \
                                     /bin/launchctl
    '';
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
    };

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = true;
    };

    screencapture.location = "/tmp";
  };
}
