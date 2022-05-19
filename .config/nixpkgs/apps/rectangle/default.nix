{ stdenv, lib, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Rectangle";
  version = "0.48";

  src = fetchurl {
    url = "https://github.com/rxhanson/Rectangle/releases/download/v${version}/Rectangle${version}.dmg";
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
    description = "Move and resize windows on macOS with keyboard shortcuts or snap areas";
    homepage = "https://rectangleapp.com";
    platforms = platforms.darwin;
  };
}
