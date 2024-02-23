{ pkgs, ... }:

{
  packages = with pkgs; [
    _1password
    azure-cli
    entr
    git
    jq
    opentofu
    tectonic
    terragrunt
  ];

  enterShell = ''
    git --version
  '';

  pre-commit.hooks.shellcheck.enable = true;
}
