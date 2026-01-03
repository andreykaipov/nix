{
  config,
  pkgs,
  host,
  ...
}:

{
  # we don't use programs.tmux.enable because we have a lot of custom written
  # configs and home-manager adds shit I don't like
  #
  # our tmux is spawned by our bootstrap import and will reference the config
  # directly at $XDG_CONFIG_HOME/tmux/core.conf instead
  xdg.configFile."tmux".source =
    config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/tmux";
  home.packages = with pkgs; [ tmux ];
}
