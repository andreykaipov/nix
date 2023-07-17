{ nixpkgs, ... }:
{
  home.packages = with nixpkgs; [
    iproute2mac
  ];
}
