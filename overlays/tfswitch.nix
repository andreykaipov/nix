# TODO: remove once nixpkgs bumps tfswitch past 1.17.1 (PGP key expiry fix)
{ inputs, ... }:
final: prev: {
  tfswitch = prev.buildGoModule rec {
    pname = "tfswitch";
    version = "1.17.1";

    src = prev.fetchFromGitHub {
      owner = "warrensbox";
      repo = "terraform-switcher";
      rev = "v${version}";
      hash = "sha256-mwseK++lsiN2oPkLnXJm4M5sHybzPI3fCPtn1Ft+dkE=";
    };

    vendorHash = "sha256-jR8zutVetlZ3WBSPxAg2ZdppqDf9+E/yuvsTeHHHtfs=";

    doCheck = false;

    postInstall = ''
      mv $out/bin/terraform-switcher $out/bin/tfswitch
    '';
  };
}
