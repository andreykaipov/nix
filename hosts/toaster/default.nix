{
  lib,
  ...
}:
{
  system = "arm64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFW9lYrlUA5gWMBEBnuMCcVpBLih8KQhizcCNsSPo9U7 ";
  desktopBackground = builtins.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/13-Ventura-Dark.jpg";
    sha256 = "1bpkf2ibh7a9vi1p11i4ykbcs2k197d6wfbnlvf4vflnylbi5lrb";
  };
  extraModules = with lib.extras; [
    dev
    aws-sso-refresh
  ];
}
