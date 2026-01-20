{
  lib,
  host,
  ...
}:

{
  imports = lib.discoverModules ./.;

  home = {
    inherit (host) username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  news.display = "silent";
}
