{
  host,
  ...
}:

{
  imports = [
    ../../../_internal/dock.nix
  ];

  # Dock entries (managed via dockutil)
  local.dock = {
    enable = true;
    username = host.username;
    entries = [
      { path = "/Applications/WezTerm.app/"; }
      { path = "/Applications/Google Chrome.app/"; }
      { path = "/System/Applications/Messages.app/"; }
      { path = "/System/Applications/Notes.app/"; }
      { path = "/System/Applications/System Settings.app/"; }
      {
        path = "${host.homeDirectory}/Downloads/";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    launchanim = true;
    orientation = "bottom";
    tilesize = 48;

    # magnify on hover
    magnification = true;
    largesize = 16;
  };
}
