{ pkgs }:

pkgs.iterm2.overrideAttrs (old: rec {
  installPhase = (old.installPhase or "")  + ''
    cp -R "$out/Applications/iTerm.app" "/Applications/Nix Apps/"
  '';
})
