{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Discord";
  version = "0.0.260";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/osx/${version}/Discord.dmg";
    sha256 = "9cddabb13d862e45a0287591b38c13fde9b372edee7f7a538ba7e375c8b32088";
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
    homepage = "https://discord.com";
    platforms = platforms.darwin;
  };
}
