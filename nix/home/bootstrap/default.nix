{ inputs
, pkgs
, lib
, ...
}:
{
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "_bootstrap.source.sh" ''
      . ${pkgs.nix.outPath}/etc/profile.d/nix.sh
      # export PATH=~/bin:$PATH
    '')
  ];
  home.file."bin/_bootstrap.sh".source = ./bootstrap.sh;
}
