{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "github-copilot";
        pi.settings.defaultModel = "claude-opus-4.6";
        pi.settings.defaultThinkingLevel = "high";
        pi.mcpServers = {
          inherit (config.pi.mcp) terraform slack;
        };
      }
    )
  ];
}
