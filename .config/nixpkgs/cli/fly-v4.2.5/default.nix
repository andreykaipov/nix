with import <nixpkgs> {};

let
  os = if stdenv.isDarwin then "darwin" else "linux";

  pname = "fly";
  version = "4.2.5";
  url = "https://github.com/concourse/fly/releases/download/v${version}/fly_${os}_amd64";
  sha256 = if stdenv.isDarwin then "0c1d69ga2ig4amzr0jssqihnmarh3jcy26dlg8xamx01a2ricccr"
                              else "1b00i90llakzszxrcbl4q8b5bmx0aki5q39npx7h4bsrl34xlix7";
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
