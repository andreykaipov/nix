{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "github-copilot";
        pi.settings.defaultModel = "claude-opus-4.6-1m";
        pi.settings.defaultThinkingLevel = "high";
        pi.mcpServers = {
          inherit (config.pi.mcp) terraform slack;
          datadog = config.pi.mcp.mkRemoteServer "https://app.datadoghq.com/mcp/sse";
        };
      }
    )
  ];
}
