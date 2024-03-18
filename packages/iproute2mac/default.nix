{ stdenv, lib, fetchurl, ... }:

let
  pname = "iproute2mac";
  version = "0.0.0";
  rev = "285993d7acf2d134f90c6e72ad822ba359e84903"; 
in
stdenv.mkDerivation {
  meta.platforms = lib.platforms.darwin;

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/brona/iproute2mac/raw/${rev}/src/ip.py";
    sha256 = "sha256-8i/A5wSZ009QjFktiLiK81qSRkdKbtAmUyJaUdoIH6c=";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ip
    chmod +x $out/bin/*
  '';
}
