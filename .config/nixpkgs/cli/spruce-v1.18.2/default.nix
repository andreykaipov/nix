with import <nixpkgs> {};

let
  os = if stdenv.isDarwin then "darwin" else "linux";

  pname = "spruce";
  version = "1.18.2";
  url = "https://github.com/geofffranks/spruce/releases/download/v${version}/spruce-${os}-amd64";
  sha256 = if stdenv.isDarwin then "0ykm7i828xaf0bl5h2mwpgjragly30x5j5csjiiyw5gs5jh9rwy7"
                              else "1xdwx8115fj05b0nnkdqqksyg29x56dy339h02pywn753vqwjbv0";
in
  stdenv.mkDerivation rec {
    inherit pname version;

    src = fetchurl {
      inherit url sha256;
    };

    unpackPhase = ":";

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/$pname
      chmod +x $out/bin/*
    '';
  }
