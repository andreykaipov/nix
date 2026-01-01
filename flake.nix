{
  description = "Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    secrets.url = "git+ssh://git@github.com/andreykaipov/nix-secrets.git";
    secrets.flake = false;
  };
  #outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, agenix, secrets, ... } @inputs:
  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs) nixpkgs;

      lib = import ./lib { inherit self; };

      # forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      forAllSystems = f: nixpkgs.lib.genAttrs (nixpkgs.lib.systems.flakeExposed) f;
      mkApps =
        system: lib.attrsets.mapAttrs (k: v: lib.mkApp k system) (builtins.readDir ./apps/${system});
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
                age
                age-plugin-yubikey
              ];
              shellHook = with pkgs; ''
                export EDITOR=vim
              '';
            };
        };

      hosts = import ./hosts { inherit lib; };
    in
    {
      apps = forAllSystems mkApps; # nix run .#app
      devShells = forAllSystems devShell;

      homeConfigurations = lib.mkConfig "home" hosts;
      darwinConfigurations = lib.mkConfig "darwin" hosts;
    };
}
