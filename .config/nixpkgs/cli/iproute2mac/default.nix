with import <nixpkgs> { };

let
  pname = "iproute2mac";
  version = "0.0.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/brona/iproute2mac/raw/master/src/ip.py";
    sha256 = "sha256-d8IHWw5VVIRGNt6H376usU3uiC7Gyeln0ZR0dEQK0GE=";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ip
    chmod +x $out/bin/*
  '';
}
