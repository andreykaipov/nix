with import <nixpkgs> { };

let
  pname = "wsl-sudo";
  version = "master";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Chronial";
    repo = "wsl-sudo";
    rev = version;
    sha256 = null;
  };

  patches = [ ./patch ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp wsl-sudo.py "$out/bin/wudo"
  '';
}
