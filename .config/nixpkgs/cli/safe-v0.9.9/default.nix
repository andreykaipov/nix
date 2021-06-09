with import <nixpkgs> { };

let
  os = if stdenv.isDarwin then "darwin" else "linux";

  pname = "safe";
  version = "0.9.9";
  url = "https://github.com/starkandwayne/safe/releases/download/v${version}/safe-${os}-amd64";
  sha256 =
    if stdenv.isDarwin then "088nf1zn9w5vjfrq49h7l34xf5w63jncfh3j9jhw4grykzpbsfi8"
    else "1iz9gbpi85y4q3f9bwgdmsp617wf1v15lwv5vqvqc862d9414l25";
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
