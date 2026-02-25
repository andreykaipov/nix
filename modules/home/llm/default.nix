{
  pkgs,
  host,
  ...
}:

{
  home.packages = with pkgs; [
    llm-agents.opencode
    spec-kit
    terraform-mcp-server
    slack-mcp-server
  ];

  # OpenCode: ~/.config/opencode/
  xdg.configFile."opencode/opencode.json" = host.symlinkTo ./config/opencode/opencode.json;
  xdg.configFile."opencode/tui.json" = host.symlinkTo ./config/opencode/tui.json;

  programs.zsh.shellAliases = {
    opencode = "opencode --port";
  };
}
