{
  lib,
  ...
}:

with builtins;
let
  files = readDir ./.;
  directories = attrNames (lib.filterAttrs (_: v: v == "directory") files);
  hosts = lib.genAttrs directories lib.mkHost;
in
{
  darwin = lib.filterAttrs (_: v: lib.isDarwin v.system) hosts;
  linux = lib.filterAttrs (_: v: lib.isLinux v.system) hosts;
  home = hosts;
}
