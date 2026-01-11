{
  host,
  ...
}:

{
  home.file."bin" = host.symlinkTo ./.;
}
