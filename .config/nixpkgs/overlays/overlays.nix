# vi: foldmethod=indent foldlevel=1
#
# Print out overlays and pinned versions:
#
# ❯ cat ~/.config/nixpkgs/overlays/overlays.nix
#   | awk '/^  [^= ]+ =.+{$/,/^    version =/'
#   | awk -F= 'NR%3==1{printf "%s ", $1}NR%3==0{print $2}'
#   | column -t

self: super: with super;
let
  os = stdenv.targetPlatform.parsed.kernel.name;
  arch = stdenv.targetPlatform.parsed.cpu.family + builtins.toString stdenv.targetPlatform.parsed.cpu.bits;
  neatos = if os == "darwin" then "macos" else "linux";
in
{
  dircolors_hex = import ../cli/dircolors.hex;
  dns-tcp-socks-proxy = import ../cli/dns-tcp-socks-proxy;
  extempore = import ../cli/extempore;
  iproute2mac = import ../cli/iproute2mac;
  rich-presence-cli-windows = import ../cli/rich-presence-cli-windows;
  rich-presence-cli-linux = import ../cli/rich-presence-cli-linux;
  twitch = import ../cli/twitch;
  win32yank = import ../cli/win32yank;
  wudo = import ../cli/wsl-sudo;

  fly-v4_2_5 = import ../cli/fly-v4.2.5;
  fly-v5_7_2 = import ../cli/fly-v5.7.2;
  safe-v0_9_9 = import ../cli/safe-v0.9.9;
  spruce-v1_18_2 = import ../cli/spruce-v1.18.2;
  bosh-v5_2_2 = import ../cli/bosh-v5.2.2;

  gost = stdenv.mkDerivation rec {
    pname = "gost";
    version = "2.11.4";
    src = fetchurl {
      url = "https://github.com/ginuerzh/${pname}/releases/download/v${version}/${pname}-${os}-${arch}-${version}.gz";
      sha256 = "sha256-2PLqlqSb24ZNAiBa5xxtao9An0k8w/8d5V9Ol44zQBo=";
    };
    buildInputs = [ gzip ];
    unpackPhase = ":";
    installPhase = ''
      mkdir -p $out/bin
      gunzip -c $src >$out/bin/${pname}
      chmod +x $out/bin/*
    '';
  };
  #  mutagen = stdenv.mkDerivation rec {
  #    pname = "mutagen";
  #    version = "0.16.3";
  #    src = fetchurl {
  #      url = "https://github.com/mutagen-io/${pname}/releases/download/v${version}/${pname}_${os}_${arch}_v${version}.tar.gz";
  #      sha256 = "sha256-cBH4s82KmBNcxIPo9aXuny89SslZEy55Y31wc5V+Ryo=";
  #    };
  #    buildInputs = [ gnutar ];
  #    unpackPhase = ":";
  #    installPhase = ''
  #      mkdir -p $out/bin
  #      tar xfvz $src -C $out/bin ${pname}
  #      chmod +x $out/bin/*
  #    '';
  #  };
  # mitmproxy depends on mitmproxy-wireguard which has a failing build on macos:
  #
  # = note: ld: warning: option -s is obsolete and being ignored
  #         ld: framework not found Security
  #         clang-11: error: linker command failed with exit code 1 (use -v to see invocation)
  #
  # requires `darwin.apple_sdk.frameworks.Security` as a buildInput
  #
  mitmproxy = with python3Packages; buildPythonPackage rec {
    pname = "mitmproxy";
    version = "9.0.1";
    src = fetchzip {
      url = "https://github.com/${pname}/${pname}/archive/refs/tags/${version}.zip";
      sha256 = "sha256-CINKvRnBspciS+wefJB8gzBE13L8CjbYCkmLmTTeYlA=";
    };
    checkInputs = [
      hypothesis
      parver
      pytest-asyncio
      pytest-timeout
      pytest-xdist
      pytestCheckHook
      requests
    ];
    postPatch = ''
      # remove dependency constraints
      sed 's/>=\([0-9]\.\?\)\+\( \?, \?<\([0-9]\.\?\)\+\)\?\( \?, \?!=\([0-9]\.\?\)\+\)\?//' -i setup.py
    '';
    doCheck = false;
    dontUsePytestXdist = true;
    pythonImportsCheck = [ "mitmproxy" ];
    propagatedBuildInputs = [
      asgiref
      blinker
      brotli
      certifi
      cryptography
      flask
      h11
      h2
      hyperframe
      kaitaistruct
      ldap3
      msgpack
      passlib
      protobuf
      publicsuffix2
      pyopenssl
      pyparsing
      pyperclip
      ruamel-yaml
      setuptools
      sortedcontainers
      tornado
      typing-extensions
      urwid
      wsproto
      zstandard
      (with python3Packages; buildPythonPackage rec {
        # mitmproxy-wireguard
        pname = "mitmproxy-wireguard";
        version = "0.1.19";
        format = "pyproject";
        src = fetchFromGitHub {
          owner = "decathorpe";
          repo = "mitmproxy_wireguard";
          rev = "refs/tags/${version}";
          hash = "sha256-6LgA8IaUCfScEr+tEG5lkt0MnWoA9Iab4kAseUvZFFo=";
        };
        buildInputs = [ ] ++ (lib.optional stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Security
        ]);
        nativeBuildInputs = [
          setuptools-rust
        ] ++ (with rustPlatform; [
          cargoSetupHook
          maturinBuildHook
        ]);
        cargoDeps = rustPlatform.fetchCargoTarball {
          inherit src;
          name = "${pname}-${version}";
          hash = "sha256-wuroElBc0LQL0gf+P6Nffv3YsyDJliXksZCgcBfK0iw=";
        };
        doCheck = false;
        pythonImportsCheck = [ "mitmproxy_wireguard" ];
      })
    ];
  };
}
