{ master ? import <master> { }
, unstable ? import <unstable> { }
, pkgs ? import <unstable> { }
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
      git-lfs
      go-2fa
      htop
      imagemagick
      jq
      k2tf
      mysql-client
      nmap
      shellcheck
      shfmt
      tre-command
      tree
      upx
      whois
      git-filter-repo
    ])

    (with unstable; [
      bashInteractive_5
      cloudflared
      exiftool
      #docker
      #docker-client
      #runc
      #containerd
      #colima
      #podman
      podman-compose
      #lima
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
      tmux
      twitch
      yq-go
      expect
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
    rich-presence-cli-windows
    rich-presence-cli-linux
    unzip
    win32yank
    wudo
  ];

  forWork = with stable; [
    google-cloud-sdk
    kubectl
    kubernetes-helm
    nodePackages.http-server
    nodePackages.typescript
    nodejs-17_x
    vault
    yarn

    safe
    #bosh-v5_2_2
    #fly-v4_2_5
    #fly-v5_7_2
    #spruce-v1_18_2
  ];

  inherit (stable.lib) optional flatten;
  inherit (stable.stdenv) isDarwin isLinux;
  isWork = builtins.pathExists ~/.config/sh/env.work;
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "";
in
{
  allowUnfree = true;

  packageOverrides = _: with pkgs; {
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

  #virtualisation.podman.dockerCompat = true;
}
