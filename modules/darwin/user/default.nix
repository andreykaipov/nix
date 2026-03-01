{
  pkgs,
  username,
  homeDirectory,
  ...
}:

{
  users.users.${username} = {
    name = username;
    home = homeDirectory;
    isHidden = false;
    shell = pkgs.zsh;
  };
}
