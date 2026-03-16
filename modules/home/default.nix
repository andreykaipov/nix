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

  # GUI apps come from homebrew casks, not nix packages
  # So we disable linking into /Applications/Home Manager Apps
  # https://github.com/nix-community/home-manager/issues/8336#issuecomment-3696615357
  targets.darwin.copyApps.enable = false;
  targets.darwin.linkApps.enable = false;

  # Workaround for builtins.toFile options.json warning with Determinate Nix
  # https://github.com/nix-community/home-manager/issues/7935
  manual.manpages.enable = false;
}
