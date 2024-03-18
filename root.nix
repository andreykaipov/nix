# module that exposes its own path at `config.root` as an alternative to using
# relative paths. supposed to be kept alongside the flake.nix file, otherwise
# the path will need to be changed. i have no clue if this is good nix or not!
# :D
{ lib
, ...
}:
with lib;
{
  options.root = mkOption {
    type = types.str;
    default = builtins.toString ./.;
  };
}
