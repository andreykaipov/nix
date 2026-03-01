# mkOutOfStoreSymlink wants absolute paths, this makes them easier to specify
# https://github.com/nix-community/home-manager/issues/2085
{ lib
, host
, ...
}:
with lib; {
  options = {
    gitRoot = mkOption {
      type = types.str;
      default = host.gitRoot;
      description = "Absolute path to the git checkout of this repo (for mkOutOfStoreSymlink)";
    };
  };
}
