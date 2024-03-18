with builtins;
let
  # the public keys used to encrypt secrets with "agenix -e mysecret.age"
  # the correspond private key will be read from 1password during the first
  # home-manager run to be able to decrypt them. subsequent runs won't need
  # it unless we request different secrets that haven't yet been decrypted.
  # ref: age.identityPaths in home/agenix.
  publicKeys = {
    # master is passwordless since age doesn't support ssh keys with passwords
    # it's intended to be ran during the first home manager activation
    # it's then deleted off the local fs
    master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAm8sUEQ0tRHVpa24hjE7EkNhknVe6zBF5Xi9ToSs8I master@self/nix";

    # we as the operator should use this one to create/edit existing secrets
    ops = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIColGqeV3FQEV5+oneVSyTzs4DRCijoOcLR5VN0o5gaU ops@self/nix";
  };

  # age expects us to declare all of our secrets in this file before we can
  # edit or create them via `agenix -e mysecret.age`. but agenix also sets FILE
  # with whatever it's passed. by using that we can effectively declare possible
  # secret that we want to encrypt with the above public keys.
  #
  # home modules that want to use the secrets will still need to declare them
  # via config.age.decrypt.mysecret = {}, so the effective security is the
  # same, but what do i know?
  secret = getEnv "FILE";
in
{
  "${secret}" = { inherit publicKeys; };
}
