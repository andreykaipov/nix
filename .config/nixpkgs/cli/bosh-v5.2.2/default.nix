with import <nixpkgs> { };

let
  os = if stdenv.isDarwin then "darwin" else "linux";

  pname = "bosh";
  version = "5.2.2";
  url = "https://github.com/cloudfoundry/bosh-cli/releases/download/v${version}/bosh-cli-${version}-${os}-amd64";
  sha256 =
    if stdenv.isDarwin then "13g3vf98mzf6dfg7l3mdgl08jlj4r9drz3ais0jfdh7l9542j0ql"
    else "1nh4j3wz5v7pwafz4wi2q69j03n6pyg1zcvrjs8c2y88a4jmr9j6";
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
