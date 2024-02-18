{ config
, lib
, pkgs
, pkgs-stable
, devenv
, homeConfig
, ...
}:
let
  user = homeConfig.username; # could just use $USER or whoami but why not pass it
in
{
  home.packages = with pkgs;
    [
      _1password
      bashInteractive
      bash-completion
      # dev tools
      rclone
      socat
      unixtools.netstat
      bat
      cachix
      dircolors_hex
      gh
      git
      graphviz
      jq
      yq-go
      mutagen
      devenv
      tmux
      nmap
      zellij

      # langs
      cargo
      go
      nodejs
      python311
      python311Packages.pip
      python311Packages.virtualenv
      terraform

      # lsps
      gopls
      lua-language-server
      nil
      nixd
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.vim-language-server
      terraform-ls
      vscode-langservers-extracted
      # yaml-language-server

      # lang-specific dev/diagnostic/lint tools
      deadnix
      lazygit
      nixpkgs-fmt
      rufo
      shellcheck
      shfmt
      statix
      stylua
      nodePackages.textlint
      nodePackages.textlint-rule-common-misspellings
      nodePackages.textlint-rule-no-start-duplicated-conjunction
      nodePackages.textlint-rule-stop-words
      nodePackages.textlint-rule-terminology
      nodePackages.textlint-rule-write-good
      yaml-language-server
      # yamlfix
      # yamlfmt
      # yamllint
    ];


  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.home-manager.enable = true;

  home.file.".config/nvim".source = ./nvim;
  home.file.".config/nvim".recursive = true;
  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-nightly;
    # package = pkgs.neovim-nightly;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      ## lualine-nvim # statusline 
      ## gruvbox-nvim # colorscheme
      ## tokyonight-nvim # colorscheme
      ## vim-tmux-navigator # navigate between vim and tmux panes easily
      ## # guess-indent-nvim # kinda like vim-sleuth for lua
      ## #(lib.my.vimPluginFromGitHub "mrcjkb/nvim-lastplace" "main" "91b996e062affebd7fe787f57a2a3e212457e87b") # remember cursor position
      ## vim-lastplace # remember cursor position
      ## vim-numbertoggle # smartly switches between relative and absolute line numbers
      ## #remember-nvim
      ## nvim-lspconfig # lsp
      ## lsp-format-nvim # easy attachment for auto formatting for lsp servers that support it

      ## vim-go

      ## # completion
      ## nvim-cmp # completion engine
      ## luasnip # snippet engine
      ## lspkind-nvim # icons for completion
      ## # completion sources: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
      ## cmp_luasnip
      ## cmp-nvim-lsp
      ## cmp-buffer
      ## cmp-async-path
      ## cmp-cmdline
      ## cmp-path
      ## cmp-git
      ## cmp-emoji
      ## (lib.my.vimPluginFromGitHub "SergioRibera/cmp-dotenv" "main" "fd78929551010bc20602e7e663e42a5e14d76c96") # remember cursor position
      ## cmp-nvim-lsp-signature-help
      ## cmp-nvim-lsp-document-symbol
      ## # copilot, the lua ones don't behave like the og one 
      ## # https://github.com/zbirenbaum/copilot-cmp/issues/5
      ## copilot-vim
      # copilot-lua
      # copilot-cmp
      #(lib.my.vimPluginFromGitHub "NOBLES5E/copilot-cmp" "master" "019b4c9d27ad4aaf61340559a3c0ad8033500289")
    ];
  };

  home.activation = lib.my.activationScripts (map toString [
    ''
      mkdir -p ~/.{cache,config,local,run}
    ''
    ''
      if ! grep -q discord /etc/group; then
        echo "Discord group does not exist. Creating it..."
        sudo groupadd discord
      fi
      if ! groups ${user} | grep -qw discord; then
        echo "Adding ${user} to discord group..."
        sudo usermod -a -G discord ${user}
      fi
    ''
    #./scripts/ssh-generate-authorized-keys
    #./scripts/nvim-ensure-plugins
    #./scripts/tmux-ensure-plugins
  ]);
}

#I'm having similar issues trying to replicate similar behaviour to copilot.vim where I open a new line, and immediately get suggestions. I've tried editing copilot.lua settings ;
# (pkgs.writeText "hello" ''
#   echo ${pkgs.bash-completion}
# '')
