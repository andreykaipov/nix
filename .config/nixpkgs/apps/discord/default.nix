{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Discord";
  version = "0.0.261";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/osx/${version}/Discord.dmg";
    sha256 = null;
  };

  sourceRoot = "${pname}.app";

  buildInputs = [ undmg ];
  installPhase = ''
    mkdir -p "$out/Applications/${sourceRoot}"
    cp -R . "$out/Applications/${sourceRoot}"
    chmod a+x "$out/Applications/${sourceRoot}/Contents/MacOS/${pname}"
  '';

  meta = with stdenv.lib; {
    homepage = "https://discord.com";
    platforms = platforms.darwin;
  };
}
