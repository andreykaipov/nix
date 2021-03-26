with import <nixpkgs> {};

let
  pname = "dircolors.hex";
  version = "master";
in
  stdenv.mkDerivation rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "andreykaipov";
      repo = pname;
      rev = version;
      sha256 = null;
    };

    installPhase = ''
      mkdir -p "$out/bin"
      cp bin/dircolors.hex "$out/bin/dircolors.hex"
    '';
  }
