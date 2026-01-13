{
  pkgs,
  ...
}:

let
  content = builtins.readFile ./bootstrap.sh;
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "_bootstrap.sh" content)
  ];

  # Also install to ~/.bootstrap.sh for wezterm's default_prog
  home.file.".bootstrap.sh" = {
    executable = true;
    text = content;
    force = true;
  };
}
