{
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;

  # auto-discover all .nix files in this directory, excluding this one
  currentFile = baseNameOf __curPos.file;
  files = builtins.attrNames (builtins.readDir ./.);
  libFiles = builtins.filter (f: f != currentFile && lib.hasSuffix ".nix" f) files;
  libs = map (f: import ./${f} { inherit inputs; }) libFiles;
in
lib.extend (lib.composeManyExtensions libs)
