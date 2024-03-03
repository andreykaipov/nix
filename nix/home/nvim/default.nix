{ inputs
, pkgs
, ...
}: {
  home.file.".config/nvim".source = ./.;
  home.file.".config/nvim".recursive = true;

  programs.neovim.enable = true;
  # programs.neovim.package = pkgs.neovim-nightly;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  # programs.neovim.plugins = with pkgs.vimPlugins; [ ]; # managed with LazyVim and lazy.nvim instead
}
