{
  inputs,
  pkgs,
  lib,
  host,
  ...
}:

let
  cs = host.colorscheme or null;
  hostLua = pkgs.writeText "host.lua" ''
    return { '${cs.name}', ${toString cs.lighterShade}${if cs.blackBg or false then ", true" else ""} }
  '';
in

{
  home.packages = with pkgs; [
    nodejs # for copilot.lua server
    tree-sitter
    lua
    luarocks
    lua-language-server
    stylua
  ];

  xdg.configFile."nvim" = host.symlinkTo ./.;
  xdg.dataFile."nvim/host.lua" = lib.mkIf (cs != null) { source = hostLua; };
  programs.neovim = {
    package = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.activation.nvimPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Installing nvim plugins..."
    PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH" ${
      inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default
    }/bin/nvim --headless +qa
  '';
}
