{ lib
, ...
}:
{
  system = "aarch64-darwin";
  username = "andrey";
  homeDirectory = "/Users/andrey";
  extraModules = [
    # { andrey.agenix.secrets.secret1 = { }; }
  ];
}
