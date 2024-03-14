{ lib
, ...
}:
{
  programs.home-manager.enable = true;
  imports = map (path: ./${path}) (lib.my.subdirs ./.);
}
