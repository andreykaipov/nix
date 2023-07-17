{ config, pkgs, ... }:

{
  home = {
    username = "andrey";
    homeDirectory = "/home/andrey";
    stateVersion = "22.11";
  };

  programs.home-manager = {
    enable = true;
  };
} 
