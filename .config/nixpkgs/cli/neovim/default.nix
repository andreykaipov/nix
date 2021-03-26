# There's no section on overlays, but it's sorta similar
#
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
# https://nixos.wiki/wiki/Vim#Custom_setup_without_using_Home_Manager
#
# Plugins refer to the repo name only, i.e. LnL7/vim-nix is just vim-nix. Fully
# qualified repos with author names can be found at:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/generated.nix

#{ pkgs ? import <nixpkgs> {} }:
with import <nixpkgs> {};

neovim.override(old: rec {
  viAlias = true;
  vimAlias = true;
  # configure = {
  #   customRC = builtins.readFile ~/.config/nvim/init.vim;
  # };
})
