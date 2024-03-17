{ config
, pkgs
, inputs
, lib
, host
, ...
}:
with lib;
let
  # this effectively extends the config.age module with a `decrypt` option that
  # is sugar for setting the encrypted files that agenix should decrypt, so
  # that we don't have to set the `age.secrets` option directly, e.g:
  #
  # [config.]age.decrypt."a.pem.age" = {}
  # [config.]age.decrypt."a.pem.age".mode = "600"
  # [config.]age.decrypt."a.pem.age".path = "/path/to/a.pem" # where it is unencrypted
  #
  # accessing the decrypted secret in a module could also be as normal via
  # config.age.secrets in a module elsewhere:
  #
  # let path_to_a_unencrypted = config.age.secrets."a.pem".path;
  #
  # note the lack of the .age suffix if accessed via config.age.secrets
  #
  # the [config.] prefix is seemingly optional, but required if we're using
  # the config property elsewhere in the module, see:
  # https://discourse.nixos.org/t/difference-between-a-modules-config-property-and-directly-defining-options/14972
  commonSecretsToDecrypt = { };
  secretsDir = "${config.root}/secrets";
  secretsFile = "${secretsDir}/secrets.nix";
  cfg = config.age;
in
{
  options.age = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    decrypt = mkOption {
      type = types.attrs;
      default = { };
      description = "A map of secrets that you want agenix to decrypt";
    };
  };

  # a conditional import here would cause infinite recursion issues i guess?
  imports = [ inputs.agenix.homeManagerModules.age ];

  config = mkIf cfg.enable {
    # don't think this pem key can exist inside of this nix flake
    # decryption seems to fails silently if it does!
    #
    # in any case the master key can be deleted after an initial run since the
    # decrypted secrets would already exist on the machine. and it would only
    # be required again if a module request different secrets that haven't yet
    # been decrypted.
    age.identityPaths = [ "/tmp/age.decryption.key.pem" ];

    age.secrets = mapAttrs'
      (name: secret:
        nameValuePair
          (removeSuffix ".age" name)
          (secret // { file = "${secretsDir}/${name}"; }))
      (commonSecretsToDecrypt // cfg.decrypt);

    home.packages = [
      inputs.agenix.packages.${pkgs.system}.agenix
    ];

    assertions = [
      {
        assertion = pathExists secretsFile;
        message = "${secretsFile} does not exist";
      }
    ] ++ (
      let
        mkAssertion = name: secret: {
          assertion = pathExists secret.file;
          message = "A module declared config.age.decrypt.\"${name}.age\" but ${name}.age does not exist";
        };
      in
      mapAttrsToList mkAssertion config.age.secrets
    );
  };
}
