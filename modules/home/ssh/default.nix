{
  pkgs,
  lib,
  host,
  ...
}:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "${host.homeDirectory}/.ssh/config_external"
    ];
    matchBlocks = {
      "*" = {
        sendEnv = [
          "LANG"
          "LC_*"
        ];
        hashKnownHosts = true;
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          "${host.homeDirectory}/.ssh/id_github"
        ];
      };
    };
  };
}
