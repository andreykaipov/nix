with import <nixpkgs> { };

let
  os = if stdenv.isDarwin then "darwin" else "linux";

  pname = "fly";
  version = "5.7.2";
  url = "https://github.com/concourse/concourse/releases/download/v${version}/fly-${version}-${os}-amd64.tgz";
  sha256 =
    if stdenv.isDarwin then "0fsd35nnxyr5cppx5llxyzffgpbiddpr7qyh8p56kgg72bd4zypf"
    else "17rfav350n6kjm132zhsngjzycch63w2xn15pwhymq7667dh4mxq";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    inherit url sha256;
  };

  unpackPhase = ''
    tar xfvz $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv fly $out/bin/${pname}${version}
    chmod +x $out/bin/*
  '';
}
