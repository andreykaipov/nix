{ config, pkgs, lib, home-manager, ... }:

let
  user = "andrey";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
      # "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
#  home-manager = {
#    useGlobalPkgs = true;
#    users.${user} = { pkgs, config, lib, ... }:{
#      home = {
#        enableNixpkgsReleaseCheck = false;
#        packages = pkgs.callPackage ./packages.nix {};
#        file = lib.mkMerge [
#          sharedFiles
#          additionalFiles
#        ];
#
#        stateVersion = "23.11";
#      };
#      programs = {
##        home-manager.enable = true;
#      } // import ../shared/home-manager.nix { inherit config pkgs lib; };
#
#      # Marked broken Oct 20, 2022 check later to remove this
#      # https://github.com/nix-community/home-manager/issues/3344
#      manual.manpages.enable = false;
#      
##      xdg.configFile = lib.mapAttrs
##      	(f: _: config.lib.file.mkOutOfStoreSymlink "/home/user/Home/.config/${f}")
##	(builtins.readDir "/Users/andrey/gh/nixos-config/home");
#      #xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink "/Users/andrey/gh/nixos-config/home/tmux";
#    };
  #};

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "${pkgs.wezterm}/Applications/Wezterm.app/"; }
        #{ path = "${pkgs.ghostty}/Applications/Ghostty.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Notes.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        # {
        #   path = "${config.users.users.${user}.home}/Downloads";
        #   section = "others";
        #   options = "--sort name --view grid --display stack";
        # }
      ];
    };
  };
}
