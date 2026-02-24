{
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;

  # auto-discover all .nix files in this directory, excluding this one
  currentFile = baseNameOf __curPos.file;
  files = builtins.attrNames (builtins.readDir ./.);
  overlayFiles = builtins.filter (f: f != currentFile && lib.hasSuffix ".nix" f) files;
in
map (f: import ./${f} { inherit inputs; }) overlayFiles
