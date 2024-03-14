{
  description = "Andrey's Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/latest"; # don't follow

    neovim-nightly.url = "github:neovim/neovim?dir=contrib"; #" #&rev=eb151a9730f0000ff46e0b3467e29bb9f02ae362";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    # zsh plugins
    # (some are available via nixpkgs but these flakes will always be up to date)
    zsh-powerlevel10k.url = "github:romkatv/powerlevel10k";
    zsh-powerlevel10k.flake = false;
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-fzf-tab.url = "github:Aloxaf/fzf-tab";
    zsh-fzf-tab.flake = false;
    zsh-fzf-tab-source.url = "github:Freed-Wu/fzf-tab-source";
    zsh-fzf-tab-source.flake = false;
    zsh-fzf-zsh-plugin.url = "github:unixorn/fzf-zsh-plugin";
    zsh-fzf-zsh-plugin.flake = false;
    lscolors.url = "github:trapd00r/LS_COLORS";
    lscolors.flake = false;
    zsh-edit.url = "github:marlonrichert/zsh-edit";
    zsh-edit.flake = false;
    zsh-almostontop.url = "github:Valiev/almostontop";
    zsh-almostontop.flake = false;
    zsh-autocomplete.url = "github:marlonrichert/zsh-autocomplete";
    zsh-autocomplete.flake = false;
  };

  outputs =
    inputs@ { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , neovim-nightly
    , devenv
    , ...
    }:
    let
      # lib = nixpkgs-unstable.lib;
      homeConfig = system: hostname:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib.extend (libself: super: {
            my = import ./lib {
              inherit system pkgs;
              lib = libself;
              flake = self;
            };
          });
          cfg = import ./hosts/${hostname}.nix { inherit lib; };
          homedir = lib.attrsets.attrByPath [ "homedir" ] "" cfg;
          inherit (cfg) username extraModules;
        in
        home-manager.lib.homeManagerConfiguration
          rec {
            inherit lib pkgs;

            # pkgs = import <nixpkgs> { }; # alternative to above line, but this is impure

            modules = [
              {
                # alternatively, we can set these in `import nixpkgs { ... }` instead of using legacyPackages above
                nixpkgs.config.allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                nixpkgs.overlays = lib.my.overlays ++ [
                  (final: prev: {
                    neovim-nightly = neovim-nightly.packages.${prev.system}.neovim;
                  })
                ];
              }
              {
                home = {
                  inherit username;
                  homeDirectory = if homedir != "" then homedir else lib.my.homedir username;
                  stateVersion = "22.11";
                };
              }
              ./home
            ]
            ++ extraModules;

            extraSpecialArgs = {
              inherit inputs;
              inherit (devenv.packages.${system}) devenv;
              pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
              homeConfig = cfg;
            };
          };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: configurer: configurer hostname) {
        dustbox = homeConfig "x86_64-linux";
        # smart-toaster = homeConfig "x86_64-darwin"; # this is an m1 but aarch64-darwin doesn't work?
        smart-toaster = homeConfig "aarch64-darwin";
      };
    };
}
