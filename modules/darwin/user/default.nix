{
  pkgs,
  host,
  ...
}:

{
  users.users.${host.username} = {
    name = host.username;
    home = host.homeDirectory;
    isHidden = false;
    shell = pkgs.zsh;
  };
}
