{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "andrey";
in
{
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "${pkgs.wezterm}/Applications/Wezterm.app/"; }
        #{ path = "${pkgs.ghostty}/Applications/Ghostty.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Notes.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
