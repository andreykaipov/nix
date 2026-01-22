# Agenix plumbing for home-manager secrets management.
#
# This module sets up the agenix home-manager integration so that any other
# module can simply declare `age.secrets.<name>` entries without worrying
# about imports or identity paths. NixOS module merging combines all
# `age.secrets` declarations across modules automatically.
#
# Example usage in another module:
#
#   age.secrets."someapp-token" = {
#     file = "${secrets}/someapp/token.age";
#     path = "${host.homeDirectory}/.config/someapp/token";
#     mode = "600";
#   };
{
  pkgs,
  agenix,
  host,
  ...
}:

{
  imports = [ agenix.homeManagerModules.default ];

  home.packages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age.identityPaths = [
    "${host.homeDirectory}/.config/agenix/identity"
  ];
}
