{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "fly";
  version = "4.2.5";

  src = fetchurl {
    url = "https://github.com/concourse/fly/releases/download/v${version}/fly_darwin_amd64";
    sha256 = "0c1d69ga2ig4amzr0jssqihnmarh3jcy26dlg8xamx01a2ricccr";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/$pname
    chmod +x $out/bin/$pname
  '';
}
