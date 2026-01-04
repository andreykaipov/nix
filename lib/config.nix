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
final: _: {
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
            };
          pkgs = unfree nixpkgs;
          pkgs-stable = unfree nixpkgs-stable;

          configuration = getAttr kind {
            home = home-manager.lib.homeManagerConfiguration;
            linux = nixpkgs.lib.nixosSystem;
            darwin = darwin.lib.darwinSystem;
          };

          args = getAttr kind {
            home = {
              inherit pkgs;
              extraSpecialArgs = inputs // {
                # host is passed to _module by the extend.nix import below, not here
                inherit pkgs-stable;
              };
              modules = [
                (import ../hosts/extend.nix host)
                ../modules/home
                {
                  # GUI apps come from homebrew casks, not nix packages
                  # So we disable linking into /Applications/Home Manager Apps
                  # https://github.com/nix-community/home-manager/issues/8336#issuecomment-3696615357
                  targets.darwin.copyApps.enable = false;
                  targets.darwin.linkApps.enable = false;

                  # Workaround for builtins.toFile options.json warning with Determinate Nix
                  # https://github.com/nix-community/home-manager/issues/7935
                  manual.manpages.enable = false;
                }
              ];
            };
            linux = { };
            darwin = {
              specialArgs = inputs // {
                inherit host pkgs pkgs-stable;
              };
              modules = [
                ../modules/darwin
                { nixpkgs.hostPlatform = system; }
              ];
            };
          };
        in
        configuration args;
    in
    lib.mapAttrs (_: configure) kindHosts;

  # Builds all *Configurations outputs, skipping kinds with no hosts
  mkConfigs =
    hosts:
    let
      nonEmpty = filter (kind: hosts.${kind} or { } != { }) (attrNames hosts);
      outputName =
        kind:
        {
          home = "homeConfigurations";
          darwin = "darwinConfigurations";
          linux = "nixosConfigurations";
        }
        .${kind};
    in
    listToAttrs (
      map (kind: {
        name = outputName kind;
        value = final.mkConfig kind hosts;
      }) nonEmpty
    );
}
