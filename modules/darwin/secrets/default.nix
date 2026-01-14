{
  pkgs,
  lib,
  agenix,
  secrets,
  host,
  ...
}:

let
  # Discover SSH keys from the secrets repo
  sshFiles = builtins.readDir "${secrets}/ssh";
  sshKeyNames = lib.pipe sshFiles [
    (lib.filterAttrs (_: type: type == "regular"))
    builtins.attrNames
    (builtins.filter (lib.hasSuffix ".age"))
    (map (lib.removeSuffix ".age"))
  ];
  sshKey = name: {
    symlink = false;
    path = "${host.homeDirectory}/.ssh/keys/${name}";
    file = "${secrets}/ssh/${name}.age";
    mode = "600";
    owner = host.username;
    group = "staff";
  };

  keyPath = "${host.homeDirectory}/.ssh/keys/${host.hostname}.pem";
in
{
  imports = [ agenix.darwinModules.default ];

  environment.systemPackages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age.identityPaths = [
    "${host.homeDirectory}/.ssh/keys/agenix.pem"
  ];

  age.secrets = lib.genAttrs sshKeyNames sshKey;

  # Generate a per-host SSH key if one doesn't already exist
  # (~/.ssh/keys is symlinked to the repo by home-manager)
  system.activationScripts.postActivation.text = ''
    if [ ! -f "${keyPath}" ]; then
      echo "Generating SSH key for ${host.hostname}..."
      mkdir -p "$(dirname "${keyPath}")"
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "${keyPath}" -N "" -C "${host.username}@${host.hostname}"
      echo "New SSH public key:"
      cat "${keyPath}.pub"
      echo "Add this key to GitHub: https://github.com/settings/ssh/new"
    fi
  '';
}
