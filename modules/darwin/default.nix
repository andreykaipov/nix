{ agenix, config, pkgs, home-manager, nix-homebrew, ... }:

let user = "andrey"; in

{
  imports = [
    ../shared

    nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix

    agenix.darwinModules.default
    ./secrets.nix

    home-manager.darwinModules.home-manager
    ./home-manager.nix
  ];

  # Setup user, packages, programs
  nix = {
    enable = false;

#    package = pkgs.nix;
#
#    settings = {
#      trusted-users = [ "@admin" "${user}" ];
#      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
#      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
#    };
#
#    gc = {
#      automatic = true;
#      interval = { Weekday = 0; Hour = 2; Minute = 0; };
#      options = "--delete-older-than 30d";
#    };
#
#    extraOptions = ''
#      experimental-features = nix-command flakes
#    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default
  ] ++ (import ../shared/packages.nix { inherit pkgs; });

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        "com.apple.swipescrolldirection" = false; # "natural" scrolling is off (IT IS NOT NATURAL)
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;

        # magnify on hover
        magnification = true;
        largesize = 16;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=60
  '';
}
