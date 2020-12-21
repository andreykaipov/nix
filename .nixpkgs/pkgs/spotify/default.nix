{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  name = "Spotify";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = null;
  };

  sourceRoot = "${name}.app";

  buildInputs = [ undmg ];
  installPhase = ''
    mkdir -p "$out/Applications/${sourceRoot}"
    cp -R . "$out/Applications/${sourceRoot}"
    chmod a+x "$out/Applications/${sourceRoot}/Contents/MacOS/${name}"
  '';

  meta = with stdenv.lib; {
    homepage = "https://spotify.com";
    platforms = platforms.darwin;
  };
}
