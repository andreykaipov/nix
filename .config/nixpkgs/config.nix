{ master ? import <master> { }
, unstable ? import <unstable> { }
, pkgs ? import <unstable> { }
, stable ? import <stable> { /* config = { allowUnfree = true; }; */ }
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
      stoken
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
      yq-go
      expect
    ])
  ];

  wsl = with stable; [
    dns-tcp-socks-proxy
    gcc
    gnumake
    rich-presence-cli-windows
    rich-presence-cli-linux
    unzip
    win32yank
    wudo
  ];

  work = with stable; [
    google-cloud-sdk
    kubectl
    safe
    vault
  ];

  inherit (stable.lib) optional flatten;
  inherit (stable.stdenv) isDarwin isLinux;

  isWork = builtins.pathExists ~/.config/sh/env.work;
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "";
in
{
  packageOverrides = _: with pkgs; {
    macos = buildEnv {
      name = "macos";
      paths = flatten [
        common

        [
          coreutils
          iproute2mac
          colima
          docker-client

          # apps; to be moved to '~/Applications/Nix Apps'
          (callPackage ./apps/rectangle { })
          (callPackage ./apps/1password { })
          (callPackage ./apps/spotify { })
          (callPackage ./apps/iterm2 { })
        ]

        (optional isWork work)

        (optional (! isWork) [
          (callPackage ./apps/barrier { })
          (callPackage ./apps/discord { })
        ])
      ];
    };

    linux = buildEnv {
      name = "linux";
      paths = flatten [
        common
        (optional isWSL wsl)
        (optional isWork work)
        (optional (! isWork) [ ])
      ];
    };
  };
}
