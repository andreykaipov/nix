{ pkgs }:

# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
#
# Plugins refer to the repo name only, i.e. LnL7/vim-nix is just vim-nix. Fully
# qualified repos with author names can be found at:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/generated.nix
pkgs.neovim.override {
  viAlias = true;
  vimAlias = true;
  configure = {
    customRC = builtins.readFile ~/.config/nvim/init.vim;
  };
}
