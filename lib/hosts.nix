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

  # Auto-discover module subdirectories
  discoverModules =
    dir:
    let
      dirs = attrNames (lib.filterAttrs (_: v: v == "directory") (readDir dir));
    in
    map (m: dir + "/${m}") dirs;

  # Imports a host directory by name and derives homeDirectory and gitRoot from its config
  mkHost =
    hostname:
    let
      raw = import ../hosts/${hostname} { lib = final; };
      homeDirectory =
        if final.isDarwin raw.system then "/Users/${raw.username}" else "/home/${raw.username}";
      gitRoot = "${homeDirectory}/gh/nix";
    in
    lib.recursiveUpdate {
      inherit hostname homeDirectory gitRoot;
      extraModules = [ ];
      desktopBackground = "/System/Library/Desktop Pictures/Solid Colors/Black.png";
      theme = {
        colorscheme = {
          name = "randomhue";
          lighterShade = 30;
          blackBg = false;
        };
        tmux = {
          pane = "subtle";
          border = "none";
          bg = "inactive";
        };
      };
    } raw;

  # Opt-in module bundles discovered recursively from modules/extra/
  # Leaf dirs (containing home.nix/darwin.nix) become { home = [...]; darwin = [...]; }
  # Non-leaf dirs aggregate children and expose them by name for dot-notation
  # e.g. lib.extras.dev = all dev modules, lib.extras.dev.cloud = just cloud
  extras =
    let
      discoverExtras =
        dir:
        let
          entries = readDir dir;
          dirs = attrNames (lib.filterAttrs (_: v: v == "directory") entries);
        in
        lib.genAttrs dirs (
          name:
          let
            child = dir + "/${name}";
            files = readDir child;
            isLeaf = files ? "home.nix" || files ? "darwin.nix";
          in
          if isLeaf then
            (lib.optionalAttrs (files ? "home.nix") { home = [ (child + "/home.nix") ]; })
            // (lib.optionalAttrs (files ? "darwin.nix") { darwin = [ (child + "/darwin.nix") ]; })
          else
            let
              children = discoverExtras child;
              childValues = lib.attrValues children;
              collectKind = kind: lib.concatMap (c: c.${kind} or [ ]) childValues;
            in
            children // { home = collectKind "home"; } // { darwin = collectKind "darwin"; }
        );
    in
    discoverExtras ../modules/extra;
}
