with import <nixpkgs> { };

let
  name = "resume";
in
stdenv.mkDerivation {
  name = "${name}-environment";
  buildInputs = [
    entr
    hugo
    jq
    tectonic
    terraform
    terragrunt
  ];
  shellHook = ''
    '';
}
