{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    go
    golangci-lint-langserver
    gopls
  ];
}
