self: super: {
  dircolors_hex = (
    with super;

    stdenv.mkDerivation rec {
      pname = "dircolors.hex";
      version = "master";

      src = fetchFromGitHub {
        owner = "andreykaipov";
        repo = pname;
        rev = version;
        sha256 = null;
      };

      installPhase = ''
        mkdir -p "$out/bin"
        cp bin/dircolors.hex "$out/bin/dircolors.hex"
      '';
    }
  );
}
