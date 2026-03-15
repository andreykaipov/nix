{
  lib,
  ...
}:

{
  # Determinate Nix manages the daemon; don't let nix-darwin conflict with it
  nix.enable = false;

  # Determinate Nix reads this for user customizations (see /etc/nix/nix.conf)
  environment.etc."nix/nix.custom.conf".text =
    let
      cachix = {
        "nix-community.cachix.org" = "mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        "nix-community-neovim-nightly-overlay.cachix.org" = "WlgMaITRm3UMnm28W1mM8hBDTdBs0chO54bens56oVo=";
      };
      substituters = lib.mapAttrsToList (h: _: "https://${h}") cachix;
      publicKeys = lib.mapAttrsToList (h: k: "${h}-1:${k}") cachix;
    in
    ''
      extra-substituters = ${lib.concatStringsSep " " substituters}
      extra-trusted-public-keys = ${lib.concatStringsSep " " publicKeys}
    '';

  # nix-darwin's programs.zsh controls /etc/zshrc, which runs before our user
  # zshrc (~/.config/zsh/.zshrc). By default it runs compinit and prompt init
  # there, but home-manager already does both. Disable them here so /etc/zshrc
  # doesn't duplicate work and delay p10k instant prompt.
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  imports = lib.discoverModules ./.;
}
