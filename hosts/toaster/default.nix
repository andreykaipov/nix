{
  ...
}:
{
  system = "arm64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFW9lYrlUA5gWMBEBnuMCcVpBLih8KQhizcCNsSPo9U7 ";
  extraDarwinModules = [
    { homebrew.casks = [ "cursor" ]; }
  ];
}
