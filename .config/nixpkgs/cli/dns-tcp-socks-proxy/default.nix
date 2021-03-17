with import <nixpkgs> {};

let
  pname = "dns-tcp-socks-proxy";
  version = "0.0.0";
  bin = "dns_proxy";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchgit {
      url = "https://github.com/cookiengineer/dns-tcp-socks-proxy.git";
      sha256 = "0zki83wr4skil604k6q49ljdszv6cba68bzmws3ski96dvy7zscg";
    };

    inherit bin;

    installPhase = ''
      mkdir -p $out/bin
      cp $bin $out/bin
      chmod +x $out/bin/*
    '';
  }
