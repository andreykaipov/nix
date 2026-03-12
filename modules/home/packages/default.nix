{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # General packages for development and system management
    _1password-cli
    bash-completion
    btop
    coreutils
    fd
    ripgrep
    sqlite
    wget
    zip

    # Text and terminal utilities
    jq
    yq
    tree
    curl

    # Shell
    nodePackages.bash-language-server
    shellcheck
    shfmt

    # Nix
    nil
    nixd
    deadnix
    statix
    nixfmt
  ];
}
