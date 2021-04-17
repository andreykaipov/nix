with import <nixpkgs> {};

let
  pname = "dns-tcp-socks-proxy";
  version = "0.0.0";
  bin = "dns-proxy";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchgit {
      url = "https://github.com/cookiengineer/dns-proxy.git";
      sha256 = "1035g8c05cvaxnxxfv1g562asyrwia8p281ns4lxxwmqbjz3w9m6";
    };

    inherit bin;

    installPhase = ''
      mkdir -p $out/bin
      cp $bin $out/bin
      chmod +x $out/bin/*
    '';
  }
