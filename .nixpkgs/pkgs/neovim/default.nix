{ pkgs }:

# see https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
pkgs.neovim.override {
  viAlias = true;
  vimAlias = true;
  configure = {
    customRC = builtins.readFile ~/.config/nvim/init.vim;
    packages.darwin.start = with pkgs.vimPlugins; [
      vim-nix
      vim-go
    ];
  };
}
