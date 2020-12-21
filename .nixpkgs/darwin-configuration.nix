{ config, pkgs, ... }:

let
in
{
  #nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    # GUI stuff
    pkgs.iterm2
    (pkgs.callPackage ./pkgs/discord {})
    (pkgs.callPackage ./pkgs/spotify {})

    # The other stuff
    (pkgs.callPackage ./pkgs/neovim {})
  ];

#  programs.tmux = {
#    enable = true;
#  };

  nixpkgs.overlays = [
    (self: super: {
      bashInteractive = super.bashInteractive_5;
    })
  ];


  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # programs.bash.enable = true;
  # environment.shells = with pkgs; [ bashInteractive fish zsh ];

  environment.variables = {
    EDITOR = "vim";
    BASH_SILENCE_DEPRECATION_WARNING = "1";
  };

  system.patches = [
    (pkgs.writeText "whatever.patch" ''
      --- a/etc/hi2
      +++ b/etc/hi2
      @@ -1 +1,2 @@
       123
      +abc
    '')
  ];

  environment.etc = {
    "sudoers.d/10-nix-commands".text = ''
      %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild, /run/current-system/sw/bin/nix-env, /run/current-system/sw/bin/nix-build, /bin/launchctl, /run/current-system/sw/bin/ln, /nix/store/*/activate
    '';

    "hi/test.conf".text = "hi test";

    # Creates /etc/test
#    test = {
#      text = ''
#        whatever you want to put in the file goes here.
#      '';
#    };
  };

  system.activationScripts.postActivation.text = ''
    echo "${pkgs.bash_5}"
    echo "${config.system.build.applications}/Applications"
  '';

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

  system.activationScripts.applications.text = pkgs.lib.mkForce (''
    rm -rf ~/Applications/Nix\ Apps
    mkdir -p ~/Applications/Nix\ Apps
    for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
      src="$(/usr/bin/stat -f%Y "$app")"
      cp -r "$src" ~/Applications/Nix\ Apps
    done
  '');
}
