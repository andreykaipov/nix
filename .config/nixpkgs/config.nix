{
  latest ? import <unstable> {},
  stable ? import <stable> {},
  ...
}:

let
  common = flatten [
    (with stable; [
      dircolors_hex
      neovim
      asciinema
      bash-completion
      bashInteractive_5
      bat
      cmake
      ffmpeg
      fzf
      gifsicle
      go
      go-2fa
      htop
      imagemagick
      jq
      shellcheck
      sshuttle
      terraform-docs
      tflint
      tmux
      tre-command
      tree
      upx
      yq-go
    ])

    (with latest; [
      terraform_0_14
      terragrunt
    ])
  ];

  forDarwin = with stable; [
    (callPackage ./apps/1password {})
    (callPackage ./apps/barrier {})
    (callPackage ./apps/discord {})
    (callPackage ./apps/docker {})
    (callPackage ./apps/iterm2 {})
    (callPackage ./apps/rectangle {})
    (callPackage ./apps/spotify {})
    coreutils
    (import ./cli/iproute2mac)
  ];

  forLinux = with stable; [];

  forWSL = with stable; [
    gcc
    gnumake
    unzip
    (import ./cli/dns-tcp-socks-proxy)
    (import ./cli/win32yank)
  ];

  forWork = with stable; [
    (callPackage ./cli/fly-v4.2.5 {})
    (callPackage ./cli/safe-v0.9.9 {})
    spruce-v1_18_2
    google-cloud-sdk
    kubectl
    kubernetes-helm
    nodePackages.http-server
    nodejs-14_x
    vault
    yarn
  ];

  inherit (stable.lib) optional flatten;
  inherit (stable.stdenv) isDarwin isLinux;
  isWork = builtins.pathExists ~/.config/sh/env.work;
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "";
in
{
  packageOverrides = pkgs: with stable; {
    mine = buildEnv {
      name = "my-packages";
      paths = flatten [
        common
        (optional isDarwin forDarwin)
        (optional isLinux forLinux)
        (optional isWSL forWSL)
        (optional isWork forWork)
      ];
    };
  };
}
