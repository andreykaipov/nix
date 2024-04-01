{ config
, pkgs
, ...
}: {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.gitRoot}/home/nvim";

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
