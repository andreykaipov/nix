{
  latest ? import <unstable> {},
  stable ? import <stable> {},
  ...
}:

let
  common = flatten [
    (with stable; [
      asciinema
      bash-completion
      bashInteractive_5
      bat
      cmake
      dircolors_hex
      ffmpeg
      fzf
      gifsicle
      go
      go-2fa
      htop
      imagemagick
      jq
      shellcheck
      terraform-docs
      tflint
      tmux
      tre-command
      tree
      upx
      yq-go
    ])

    (with latest; [
      neovim
      sshuttle
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
    iproute2mac
  ];

  forLinux = with stable; [];

  forWSL = with stable; [
    gcc
    gnumake
    unzip
    dns-tcp-socks-proxy
    win32yank
  ];

  forWork = with stable; [
    google-cloud-sdk
    kubectl
    kubernetes-helm
    nodePackages.http-server
    nodejs-14_x
    vault
    yarn

    fly-v4_2_5
    safe-v0_9_9
    spruce-v1_18_2
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
