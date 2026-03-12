{
  lib,
  ...
}:
{
  system = "aarch64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAS3g5ZE1lo833a6BunbgwoUL1mVqQqS4MxGdVL5am7F";
  colorscheme = {
    name = "vaporwave";
    lighterShade = 10;
    blackBg = true;
  };
  extraModules = with lib.extras; [
    dev
  ];
}
