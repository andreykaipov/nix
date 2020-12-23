{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      bashInteractive = super.bashInteractive_5;
    })
  ];

  system.patches = [
    (pkgs.writeText "add bash from nix.patch" ''
      --- a/etc/shells
      +++ b/etc/shells
      @@ -5 +5,2 @@
       /bin/bash
      +${pkgs.bashInteractive_5}/bin/bash
    '')
  ];

  system.activationScripts.postActivation.text = ''
    chsh -s ${pkgs.bashInteractive_5}/bin/bash "$SUDO_USER"

    mkdir -p ~/.config/nix/links
    ln -sf "${pkgs.bash-completion}" ~/.config/nix/links/bash-completion
  '';

  programs.bash.interactiveShellInit = ''
    reexec() {
        unset __ETC_BASHRC_SOURCED
        unset __NIX_DARWIN_SET_ENVIRONMENT_DONE
        exec $SHELL -c 'echo >&2 "reexecuting shell: $SHELL" && exec $SHELL -l'
    }
  '';
}
