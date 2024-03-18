_: {
  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    # quiets direnv (instead look for the duck emoji in our prompt)
    zsh.envExtra = ''
      # export DIRENV_LOG_FORMAT=
    '';
  };
}
