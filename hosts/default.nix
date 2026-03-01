{ lib
, ...
}:
with lib; with builtins;
let
  files = readDir ./.;
  directories = attrNames (lib.filterAttrs (_: v: v == "directory") files);
  mkHost = dir:
    let
      hostname = dir;
    in
      {
        name = hostname;
        value = import ./${dir} { inherit lib; } // { inherit hostname; };
      };

  hosts = listToAttrs (map mkHost directories);
  # hosts' = mapAttrs (_: v: v // { homeDirectory = "/Users/andrey"; }) hosts;
  hosts' = mapAttrs (_: v: v) hosts;
in
  {
    all = hosts';
    darwin = filterAttrs (_: v: strings.hasSuffix "darwin" v.system) hosts';

    # for lib.mkConfig
    home = hosts';
  }
