{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "Barrier";
  version = "2.3.3";

  src = fetchurl {
    url = "https://github.com/debauchee/barrier/releases/download/v${version}/Barrier-${version}-release.dmg";
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
    description = "Fork of Symless's Synergy - open source KVM software";
    homepage = "https://github.com/debauchee/barrier";
    platforms = platforms.darwin;
  };
}
