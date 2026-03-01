{
  lib,
  ...
}:

let
  homeDirectory = "/Users/andrey";
in
{
  system = "aarch64-darwin";
  username = "andrey";
  inherit homeDirectory;
  gitRoot = "${homeDirectory}/gh/nix";
  extraModules = [
  ];
}
