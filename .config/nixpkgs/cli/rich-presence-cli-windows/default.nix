with import <nixpkgs> { };

let
  os = "windows";
  ext = ".exe";

  name = "rich-presence";
  pname = "${name}-${os}";
  version = "0.1.0";
  url = "https://github.com/andreykaipov/rich-presence-cli/releases/download/v${version}/${name}-${os}-amd64${ext}";
  sha256 = "sha256-QFDqKJ3X9zevjcVLugdnA+1Q9X3SjJ962nLNGGzWbdQ=";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    inherit url sha256;
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    ls -al
    cp $src $out/bin/${name}${ext}
    chmod +x $out/bin/*
  '';
}
