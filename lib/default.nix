{
  self,
  ...
}:
let
  inherit (self) inputs;
  inherit (inputs) nixpkgs nixpkgs-stable;
  inherit (inputs) home-manager darwin;
  inherit (nixpkgs) lib;
in
with lib;
with builtins;
extend (
  final: prev: {
    mkApp = scriptName: system: {
      type = "app";
      program =
        let
          scriptBin = nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
            #!/usr/bin/env bash
            PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
            echo "Running ${scriptName} for ${system}"
            exec ${self}/apps/${system}/${scriptName}
          '';
        in
        "${scriptBin}/bin/${scriptName}";
    };

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
                  inherit host pkgs-stable;
                };
                modules = [
                  ../modules/roots
                  ../home
                  # {
                  #   # I like to use
                  #   # https://github.com/nix-community/home-manager/issues/8336#issuecomment-3696615357
                  #   targets.darwin.copyApps.enable = false;
                  #   targets.darwin.linkApps.enable = false;
                  # }
                ];
              };
              linux = { };
              darwin = {
                inherit system;
                specialArgs = inputs // host // { inherit pkgs pkgs-stable; };
                modules = [ ../modules/darwin ];
              };
            };
          in
          configuration args;
      in
      mapAttrs (_: configure) kindHosts;

    homedir =
      user:
      head (concatLists [
        (lib.optional pkgs.stdenv.hostPlatform.isLinux "/home/${user}")
        (lib.optional pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}")
      ]);

    mkConfig2 =
      hosts: configuration: args:
      let
        configure =
          host:
          let
            homeManagerConfig = {
              inherit pkgs;
              extraSpecialArgs = {
                inherit pkgs-stable;
              }
              // attrByPath [ "extraSpecialArgs" ] { } args;
            };
          in
          if configuration == home-manager.lib.homeManagerConfiguration then
            homeManagerConfig
          else
            systemConfig;

        #          configure = host:
        #            let
        #              baseSpecialArgs = inputs;
        #              userSpecialArgs = attrByPath [name] {} args;
        #                in
        #                  # deep merges the dynamic specialArgs key, if set via the user args
        #                  { "${name}" = baseSpecialArgs // unfreePkgs // userSpecialArgs; };
        #
        #              # finalArgs = { inherit system; } // args // specialArgsAttrSet;
        #              finalArgs = f host;
        #            in
        #              configuration finalArgs;
      in
      builtins.mapAttrs (_: configure) hosts;
  }
)
// darwin.lib
// home-manager.lib

# pkgs = nixpkgs.legacyPackages.${system};
# pkgs-stable = nixpkgs-stable.legacyPackages.${system};

#  # read the current dir and get a list of files, excluding this one
#  # ref: https://github.com/NixOS/nix/issues/5897
#  # currentFile = baseNameOf __curPos.file;
#  #files = attrNames (readDir ./.);
#  #hostFiles = filter (f: f != currentFile) files;
