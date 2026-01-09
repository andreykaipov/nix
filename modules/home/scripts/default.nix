{
  config,
  host,
  ...
}:

{
  home.file."bin".source = config.lib.file.mkOutOfStoreSymlink "${host.gitRoot}/modules/home/scripts/bin";
}
