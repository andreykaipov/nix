{ homebrew-core, homebrew-cask, homebrew-bundle, ... }:

let user = "andrey"; in

{
  # https://github.com/zhaofengli/nix-homebrew/tree/main#a-new-installation
  nix-homebrew = {
    inherit user;
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
}
