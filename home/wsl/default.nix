{ config
, pkgs
, lib
, host
, ...
}:
with lib;
{
  options.wsl = mkOption {
    type = types.bool;
    default = false;
  };

  # https://discourse.nixos.org/t/difference-between-a-modules-config-property-and-directly-defining-options/14972
  config = mkIf config.wsl {
    home.packages = with pkgs; [
      expect
      gcc
      gnumake
      rich-presence-cli-linux
      rich-presence-cli-windows
      unzip
      win32yank
      wsl-sudo
      wslu
      npiperelay-exe
    ];
  };
}
