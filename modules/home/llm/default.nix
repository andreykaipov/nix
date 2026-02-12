{
  pkgs,
  host,
  ...
}:

{
  home.packages = with pkgs; [
    llm-agents.claude-code
    llm-agents.opencode
    llm-agents.crush
  ];

  # Claude Code: ~/.claude/settings.json
  home.file.".claude/settings.json" = host.symlinkTo ./config/claude-settings.json;

  # OpenCode: ~/.config/opencode/
  xdg.configFile."opencode/opencode.json" = host.symlinkTo ./config/opencode/opencode.json;
  xdg.configFile."opencode/tui.json" = host.symlinkTo ./config/opencode/tui.json;

  # Crush: ~/.config/crush/crush.json
  xdg.configFile."crush/crush.json" = host.symlinkTo ./config/crush.json;

  programs.zsh.sessionVariables = {
    CLAUDE_CODE_USE_BEDROCK = "1";
    AWS_REGION = "us-east-1";
  };

  programs.zsh.shellAliases = {
    cc = "claude";
    oc = "opencode --port";
    opencode = "opencode --port";
    cr = "crush";
  };
}
