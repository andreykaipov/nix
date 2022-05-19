{ stdenv, lib, fetchurl, xar, cpio }:

stdenv.mkDerivation rec {
  pname = "1Password";
  version = "7.7";

  src = fetchurl {
    url = "https://c.1password.com/dist/1P/mac7/1Password-${version}.pkg";
    sha256 = null;
  };

  appname = "${pname} 7";
  sourceRoot = "${appname}.app";

  buildInputs = lib.optionals stdenv.isDarwin [ xar cpio ];

  unpackPhase = lib.optionalString stdenv.isDarwin ''
    xar -xf "$src"
    zcat < ${pname}.pkg/Payload | cpio -i
  '';

  installPhase = ''
    mkdir -p "$out/Applications/${sourceRoot}"
    cp -R . "$out/Applications/${sourceRoot}"
    chmod a+x "$out/Applications/${sourceRoot}/Contents/MacOS/${appname}"
  '';

  dontStrip = stdenv.isDarwin;

  meta = with lib; {
    homepage = "https://1password.com";
    platforms = platforms.darwin;
  };
}
