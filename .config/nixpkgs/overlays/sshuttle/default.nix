# Original: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/sshuttle/default.nix

self: super:

with super.python3Packages; {

  # can use overrideAttrs but some attributes like `doCheck` are Python-specific
  sshuttle = super.sshuttle.overridePythonAttrs(old: rec {

    pname = old.pname;
    version = "1.0.5";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1gd14sj0vagi10sffj2wzh7846i7ksflvyg7m8rhkf1cmhd6k37x";
    };

    # see https://github.com/sshuttle/sshuttle/issues/563#issuecomment-789693694
    patches = old.patches ++ [./pf.patch];

    # our new patch breaks some pf firewall tests
    setuptoolsCheckPhase = ''
      pytest -k 'not (test_setup_firewall_darwin or test_setup_firewall_freebsd or test_setup_firewall_openbsd)'
    '';

    # Python build-time dependencies
    nativeBuildInputs = old.nativeBuildInputs ++ [psutil];

    # Python runtime dependencies
    propagatedBuildInputs = [ psutil ];

  });

}
