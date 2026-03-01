{
  config,
  pkgs,
  lib,
  host,
  ...
}:
let
  name = "Andrey Kaipov";
  user = "andrey";
  email = "9457739+andreykaipov@users.noreply.github.com";
in
{
  home = {
    inherit (host) username homeDirectory;
    stateVersion = "25.11";
  };

  imports = [
    ./packages
    ./tmux
    ./nvim
  ];

  #programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
  programs = {

    # let home-manager install and manage itself
    home-manager.enable = true;

    # Shared shell configuration
    zsh = {
      enable = true;
      autocd = false;
      cdpath = [ "~/Projects" ];
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
        }
      ];
      initContent = lib.mkBefore ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi

        # Define variables for directories
        export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
        export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
        export PATH=$HOME/.local/share/bin:$PATH

        # Remove history data we don't want to see
        export HISTIGNORE="pwd:ls:cd"

        # Ripgrep alias
        alias search=rg -p --glob '!node_modules/*'  $@

        # nix shortcuts
        shell() {
            nix-shell '<nixpkgs>' -A "$1"
        }

        # pnpm is a javascript package manager
        alias pn=pnpm
        alias px=pnpx

        # Use difftastic, syntax-aware diffing
        alias diff=difft

        # Always color ls and group directories
        alias ls='ls --color=auto'

        alias ll='ls -alh'
        alias vi=nvim
      '';
    };

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        commit.gpgsign = true;
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/config_external")
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/config_external")
      ];
      matchBlocks = {
        "*" = {
          # Set the default values we want to keep
          sendEnv = [
            "LANG"
            "LC_*"
          ];
          hashKnownHosts = true;
        };
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/id_github")
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/id_github")
          ];
        };
      };
    };
  };
}
