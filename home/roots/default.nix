# as an alternative to using relative paths around the other modules, this
# module exposes the flake root and git root paths

{ lib
, host
, config
, ...
}:
with lib; {
  options = {
    flakeRoot = mkOption {
      type = types.str;
      default = host.flakeRoot;
      description = "Path of the flake directory in the Nix store";
    };

    # mkOutOfStoreSymlink wants absolute paths, this makes them easier to specify
    # https://github.com/nix-community/home-manager/issues/2085
    gitRoot = mkOption {
      type = types.str;
      apply = toString;
      # default = fileContents ./.gitRoot; # readFile will read the line feed
      default = "${config.home.homeDirectory}/gh/nix";
      description = "Path of the flake project directory (i.e. outside the Nix store, where it was cloned)";
    };
  };
}
