{ config
, lib
, pkgs
, pkgs-stable
, devenv
, ...
}:
{
  home.packages = with pkgs;
    [
      _1password
      bashInteractive
      bash-completion
      bat
      cachix
      devenv
      dircolors_hex
      git
      gh
      go
      graphviz
      jq
      yq-go
      neovim
      nmap
      mutagen
      nixpkgs-fmt
      nodePackages.bash-language-server
      nodejs
      rclone
      rufo
      shfmt
      shellcheck
      terraform
      terraform-ls
      tmux
    ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.home-manager.enable = true;

  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
    ./scripts/ssh-generate-authorized-keys
    ./scripts/nvim-ensure-plugins
    ./scripts/tmux-ensure-plugins
  ]);
}

# (pkgs.writeText "hello" ''
#   echo ${pkgs.bash-completion}
# '')
