{ master ? import <master> { }
, unstable ? import <unstable> { }
, stable ? import <stable> { }
, ...
}:

let
  common = flatten [
    (with stable; [
      asciinema
      bash-completion
      bat
      binutils
      cmake
      dircolors_hex
      ffmpeg
      fzf
      gifsicle
      go-2fa
      htop
      imagemagick
      jq
      k2tf
      mysql-client
      nmap
      shellcheck
      shfmt
      tmux
      tre-command
      tree
      upx
      whois
      yq-go
    ])

    (with unstable; [
      bashInteractive_5
      cloudflared
      exiftool
      gh
      go
      go-tools
      neofetch
      neovim
      nixpkgs-fmt
      nodePackages.bash-language-server
      sshuttle
      terraform
      terraform-docs
      terraform-ls
      terragrunt
      tflint
      twitch
    ])
  ];

  forDarwin = with stable; [
    coreutils
    iproute2mac
  ];

  forLinux = with stable; [
  ];

  forWSL = with stable; [
    dns-tcp-socks-proxy
    gcc
    gnumake
    unzip
    win32yank
    wudo
  ];

  forWork = with stable; [
    google-cloud-sdk
    kubectl
    kubernetes-helm
    nodePackages.http-server
    nodejs-14_x
    vault
    yarn

    bosh-v5_2_2
    fly-v4_2_5
    fly-v5_7_2
    safe-v0_9_9
    spruce-v1_18_2
  ];

  inherit (stable.lib) optional flatten;
  inherit (stable.stdenv) isDarwin isLinux;
  isWork = builtins.pathExists ~/.config/sh/env.work;
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "";
in
{
  allowUnfree = true;

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
        (callPackage ./apps/1password { })
        (callPackage ./apps/barrier { })
        (callPackage ./apps/discord { })
        (callPackage ./apps/docker { })
        (callPackage ./apps/iterm2 { })
        (callPackage ./apps/rectangle { })
        (callPackage ./apps/spotify { })
      ];
    };
  };
}
