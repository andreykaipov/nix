{ pkgs
, lib
, host
, ...
}:
let
  data = {
    inherit host;
  };
  f = lib.my.templateFile "gitconfig" ./gitconfig.mustache data;
in
{
  home.packages = with pkgs; [
    git
    git-filter-repo
    gh
    lazygit
  ];

  xdg.configFile."git/config".source = f;
}
