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

    # Fonts
    comic-mono
    nerd-fonts.comic-shanns-mono # verify name: fc-list | grep -i shanns

    # Text and terminal utilities
    glow
    jq
    yq
    tree
    curl

    # Shell
    bash-language-server
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
