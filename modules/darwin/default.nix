{
  ...
}:

{
  imports = [
    ./system
    ./dock
    ./user
    ./homebrew
    ./secrets
  ];

  nix.enable = false;
}
