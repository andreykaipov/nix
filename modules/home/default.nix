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
  news.display = "silent";

  imports = [
    ./shell
    ./git
    ./ssh
    ./packages
    ./tmux
    ./nvim
  ];
}
