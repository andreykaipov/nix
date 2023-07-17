{
  description = "Home Manager configuration of Andrey Kaipov";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib.extend (self: super: {
      });

      genPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      processConfigurations = lib.mapAttrs (n: v: v n);

      homeConfig = system: extraModules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./home.nix
          ] ++ extraModules;

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    in {
      homeConfigurations = processConfigurations {
        dustbox = homeConfig "x86_64-linux";
        smart-toaster = homeConfig "aarch64-darwin";
      };
    };
}
