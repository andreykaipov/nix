{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Spotify";
  version = "0.0.0";

  src = fetchurl {
    url = "https://download.scdn.co/Spotify.dmg";
    sha256 = null;
  };

  sourceRoot = "${pname}.app";

  buildInputs = [ undmg ];
  installPhase = ''
    mkdir -p "$out/Applications/${sourceRoot}"
    cp -R . "$out/Applications/${sourceRoot}"
    chmod a+x "$out/Applications/${sourceRoot}/Contents/MacOS/${pname}"
    cp -R "$out/Applications/${sourceRoot}" "/Applications/Nix Apps/"
  '';

  meta = with stdenv.lib; {
    homepage = "https://spotify.com";
    platforms = platforms.darwin;
  };
}
