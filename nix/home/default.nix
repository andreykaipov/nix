{ config
, lib
, pkgs
, pkgs-stable
, devenv
, homeConfig
, ...
}:
let
  user = homeConfig.username; # could just use $USER or whoami but why not pass it
in
{
  home.packages = with pkgs; [
    _1password
    bashInteractive
    bash-completion
    # dev tools
    rclone
    socat
    unixtools.netstat
    bat
    autojump
    cachix
    dircolors_hex
    fzf
    gh
    git
    graphviz
    jq
    yq-go
    mutagen
    devenv
    tmux
    nmap
    ripgrep
    fd
    eza
    gnused
    lesspipe

    # langs
    cargo
    go
    nodejs
    python311
    python311Packages.pip
    python311Packages.virtualenv
    terraform

    # lsps
    golangci-lint-langserver
    gopls
    lua-language-server
    marksman
    nil
    nixd
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    nodePackages.vim-language-server
    terraform-ls
    terraform-lsp # unofficial one
    vscode-langservers-extracted
    # yaml-language-server

    # lang-specific dev/diagnostic/lint tools
    deadnix
    git-filter-repo
    lazygit
    nixpkgs-fmt
    rufo
    shellcheck
    shfmt
    statix
    stylua
    nodePackages.textlint
    nodePackages.textlint-rule-common-misspellings
    nodePackages.textlint-rule-no-start-duplicated-conjunction
    nodePackages.textlint-rule-stop-words
    nodePackages.textlint-rule-terminology
    nodePackages.textlint-rule-write-good
    yaml-language-server
    # yamlfix
    # yamlfmt
    # yamllint
  ];


  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./zsh
    ./zellij
  ];

  home.file.".config/nvim".source = ./nvim;
  home.file.".config/nvim".recursive = true;

  home.file.bin.source = ./scripts;
  home.file.bin.recursive = true;

  programs.neovim.enable = true;
  # programs.neovim.package = pkgs.neovim-nightly;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  # programs.neovim.plugins = with pkgs.vimPlugins; [ ]; # managed with LazyVim and lazy.nvim instead

  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
    ''
      if ! grep -q discord /etc/group; then
        echo "Discord group does not exist. Creating it..."
        sudo groupadd discord
      fi
      if ! groups ${user} | grep -qw discord; then
        echo "Adding ${user} to discord group..."
        sudo usermod -a -G discord ${user}
      fi
    ''
    #./scripts/ssh-generate-authorized-keys
    #./scripts/nvim-ensure-plugins
    #./scripts/tmux-ensure-plugins
  ]);
}

#I'm having similar issues trying to replicate similar behaviour to copilot.vim where I open a new line, and immediately get suggestions. I've tried editing copilot.lua settings ;
# (pkgs.writeText "hello" ''
#   echo ${pkgs.bash-completion}
# '')
