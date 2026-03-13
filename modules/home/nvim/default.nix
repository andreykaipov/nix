{
  inputs,
  pkgs,
  lib,
  host,
  ...
}:

let
  theme = host.theme;
  cs = theme.colorscheme;
  tmux = theme.tmux;
  themeLua = pkgs.writeText "host.lua" ''
    return {
      colorscheme = { '${cs.name}', ${toString cs.lighterShade}, ${lib.boolToString cs.blackBg} },
      tmux = { pane = '${tmux.pane}', border = '${tmux.border}', bg = '${tmux.bg}' },
    }
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
  xdg.dataFile."nvim/host.lua" = {
    source = themeLua;
  };

  programs.neovim = {
    package = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.activation.nvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # new line is weird because it sends OSC11 code to tmux
    # ^[Ptmux;^[^[]11;#3d2520^[\^[\
    # over stderr, it shows up as a new line
    printf "installing nvim plugins... "
    date +%s > "$HOME/.local/share/nvim/color-seed"
    PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.tmux}/bin:$PATH" ${
      inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default
    }/bin/nvim --headless +qa 2>&1
  '';
}
