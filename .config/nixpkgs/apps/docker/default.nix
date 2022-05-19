{ stdenv, lib, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Docker";
  version = "stable";

  src = fetchurl {
    url = "https://desktop.docker.com/mac/stable/Docker.dmg";
    sha256 = null;
  };

  sourceRoot = "${pname}.app";

  buildInputs = [ undmg ];
  installPhase = ''
    mkdir -p "$out/Applications/${sourceRoot}"
    cp -R . "$out/Applications/${sourceRoot}"
    chmod a+x "$out/Applications/${sourceRoot}/Contents/MacOS/${pname}"
  '';

  meta = with lib; {
    homepage = "https://docker.com";
    platforms = platforms.darwin;
  };
}
