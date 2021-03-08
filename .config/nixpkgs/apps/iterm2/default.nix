{ pkgs }:

pkgs.iterm2.overrideAttrs (old: rec {
  installPhase = (old.installPhase or "")  + ''
    # keeping this around so I know how to add extra steps to an install
    # cp -R "$out/Applications/iTerm.app" "/Applications/Nix Apps/"
  '';
})
