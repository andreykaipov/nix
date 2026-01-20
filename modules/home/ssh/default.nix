{
  pkgs,
  lib,
  secrets,
  host,
  ...
}:

let
  hostKey = "${host.hostname}.pem";
  hostKeyAge = "${secrets}/ssh/${hostKey}.age";
  hasHostKey = builtins.pathExists hostKeyAge;
in
{
  home.packages = with pkgs; [ openssh ];

  age.secrets = lib.optionalAttrs hasHostKey {
    ${hostKey} = {
      symlink = false;
      path = "${host.gitRoot}/modules/home/ssh/keys/${hostKey}";
      file = hostKeyAge;
      mode = "600";
    };
  };

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
        IdentityFile ~/.ssh/keys/${host.hostname}.pem

        # persist connections for 30 minutes
        ControlMaster auto
        ControlPath ~/.cache/ssh/sockets/%r.%C
        ControlPersist 1800

    CanonicalizeHostname yes
    Include ~/.ssh/config.d/*
  '';

  home.file.".ssh/config.d" = host.symlinkTo ./config.d;
  home.file.".ssh/keys" = host.symlinkTo ./keys;

  # Ensure socket dir exists for ControlPath
  home.file.".cache/ssh/sockets/.keep".text = "";

  # Surface agenix decryption results after the LaunchAgent runs.
  home.activation.reportSSHKeys = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    echo "Fetching SSH keys from secrets..."
    sleep 1
    if [ -f "${host.homeDirectory}/Library/Logs/agenix/stderr" ] && [ -s "${host.homeDirectory}/Library/Logs/agenix/stderr" ]; then
      echo "agenix errors:"
      cat "${host.homeDirectory}/Library/Logs/agenix/stderr"
    fi
    echo "SSH keys available:"
    ls -1 "${host.gitRoot}/modules/home/ssh/keys/"*.pem 2>/dev/null | xargs -n1 basename
  '';
}
