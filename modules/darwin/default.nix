{
  lib,
  ...
}:

{
  # Determinate Nix manages the daemon; don't let nix-darwin conflict with it
  nix.enable = false;

  imports = lib.discoverModules ./.;
}
