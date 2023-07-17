{
  description = "Andrey's Home Manager config";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devenv.url = "github:cachix/devenv/latest"; # don't follow 
  };

  outputs =
    inputs @ { self
    , nixos
    , nixos-unstable
    , nixpkgs-unstable
    , home-manager
    , devenv
    , ...
    }:
    let
      homeConfig = system: extraModules: hostName:
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixos.legacyPackages.${system}; # or remiport again with... pkgs = import blah stable { inherit system; };

          lib = nixos.lib.extend (self: super: {
            my = import ./lib.nix {
              inherit system pkgs;
              lib = self;
            };
          });

          modules =
            let
              username = "andrey";
            in
            [
              {
                home.username = username;
                home.homeDirectory = lib.my.homedir username;
                home.stateVersion = "22.11";
              }
              ./home.nix
            ] ++ extraModules;

          extraSpecialArgs =
            let
              import' = pkg: import pkg {
                inherit system;
                config.allowUnfree = true;
                overlays = lib.my.overlays;
              };
            in
            {
              nixpkgs = import' nixpkgs-unstable;
              nixpkgs-stable = import' nixos;
              devenv = devenv.packages.${system}.devenv;
            };
        };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: config: config hostname) {
        dustbox = homeConfig "x86_64-linux" [ ./wsl.nix ];
        smart-toaster = homeConfig "aarch64-darwin " [ ./macos.nix ];
      };
    };
}


