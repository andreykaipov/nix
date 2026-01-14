# HM module that extends the host attrset with helpers requiring module context.
# Imported in lib/config.nix as: (import ../hosts/extend.nix host)
#
# Uses _module.args.host to override the host passed via extraSpecialArgs,
# adding functions that need home-manager's `config` (unavailable outside modules).
#
# Currently adds:
#   host.symlinkTo : path -> { source = ...; }
#     Symlinks any repo path back into the filesystem for live editing.
#     Works with module directories, subdirectories, and individual files.
#     e.g. xdg.configFile."nvim" = host.symlinkTo ./.;
#          creates: ~/.config/nvim → ~/gh/nix/modules/home/nvim
#     e.g. home.file.".ssh/config" = host.symlinkTo ./config;
#          creates: ~/.ssh/config → ~/gh/nix/modules/home/ssh/config
host:

{ config, lib, ... }:

let
  # Store path of the flake source root (e.g. /nix/store/hash-source)
  sourceRoot = builtins.toString ../.;
in
{
  _module.args.host = host // {
    symlinkTo =
      path:
      let
        fullPath = builtins.toString path;
        relPath = lib.removePrefix sourceRoot fullPath;
      in
      {
        source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}${relPath}";
      };
  };
}
