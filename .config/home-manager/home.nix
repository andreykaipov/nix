{ lib
, nixpkgs
, nixpkgs-stable
, devenv
, ...
}:
{
  home.packages = with nixpkgs; [
    bat
    cachix
    devenv
    gh
    go
    jq
    neovim
    mutagen
    nixpkgs-fmt
    nodePackages.bash-language-server
    nodejs
    rufo
    terraform-ls
    tmux
    wslu
  ] ++ lib.my.packages;

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.activation = {
    # run arbitrary commands after activation of the following entries
    arbitrary-shell = lib.hm.dag.entryAfter [ "installPackages" "onFilesChange" "reloadSystemd" ] ''
      echo hello
    '';

    ssh-xdg-dir-workaround = lib.hm.dag.entryAfter [ "arbitrary" ] ''
      rm -rf ~/.ssh/config
      ln -sf ~/.config/ssh/config ~/.ssh/config
    '';
  };
}
