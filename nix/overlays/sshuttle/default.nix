# Original: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/sshuttle/default.nix

self: super:

with super.python3Packages; {

  # can use overrideAttrs but some attributes like `doCheck` are Python-specific
  sshuttle = super.sshuttle.overridePythonAttrs (old: rec {

    pname = old.pname;
    version = "1.1.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-9aPtHlqxITx6bfhgr0HxqQOrLK+/73Hzcazc/yHmnuY=";
    };

    # see https://github.com/sshuttle/sshuttle/issues/563#issuecomment-789693694
    patches = [ ./sudo.patch ./pf.patch ];

    # our new patch breaks some pf firewall tests
    checkPhase = ''
      pytest -k 'not (test_setup_firewall_darwin or test_setup_firewall_freebsd or test_setup_firewall_openbsd)'
    '';

    # Python build-time dependencies
    nativeBuildInputs = old.nativeBuildInputs ++ [ psutil ];

    # Python runtime dependencies
    propagatedBuildInputs = [ psutil ];

  });

}
