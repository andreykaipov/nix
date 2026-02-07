{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # General packages for development and system management
    bash-completion
    btop
    coreutils
    fd
    killall
    ripgrep
    sqlite
    wget
    zip

    # Encryption and security tools
    age
    age-plugin-yubikey
    gnupg
    libfido2
    _1password-cli

    # Cloud-related tools and SDKs
    # docker
    # docker-compose

    # Media-related packages
    # emacs-all-the-icons-fonts
    # dejavu_fonts
    # ffmpeg
    # fd
    # font-awesome
    # hack-font
    # noto-fonts
    # noto-fonts-color-emoji
    # meslo-lgs-nf

    # Node.js development tools
    # nodejs_24

    # Text and terminal utilities
    # htop
    # jetbrains-mono
    jq
    yq
    # ripgrep
    tree
    # tmux
    # unrar
    # unzip
    # zsh-powerlevel10k

    # Development tools
    # azure-cli
    # azure-cli-extensions.monitor-control-service
    curl
    kubectl
    awscli2

    # misc web things
    hugo
    # rustc
    # cargo
    # openjdk

    # Python packages
    # python3
    # virtualenv

    # lua
    lua
    luarocks
    lua-language-server
    stylua

    # tf
    checkov
    terraform
    terragrunt
    opentofu
    terraform-ls
    tflint

    # nix
    nil
    nixd
    deadnix
    statix
    nixfmt

    # yaml
    yaml-language-server
    yamllint
    # toml
    taplo

    # go
    go
    golangci-lint-langserver
    gopls

    # sh
    nodePackages.bash-language-server
    shellcheck
    shfmt
  ];
}
