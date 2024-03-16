{ lib
, ...
}:
with lib;
with builtins;
let
  # read the current dir and get a list of files, excluding this one
  # ref: https://github.com/NixOS/nix/issues/5897
  currentFile = baseNameOf __curPos.file;
  files = mapAttrsToList (name: _: name) (readDir ./.);
  hostFiles = filter (f: f != currentFile) files;

  # find the hostname from the filename and make an intermmediary list to be
  # able to map each hostname to its config
  mkHost = f:
    let
      hostname = removeSuffix ".nix" f;
    in
    {
      name = hostname;
      value = import ./${f} { inherit lib; } // { inherit hostname; };
    };
in
listToAttrs (map mkHost hostFiles)
