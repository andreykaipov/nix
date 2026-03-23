{
  pkgs,
  ...
}:

{
  home.packages = [
    (pkgs.haskellPackages.ghcWithPackages (hp: [ hp.tidal ]))
  ];
}
