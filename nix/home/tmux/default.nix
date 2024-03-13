{ pkgs
, ...
}:
{
  # we don't use programs.tmux.enable because we have a lot of custom written config
  # and home-manager adds some defaults that i don't like
  home.packages = with pkgs; [ tmux ];

  # for example our configs expect to be in XDG_CONFIG_HOME/tmux
  # tmux is spawned by our bootstrap import and references the config directly
  home.file.".config/tmux".source = ./.;
  home.file.".config/tmux".recursive = true;
}

