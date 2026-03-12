{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    lua
    luarocks
    lua-language-server
    stylua
  ];
}
