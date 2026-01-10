{
  host,
  ...
}:

{
  xdg.configFile."wezterm" = host.symlinkTo ./.;
}
