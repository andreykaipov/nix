{
  lib,
  ...
}:

{
  # Determinate Nix manages the daemon; don't let nix-darwin conflict with it
  nix.enable = false;

  # nix-darwin's programs.zsh controls /etc/zshrc, which runs before our user
  # zshrc (~/.config/zsh/.zshrc). By default it runs compinit and prompt init
  # there, but home-manager already does both. Disable them here so /etc/zshrc
  # doesn't duplicate work and delay p10k instant prompt.
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  imports = lib.discoverModules ./.;
}
