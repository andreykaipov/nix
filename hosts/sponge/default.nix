{
  lib,
  ...
}:
{
  system = "arm64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICISXN76Z8A910ttATq46VO/KY1Qw5zOIua04oSZbDe3";
  desktopBackground = builtins.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers/10-15-Night.jpg";
    sha256 = "08cd0lacb2l0kal1zvxk7xhignqvhwdznwgqmsxy2iw7kzy12yfa";
  };
  extraModules = with lib.extras; [
    unattended
  ];
}
