{
  pkgs,
  host,
  ...
}:

{
  home.packages = with pkgs; [ tmux ];

  xdg.configFile."tmux" = host.symlinkTo ./config;
}
