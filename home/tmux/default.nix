{ config
, pkgs
, ...
}:
{
  # we don't use programs.tmux.enable because we have a lot of custom written
  # configs and home-manager adds some defaults that i don't like.
  #
  # our tmux is spawned by our bootstrap import and will reference the config
  # directly at $XDG_CONFIG_HOME/tmux.core.conf instead

  home.packages = with pkgs; [ tmux ];

  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.gitRoot}/home/tmux";
}
