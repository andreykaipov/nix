{
  lib,
  ...
}:

with builtins;
let
  files = readDir ./.;
  directories = attrNames (lib.filterAttrs (_: v: v == "directory") files);
  hosts = lib.genAttrs directories lib.mkHost;
  getHosts = check: lib.filterAttrs (_: v: check v.system) hosts;
in
{
  darwin = getHosts lib.isDarwin;
  linux = getHosts lib.isLinux;
  home = getHosts (_: true);
}
