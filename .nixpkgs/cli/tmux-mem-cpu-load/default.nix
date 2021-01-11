{ stdenv, fetchFromGitHub }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "tmux-mem-cpu";
  version = "master";

  src = fetchFromGitHub {
    owner = "mandre";
    repo = pname;
    rev = version;
    sha256 = null;
  };

  nativeBuildInputs = [cmake];

  configurePhase = ''
    cmake .
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mv $pname "$out/bin"
  '';
}
