# HM module that extends the host attrset with helpers requiring module context.
# Imported in lib/config.nix as: (import ../hosts/extend.nix host)
#
# Uses _module.args.host to override the host passed via extraSpecialArgs,
# adding functions that need home-manager's `config` (unavailable outside modules).
#
# Currently adds:
#   host.symlinkTo : path -> { source = ...; }
#     Symlinks ~/.config/<name> back into the repo for live editing.
#     e.g. xdg.configFile."nvim" = host.symlinkTo ./.;
#          creates: ~/.config/nvim → ~/gh/nix/modules/home/nvim
host:

{ config, ... }:

{
  _module.args.host = host // {
    symlinkTo =
      path:
      let
        name = builtins.baseNameOf (builtins.toString path);
      in
      {
        source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/${name}";
      };
  };
}
