{ pkgs
, ...
}:
let
  substituters = {
    "https://cache.nixos.org" = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    "https://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
in
{
  nix = {
    package = pkgs.nixVersions.latest; # pkgs.nixUnstable;
    checkConfig = true;
    settings = {
      allow-dirty = true;
      warn-dirty = true;
      pure-eval = false;
      use-xdg-base-directories = false;
      experimental-features = [ "nix-command" "flakes" ];

      # builds
      always-allow-substitutes = false;
      substitute = true; # false to force building from source
      # substituters = builtins.attrNames substituters;
      trusted-substituters = builtins.attrNames substituters;
      trusted-public-keys = builtins.attrValues substituters;
      connect-timeout = 10;
      download-attempts = 5;
      max-jobs = "auto";

      # store
      auto-optimise-store = true;
      keep-build-log = true;
      keep-derivations = false;
      keep-outputs = false;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 21d";

      # https://nix-community.github.io/home-manager/options.xhtml#opt-nix.gc.frequency
      frequency = if pkgs.stdenv.isDarwin then "weekly" else "1week";
    };
  };
}
