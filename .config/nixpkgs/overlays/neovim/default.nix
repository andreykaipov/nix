self: super: {
  neovim = super.neovim.override(old: rec {
    viAlias = true;
    vimAlias = true;
    # configure = {
    #   customRC = builtins.readFile ~/.config/nvim/init.vim;
    # };
  });
}
