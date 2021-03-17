with import <nixpkgs> {};

let
  pname = "iproute2mac";
  version = "0.0.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/brona/iproute2mac/raw/master/src/ip.py";
      sha256 = "0qivphbqvbp04bsx6zgzhq4c8cvf7av8x60b258gwjv40brrbm6q";
    };

    unpackPhase = ":";

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/ip
      chmod +x $out/bin/*
    '';
  }
