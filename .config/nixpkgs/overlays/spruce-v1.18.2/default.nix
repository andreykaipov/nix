self: super: {
  spruce-v1_18_2 = (
    with super;

    buildGoPackage rec {
      pname = "spruce";
      version = "1.18.2";

      src = fetchFromGitHub {
        owner = "geofffranks";
        repo = "spruce";
        rev = "v1.18.2";
        sha256 = null;
      };

      goPackagePath = "github.com/geofffranks/spruce";

      preBuild = ''
        buildFlagsArray+=("-ldflags" "-X main.Version=${version}")
      '';

      meta = with lib; {
        description = "YAML merger thing";
        homepage = "https://github.com/geofffranks/spruce";
        license = licenses.mit;
      };
    }
  );
}
