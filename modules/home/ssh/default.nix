{
  config,
  pkgs,
  host,
  ...
}:

{
  home.packages = with pkgs; [ openssh ];

  # Symlink the whole ssh module directory into ~/.ssh so config + config.d/* are live-editable
  home.file.".ssh".source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/ssh";
}
