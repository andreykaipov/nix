{ pkgs
, lib
, ...
}:
let
  data = {
    nix = pkgs.nix.outPath;
  };
  f = lib.my.templateFile "_bootstrap.sh" ./bootstrap.sh.mustache data;
  content = builtins.readFile f;
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "_bootstrap.sh" content)
  ];
}
