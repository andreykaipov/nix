with import <nixpkgs> { };

let
  derivation = (import ./default.nix);
  name = derivation.drvAttrs.name;
in
stdenv.mkDerivation {
  name = "${name}-environment";
  buildInputs = [ derivation ];
}
