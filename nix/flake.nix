{
  description = "Andrey's Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devenv.url = "github:cachix/devenv/latest"; # don't follow

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
    neovim-nightly-overlay.inputs.neovim-flake.url = "github:neovim/neovim?dir=contrib"; #&rev=eb151a9730f0000ff46e0b3467e29bb9f02ae362";
    neovim-nightly-overlay.inputs.neovim-flake.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # zsh plugins
    zsh-powerlevel10k.url = "github:romkatv/powerlevel10k";
    zsh-powerlevel10k.flake = false;
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-fzf-tab.url = "github:Aloxaf/fzf-tab";
    zsh-fzf-tab.flake = false;
    zsh-fzf-tab-source.url = "github:Freed-Wu/fzf-tab-source";
    zsh-fzf-tab-source.flake = false;
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-master
    , home-manager
    , devenv
    , neovim-nightly-overlay
    , ...
    }:
    let
      lib = nixpkgs-unstable.lib;
      homeConfig = system: hostname:
        let
          cfg = import ./hosts/${hostname}.nix;
          username = cfg.username;
          homedir = lib.attrsets.attrByPath [ "homedir" ] "" cfg;
          extraModules = cfg.extraModules;
        in
        home-manager.lib.homeManagerConfiguration
          rec {
            pkgs = nixpkgs-unstable.legacyPackages.${system};
            # pkgs = import <nixpkgs> { }; # alternative to above line, but this is impure

            lib = nixpkgs.lib.extend (libself: super: {
              my = import ./lib {
                inherit system pkgs;
                lib = libself;
                flake = self;
              };
            });

            modules = [
              {
                # alternatively, we can set these in `import nixpkgs { ... }` instead of using legacyPackages above
                nixpkgs.config.allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                nixpkgs.overlays = lib.my.overlays ++ [
                  # neovim-nightly-overlay.overlay
                ];
              }
              {
                home.username = username;
                home.homeDirectory = if homedir != "" then homedir else lib.my.homedir username;
                home.stateVersion = "22.11";
              }
              ./home
            ]
            ++ extraModules;

            extraSpecialArgs = {
              inherit inputs;
              pkgs-stable = import nixpkgs { inherit system; config.allowUnfree = true; };
              devenv = devenv.packages.${system}.devenv;
              homeConfig = cfg;
            };
          };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: configurer: configurer hostname) {
        dustbox = homeConfig "x86_64-linux";
        smart-toaster = homeConfig "x86_64-darwin"; # this is an m1 but aarch64-darwin doesn't work?
      };
    };
}
