{ inputs
, ...
}:
{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # quiets direnv (instead look for the duck emoji in our prompt)
  programs.zsh.envExtra = ''
    # export DIRENV_LOG_FORMAT=
  '';
}
