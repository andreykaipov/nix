{ flake
, hosts
, extraModules ? [ ]
, ...
}:
let
  inherit (flake.inputs) nixpkgs nixpkgs-stable home-manager neovim-nightly;
  inherit (builtins) mapAttrs map;

  configure = host:
    let
      inherit (host) username system;

      # https://github.com/NixOS/nixpkgs/blob/e456032addae76701eb17e6c03fc515fd78ad74f/flake.nix#L76
      pkgs = nixpkgs.legacyPackages.${system};

      # https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/12
      lib = nixpkgs.lib.extend
        (final: _: {
          my = import ./../lib {
            inherit system pkgs flake;
            lib = final;
          };
        }) // home-manager.lib;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit lib pkgs;

      modules = [
        {
          nixpkgs.config.allowUnfreePredicate = _: true; # https://github.com/nix-community/home-manager/issues/2942
          nixpkgs.overlays = lib.my.overlays ++ [
            (_: _: { neovim-nightly = neovim-nightly.packages.${system}.neovim; })
          ];
        }
        {
          # so that after the first `nix run home-manager`, it gets added to our path as a standalone bin
          programs.home-manager.enable = true;
          home = {
            inherit username;
            homeDirectory = host.homedir or (lib.my.homedir username);
            stateVersion = "22.11";
          };
          # discover all the home imports
          # TODO: make it only discover dirs with a default.nix
          # see rakeLeaves: https://github.com/bangedorrunt/nix/blob/tdt/lib/importers.nix
          imports = map (path: ./${path}) (lib.my.subdirs ./.);
        }
        {
          config.flakeRoot = toString flake;
        }
      ]
      ++ (host.extraModules or [ ])
      ++ extraModules;

      extraSpecialArgs = {
        inherit host;
        inherit (flake) inputs;

        # this import is not as efficient as using legacyPackages like above, but it's the only way to allow unfree for
        # nixpkgs-stable. thankfully this is not impure (using <...> would be), and we rarely use nixpkgs-stable anyway.
        # see:
        # https://discourse.nixos.org/t/allow-unfree-in-flakes/29904
        # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/12
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
in
mapAttrs (_: configure) hosts
