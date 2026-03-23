{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "github-copilot";
        pi.settings.defaultModel = "claude-sonnet-4.6";
        pi.settings.defaultThinkingLevel = "high";
        pi.mcpServers = {
          inherit (config.pi.mcp) terraform slack;
          datadog = config.pi.mcp.mkRemoteServer "https://app.datadoghq.com/mcp/sse";
        };
      }
    )
  ];
}
