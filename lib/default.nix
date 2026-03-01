{
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;

  overlays = map (f: import f { inherit inputs; }) [
    ./apps.nix
    ./hosts.nix
    ./config.nix
  ];
in
lib.extend (lib.composeManyExtensions overlays)
