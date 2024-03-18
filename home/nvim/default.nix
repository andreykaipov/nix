{ pkgs
, ...
}: {
  home.file = {
    # by default these are recursive = false, so they will be symlinks to these files in the nix store
    # meaning we still must do a home-manager switch to actually see changes to nvim regardless
    # ref: https://nix-community.github.io/home-manager/options.xhtml#opt-home.file._name_.recursive
    ".config/nvim/init.lua".source = ./init.lua;
    ".config/nvim/lua".source = ./lua;
    ".config/nvim/after".source = ./after;
    ".config/nvim/ftdetect".source = ./ftdetect;
    # ".config/nvim/ftplugin".source = ./ftplugin;
  };

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
