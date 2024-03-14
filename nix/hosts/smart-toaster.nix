{ lib
, ...
}:
{
  system = "aarch64-darwin";
  username = "andreykaipov";
  homedir = "/Users/andrey";
  extraModules = [
    ./macos.nix
  ];
}
