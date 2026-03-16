{
  inputs,
  ...
}:

with builtins;
let
  inherit (inputs) nixpkgs nixpkgs-stable;
  inherit (inputs) home-manager darwin;
  inherit (nixpkgs) lib;
in
final: _:
let
  hosts = import ../hosts { lib = final; };
in
{
  forAllHosts = f: f "home" hosts;
  forDarwinHosts = f: f "darwin" hosts;

  # Builds configurations for a given kind (home, darwin, linux) across all matching hosts
  mkConfig =
    kind: hosts:
    let
      kindHosts = getAttr kind hosts;
      configure =
        host:
        let
          inherit (host) system;
          unfree =
            pkgs:
            import pkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = import ../overlays { inherit inputs; };
            };

          pkgs = unfree nixpkgs;
          pkgs-stable = unfree nixpkgs-stable;

          configuration = getAttr kind {
            home = home-manager.lib.homeManagerConfiguration;
            linux = nixpkgs.lib.nixosSystem;
            darwin = darwin.lib.darwinSystem;
          };

          baseModules = [
            (import ../hosts/extend.nix host) # passes host with additional functions on it
            (../modules + "/${kind}")
          ];

          resolvedExtraModules = map (m: if lib.isPath m then import m else m) host.extraModules;
          extraModules = concatMap (m: m.${kind} or [ ]) resolvedExtraModules;

          baseArgs = getAttr kind {
            home = {
              inherit pkgs;
              lib = final;
              extraSpecialArgs = {
                inherit inputs pkgs-stable;
              };
            };
            linux = { };
            darwin = {
              specialArgs = {
                lib = final;
                inherit inputs pkgs pkgs-stable;
              };
              modules = [
                { nixpkgs.hostPlatform = system; }
              ];
            };
          };

          args = baseArgs // {
            modules = baseModules ++ (baseArgs.modules or [ ]) ++ extraModules;
          };
        in
        configuration args;
    in
    lib.mapAttrs (_: configure) kindHosts;
}
