{
  lib,
  ...
}:
{
  system = "aarch64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAS3g5ZE1lo833a6BunbgwoUL1mVqQqS4MxGdVL5am7F";
  desktopBackground = builtins.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/10-14-Night-6k.jpg";
    sha256 = "09vgyvrjbi5zdrgifdq8zpp9qb9yf70g1npc0ldz3j5kbydnq4fn";
  };
  extraModules = with lib.extras; [
    dev
    ./extra/pi.nix
  ];
}
