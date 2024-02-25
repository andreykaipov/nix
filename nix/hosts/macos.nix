{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    coreutils
    iproute2mac
    gnused
  ];
}
