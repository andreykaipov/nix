{ lib
, ...
}:
{
  system = "aarch64-linux";
  username = "andrey";
  homedir = "/Users/andrey";
  extraModules = [
    # { andrey.agenix.secrets.secret1 = { }; }
  ];
}
