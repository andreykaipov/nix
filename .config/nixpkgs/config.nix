{ nixpkgs ? import <nixpkgs> { }
, unstable ? import <nixpkgs> { }
, stable ? import <stable> { /* config = { allowUnfree = true; }; */ }
, ...
}:

let
  common = flatten [
    (with stable; [
      #      asciinema
      #      bash-completion
      #      bat
      #      binutils
      #      cmake
      #      csvkit
      #      entr
      #      ffmpeg
      #      fzf
      #      gifsicle
      #      git-filter-repo
      #      git-lfs
      #      go-2fa
      #      htop
      #      imagemagick
      #      jp
      #      jq
      #      k2tf
      #      kind
      #      mysql-client
      #      nixFlakes
      #      nmap
      #      nodejs
      #      powershell
      #      python38Packages.scapy
      #      shellcheck
      #      shfmt
      #      sshpass
      #      stoken
      #      tre-command
      #      tree
      #      upx
      #      whois
      #      wireguard-go
      #      wireguard-tools
    ])

    (with unstable; [
      #      bashInteractive_5
      #      cloudflared
      #      direnv
      #      exiftool
      #      expect
      #      gh
      #      go
      #      go-tools
      #      neofetch
      #      neovim
      #      nixpkgs-fmt
      #      nodePackages.bash-language-server
      #      sshuttle
      #      terraform
      #      terraform-docs
      #      terraform-ls
      #      terragrunt
      #      tflint
      #      tmux
      #      yq-go
    ])
  ];

  wsl = with stable; [
    #dns-tcp-socks-proxy
    #gcc
    #gnumake
    ##rich-presence-cli-linux
    ##rich-presence-cli-windows
    #unzip
    #win32yank
    #wudo
  ];

  work = with stable; [
    kubectl
    safe
    vault
  ];

  inherit (stable.lib) optional flatten;
  inherit (stable.stdenv) isDarwin isLinux;

  #isWork = builtins.pathExists ~/.config/sh/env.work;
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME") != "";
in
{
  packageOverrides = _: with stable; {
    macos = buildEnv {
      name = "macos";
      paths = flatten [
        common

        [
          coreutils
          gnugrep
          gnused
          iproute2mac

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

    macos-broken = buildEnv {
      name = "macos-broken";
      paths = [
        _1password
      ];
    };

    linux = buildEnv
      {
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
