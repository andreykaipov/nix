with import <nixpkgs> {};

let
  name = "resume";
in
  stdenv.mkDerivation {
    name = "${name}-environment";
    buildInputs = [
      tectonic
      entr
    ];
    shellHook = ''
    '';
  }
