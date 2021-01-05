{ stdenv, buildGoPackage, fetchFromGitHub }:

with builtins;

buildGoPackage rec {
  pname = "safe";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "starkandwayne";
    repo = "safe";
    rev = "v0.9.9";
    sha256 = null;
  };

  goPackagePath = "github.com/starkandwayne/safe";

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-X main.Version=${version}")
  '';

  meta = with stdenv.lib; {
    description = "A Vault CLI";
    homepage = "https://github.com/starkandwayne/safe";
    license = licenses.mit;
    maintainers = with maintainers; [ eonpatapon ];
  };
}
