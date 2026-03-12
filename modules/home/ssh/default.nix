{
  pkgs,
  lib,
  host,
  ...
}:

let
  hostKey = "${host.hostname}.pem";
  hasPublicKey = (host.publicKey or "") != "";
in
{
  home.packages = with pkgs; [ openssh ];

  home.file.".ssh/config".text = ''
    # vim: ft=sshconfig
    #
    # To workaround SSH's lack of XDG path support, we have to specify full paths
    # below, e.g. ~/.config/ssh/<blah>

    Host *
        # keys will still be added to our known hosts, and we'll still get the
        # warning, so calm yourself, i just don't like typing yes
        StrictHostKeyChecking no
        HashKnownHosts no
        UserKnownHostsFile ~/.cache/ssh/known_hosts

        # don't try all keys, but only the ones we specify
        IdentitiesOnly yes
        IdentityFile ~/.ssh/${host.hostname}.pem

        # persist connections for 30 minutes
        ControlMaster auto
        ControlPath ~/.cache/ssh/sockets/%r.%C
        ControlPersist 1800

    CanonicalizeHostname yes
    Include ~/.ssh/config.d/*
  '';

  home.file.".ssh/config.d" = host.symlinkTo ./config.d;

  # Write public key from host config.
  # force: bootstrap would have already generated a host key before home-manager runs,
  # but now we're going to manage it with home-manager, even if it has the same contents
  home.file.".ssh/${hostKey}.pub" = lib.mkIf hasPublicKey {
    text = host.publicKey + "\n";
    force = true;
  };

  # Ensure socket dir exists for ControlPath
  home.file.".cache/ssh/sockets/.keep".text = "";
}
