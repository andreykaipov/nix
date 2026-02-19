{
  inputs,
  pkgs,
  lib,
  host,
  ...
}:

{
  home.packages = with pkgs; [
    nodejs # for copilot.lua server
    tree-sitter
  ];

  xdg.configFile."nvim" = host.symlinkTo ./.;
  programs.neovim = {
    package = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.activation.nvimPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Installing nvim plugins..."
    PATH="${pkgs.git}/bin:$PATH" ${
      inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default
    }/bin/nvim --headless +qa 2>&1 || true
  '';
}
