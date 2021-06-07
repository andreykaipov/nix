self: super: with super; {
  terragrunt = let
    os = if stdenv.isDarwin then "darwin" else "linux";

    pname = "terragrunt";
    version = "0.29.10";
    url = "https://github.com/gruntwork-io/terragrunt/releases/download/v${version}/${pname}_${os}_amd64";
    sha256 = if stdenv.isDarwin then "12hi1xb9nq8a788ynh2fh5fyx9ln251bxa74jvgjpmmifdq66qih"
                                else "136cb10va0b6lfzfyqd44lljnpzgr8f0f5k6n7ip4f0h3lxkgp9p";
  in
    stdenv.mkDerivation rec {
      inherit pname version;

      src = fetchurl {
        inherit url sha256;
      };

      unpackPhase = ":";

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/$pname
        chmod +x $out/bin/*
      '';
    };
}
