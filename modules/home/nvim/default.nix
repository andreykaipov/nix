{
  inputs,
  pkgs,
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
}
