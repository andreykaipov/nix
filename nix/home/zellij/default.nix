{ inputs
, ...
}:
{
  programs.zellij.enable = true;

  # see scripts/_bootstrap.sh instead
  programs.zellij.enableZshIntegration = false;

  home.file.".config/zellij/config.kdl".source = ./config.kdl;
}
