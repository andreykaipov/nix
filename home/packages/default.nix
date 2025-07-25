{ pkgs
, pkgs-stable
, ...
}:
{
  home.packages = with pkgs; [
    # misc non-lang specific dev tools
    _1password
    # azure-cli # homebrew...
    azurite
    bat
    upx
    cachix
    coreutils
    devbox
    dircolors_hex
    eza
    fd
    fzf
    graphviz
    jq
    lesspipe
    mutagen
    nmap
    rclone
    imagemagick_light
    ripgrep
    socat
    yq-go
    neofetch
    qmk

    # lint
    nodePackages.prettier

    # sh
    nodePackages.bash-language-server
    shellcheck
    shfmt

    # go
    go
    golangci-lint-langserver
    gopls

    # tf
    checkov
    terraform
    terragrunt
    opentofu
    terraform-ls
    tflint

    # nix
    nil
    # nixd # https://github.com/nix-community/nixd/issues/357
    deadnix
    statix
    nixpkgs-fmt

    # lua
    lua
    luarocks
    lua-language-server
    stylua

    # yaml
    yaml-language-server
    yamllint
    # pkgs-stable.yamlfix # https://github.com/NixOS/nixpkgs/issues/294005
    # yamlfmt # probably don't need these since lsp does enough

    # rust
    cargo

    # ruby
    rufo

    # python
    python311
    python311Packages.pip
    python311Packages.virtualenv

    # web crap
    nodejs
    nodePackages.typescript-language-server
    vscode-langservers-extracted

    # text
    marksman
    nodePackages.textlint
    nodePackages.textlint-rule-common-misspellings
    nodePackages.textlint-rule-no-start-duplicated-conjunction
    nodePackages.textlint-rule-stop-words
    nodePackages.textlint-rule-terminology
    nodePackages.textlint-rule-write-good

    # tex
    texlab

    # vim
    nodePackages.vim-language-server
  ];
}
