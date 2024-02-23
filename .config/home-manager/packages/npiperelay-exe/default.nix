{ stdenv
, fetchurl
, ...
}:

let
  os = "windows";
  ext = ".exe";

  name = "npiperelay";
  pname = "${name}-${os}";
  version = "1.6.0";
  url = "https://github.com/albertony/npiperelay/releases/download/v${version}/${name}_${os}_amd64${ext}";
  sha256 = "sha256-AewgojFL+nNvXAuM/TkyAPb7QbmeNm70zrerdiVs4U8=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit url sha256;
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}${ext}
    chmod +x $out/bin/*
  '';
}
