{
  config,
  pkgs,
  agenix,
  secrets,
  host,
  ...
}:

{
  imports = [ agenix.darwinModules.default ];

  environment.systemPackages = [
    agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  age.identityPaths = [
    "${host.homeDirectory}/.ssh/agenix"
  ];

  age.secrets."id_ed25519" = {
    symlink = false;
    path = "${host.homeDirectory}/.ssh/id_ed25519";
    file = "${secrets}/id_ed25519.age";
    mode = "600";
    owner = host.username;
    group = "staff";
  };

  age.secrets."id_ed25519_agenix" = {
    symlink = false;
    path = "${host.homeDirectory}/.ssh/id_ed25519_agenix";
    file = "${secrets}/id_ed25519_agenix.age";
    mode = "600";
    owner = host.username;
    group = "staff";
  };

  age.secrets."id_rsa" = {
    symlink = false;
    path = "${host.homeDirectory}/.ssh/id_rsa";
    file = "${secrets}/id_rsa.age";
    mode = "600";
    owner = host.username;
    group = "staff";
  };
}
