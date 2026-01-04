{
  inputs,
  ...
}:

with builtins;
let
  inherit (inputs.nixpkgs) lib;
in
final: _: {
  # Check if a system string is darwin or linux
  isDarwin = system: lib.strings.hasSuffix "darwin" system;
  isLinux = system: lib.strings.hasSuffix "linux" system;

  # Imports a host directory by name and derives homeDirectory and gitRoot from its config
  mkHost =
    hostname:
    let
      raw = import ../hosts/${hostname} { inherit lib; };
      homeDirectory =
        if final.isDarwin raw.system then "/Users/${raw.username}" else "/home/${raw.username}";
      gitRoot = "${homeDirectory}/gh/nix";
    in
    { inherit hostname homeDirectory gitRoot; } // raw;
}
