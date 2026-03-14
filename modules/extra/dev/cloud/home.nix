{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    kubectl
    awscli2
    vault
    argocd
  ];
}
