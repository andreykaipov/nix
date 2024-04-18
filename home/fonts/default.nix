{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    comic-mono
  ];
}
