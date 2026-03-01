{
  pkgs,
  host,
  neovim-nightly,
  ...
}:

{
  xdg.configFile."nvim" = host.symlinkTo ./.;
  programs.neovim = {
    package = neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
