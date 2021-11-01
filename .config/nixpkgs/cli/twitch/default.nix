with import <nixpkgs> { };

let
  os = if stdenv.isDarwin then "Darwin" else "Linux";

  pname = "twitch";
  version = "1.1.1";
  url = "https://github.com/twitchdev/twitch-cli/releases/download/${version}/twitch-cli_${version}_${os}_x86_64.tar.gz";
  sha256 =
    if stdenv.isDarwin then "06f36s790nphv34kghh8aj392lky8cymj1gadha7m85hlkyw293i"
    else "0wd2dkhx020v34nkm6k99gid8x02gf293gmx44lds3a4rniyahv4";
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
    mv $pname $out/bin/$pname
    chmod +x $out/bin/*
  '';
}
