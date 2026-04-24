{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    checkov
    terraform
    terragrunt
    opentofu
    terraform-ls
    tflint
    tfswitch
  ];
}
