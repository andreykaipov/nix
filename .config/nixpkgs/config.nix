{
  master ? import <master> {},
  unstable ? import <unstable> {},
  stable ? import <stable> {},
  ...
}:

let
  common = flatten [
    (with stable; [
      asciinema
      bash-completion
      bat
      cmake
      dircolors_hex
      ffmpeg
      fzf
      gifsicle
      go-2fa
      htop
      imagemagick
      jq
      shfmt
      shellcheck
      tmux
      tre-command
      tree
      upx
      yq-go
      mysql-client
    ])

    (with unstable; [
      go
      exiftool
      bashInteractive_5
      neovim
      sshuttle
      terraform-docs
      tflint
    ])

    (with master; [
      terragrunt
      terraform_0_15
    ])
  ];

  forDarwin = with stable; [
    coreutils
    iproute2mac
  ];

  forLinux = with stable; [
    neofetch
  ];

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
    bosh-v5_2_2
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

    macos-apps = buildEnv {
      name = "my-macos-apps";
      paths = [
        (callPackage ./apps/1password {})
        (callPackage ./apps/barrier {})
        (callPackage ./apps/discord {})
        (callPackage ./apps/docker {})
        (callPackage ./apps/iterm2 {})
        (callPackage ./apps/rectangle {})
        (callPackage ./apps/spotify {})
      ];
    };
  };
}
