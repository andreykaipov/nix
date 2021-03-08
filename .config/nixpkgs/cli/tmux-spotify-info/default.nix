{ stdenv, fetchFromGitHub }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "tmux-spotify-info";
  version = "master";

  src = fetchFromGitHub {
    owner = "jdxcode";
    repo = pname;
    rev = version;
    sha256 = null;
  };

  installPhase = ''
    mkdir -p "$out/bin"
    mv $pname "$out/bin"
  '';
}
