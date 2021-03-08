{ stdenv, fetchFromGitHub }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "extempore";
  version = "7022f6144e42fba77a0e8d99519cc3460872240a";

  src = fetchFromGitHub {
    owner = "digego";
    repo = pname;
    rev = version;
    sha256 = null;
  };

  patches = [./cmakelists.txt.patch];

  nativeBuildInputs = [cmake python3];

  cmakeFlags = [
    "-DASSETS=ON"
  ];

#  configurePhase = ''
#    mkdir build
#    cd build
#    cmake ..
#  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mv $pname "$out/bin"
  '';
}
