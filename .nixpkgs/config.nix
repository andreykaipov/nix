{ pkgs ? import <nixpkgs> {} }:

let
  common = with pkgs; [
    (callPackage ./cli/dircolors.hex {})
    (callPackage ./cli/neovim {})

    tmux
    (callPackage ./cli/tmux-mem-cpu-load {})

    bat
    bashInteractive_5
    bash-completion
    go
    go-2fa
    htop
    jq
    shellcheck
    terraform_0_14
    terragrunt
    tflint
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
    nodePackages.http-server
    nodejs-14_x

    vault
    (callPackage ./cli/safe-v0.9.9 {})

    # todo maybe make this a platform-agnostic script
    (callPackage ./cli/tmux-spotify-info {})
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
