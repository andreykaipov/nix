{ lib
, ...
}:
{
  system = "x86_64-linux";
  username = "andrey";
  extraModules = [
    { wsl = true; }
  ];
}
