{
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  nix-homebrew,
  username,
  ...
}:

{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
    ./packages
  ];

  # https://github.com/zhaofengli/nix-homebrew/tree/main#a-new-installation
  nix-homebrew = {
    user = username;
    enable = true;
    # enableRosetta = true;
    mutableTaps = false;
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
  };

  homebrew.enable = true;
}
