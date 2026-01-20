{
  inputs,
  ...
}:

with builtins;
final: _: {
  # Wraps a shell script from apps/<system>/<name> into a nix app with git on PATH
  mkApp = scriptName: system: {
    type = "app";
    meta = {
      description = "Run ${scriptName} for ${system}";
    };
    program =
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        scriptBin = pkgs.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${pkgs.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${inputs.self}/apps/${system}/${scriptName} "$@"
        '';
      in
      "${scriptBin}/bin/${scriptName}";
  };

  # Discovers all scripts in apps/<system>/ and wraps each with mkApp
  mkApps =
    system: mapAttrs (name: _: final.mkApp name system) (readDir (inputs.self + "/apps/${system}"));

  # Applies a function across all systems that have an apps/<system>/ directory
  forAvailableSystems = inputs.nixpkgs.lib.genAttrs (attrNames (readDir (inputs.self + "/apps")));
}
