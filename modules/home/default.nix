{
  host,
  ...
}:

{
  home = {
    inherit (host) username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./shell
    ./git
    ./ssh
    ./packages
    ./tmux
    ./nvim
  ];
}
