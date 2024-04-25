# as an alternative to using relative paths, this module that exposes the flake
# paths at config.root and config.gitRoot. it's probably not the most nix-esque
# but i'm digging it 8)

{ flake
, ...
}:
with flake.inputs.nixpkgs.lib;
{
  options = {
    root = mkOption {
      type = types.str;
      default = toString flake;
      description = "Path of the flake directory in the Nix store";
    };

    # this is a bit of a hack to get the local git directory from the flake.
    # when bootstrapping nix, we'll need to write the local dir to this file.
    # this is used for mkOutOfStoreSymlink to be able to specify absolute paths.
    # https://github.com/nix-community/home-manager/issues/2085
    #
    # TODO: alternatively, i suppose i can just hardcode this to
    # "${config.home.homeDirectory}/gh/nix" since that's always where I clone
    # this repo?
    gitRoot = mkOption {
      type = types.str;
      apply = toString;
      default = fileContents ./.gitRoot; # readFile will read the line feed
      #default = "${config.home.homeDirectory}/gh/nix";
      description = "Path of the flake project directory (i.e. outside the Nix store, where it was cloned)";
    };
  };
}
