{ config
, pkgs
, lib
, host
, ...
}:
with lib;
let
  cfg = config.andrey;
in
{
  config = mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [
      coreutils
      iproute2mac
      gnused
      findutils
    ];

    home.activation = lib.my.activationScripts (map toString [
      ''
        echo i am a macos user
      ''
    ]);
  };
}
