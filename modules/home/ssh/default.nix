{
  config,
  pkgs,
  host,
  ...
}:

{
  home.packages = with pkgs; [ openssh ];

  # Symlink config files into ~/.ssh (not the whole dir — agenix places keys there)
  home.file.".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/ssh/config";
  home.file.".ssh/config.d".source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/ssh/config.d";

  # Ensure socket dir exists for ControlPath
  home.file.".cache/ssh/sockets/.keep".text = "";
}
