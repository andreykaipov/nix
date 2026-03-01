{
  pkgs,
  host,
  ...
}:

{
  xdg.configFile."tmux" = host.symlinkTo ./.;
  home.packages = with pkgs; [ tmux ];
}
