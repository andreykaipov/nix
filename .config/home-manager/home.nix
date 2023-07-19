{ config
, lib
, pkgs
, pkgs-stable
, devenv
, ...
}:
{
  home.packages = with pkgs; [
    bashInteractive
    bash-completion
    bat
    cachix
    devenv
    dircolors_hex
    git
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
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.home-manager.enable = true;

  home.activation = lib.my.activationScripts (map toString [
    ./scripts/ssh-generate-authorized-keys
    ./scripts/nvim-ensure-plugins
    ./scripts/tmux-ensure-plugins
  ]);
}
