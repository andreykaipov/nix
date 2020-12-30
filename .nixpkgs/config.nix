{ pkgs }:

let
  common = with pkgs; [
    (callPackage ./cli/dircolors.hex {})
    (callPackage ./cli/neovim {})

    bashInteractive_5
    bash-completion
    go
    go-2fa
    htop
    jq
    nodePackages.http-server
    nodejs-14_x
    shellcheck
    tmux
    tre-command
    tree
    upx
    yarn
  ];

  forDarwin  = with pkgs; [
    (callPackage ./apps/1password {})
    (callPackage ./apps/barrier {})
    (callPackage ./apps/discord {})
    (callPackage ./apps/docker {})
    (callPackage ./apps/iterm2 {})
    (callPackage ./apps/rectangle {})
    (callPackage ./apps/spotify {})

    coreutils
    gifsicle
  ];

  forLinux = with pkgs; [];

  inherit (pkgs.lib) optional flatten;
  inherit (pkgs.stdenv) isDarwin isLinux;

  platform =
    if isDarwin then "macosx"
    else if isLinux then "linux"
    else throw "unsupported platform";
in
{
  packageOverrides = pkgs: with pkgs; {
    mine = buildEnv {
      name = "my-packages";
      paths = flatten [
        common
        (optional isDarwin forDarwin)
        (optional isLinux forLinux)
      ];
    };
  };
}
