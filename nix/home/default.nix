{ ... }:
{
  programs.home-manager.enable = true;
  imports = [
    ./bootstrap
    ./packages
    ./zsh
    ./tmux
    ./nvim
    ./ssh
    ./scripts
    ./direnv
  ];
}
