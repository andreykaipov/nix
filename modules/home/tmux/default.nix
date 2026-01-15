{
  pkgs,
  host,
  ...
}:

{
  xdg.configFile."tmux" = host.symlinkTo ./config;

  home.packages = with pkgs; [ tmux ];
}
