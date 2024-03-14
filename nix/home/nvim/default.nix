{ pkgs
, ...
}: {
  home.file.".config/nvim".source = ./.;
  home.file.".config/nvim".recursive = true;

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
