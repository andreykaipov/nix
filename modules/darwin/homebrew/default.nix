{
  inputs,
  host,
  ...
}:

{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  # https://github.com/zhaofengli/nix-homebrew/tree/main#a-new-installation
  nix-homebrew = {
    user = host.username;
    enable = true;
    # enableRosetta = true;
    mutableTaps = false;
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
    };
  };

  homebrew = {
    enable = true;

    casks = [
      # Development Tools
      "visual-studio-code"
      "wezterm"

      # Entertainment
      "spotify"
      "discord"

      # Utilities
      "1password"

      # Browsers
      "google-chrome"
    ];

    brews = [
      # CLI formulae installed via Homebrew (for things not in nixpkgs)
      # "gemini-cli"
    ];

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
}
