{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    kubectl
    kubeconform
    kubernetes-helm
    awscli2
    azure-cli
    vault
    argocd
  ];
}
