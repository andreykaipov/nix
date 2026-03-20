{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "amazon-bedrock";
        pi.settings.defaultModel = "claude-opus-4.6";
        pi.settings.defaultThinkingLevel = "high";
        pi.mcpServers = {
          inherit (config.pi.mcp) terraform slack;
          atlassian = config.pi.mcp.mkServer "TOOLSETS=default,jira_links uvx mcp-atlassian";
          argocd = config.pi.mcp.mkServer "MCP_READ_ONLY=true npx argocd-mcp@latest stdio";
          grafana = config.pi.mcp.mkServer "uvx mcp-grafana";
          cloudflare = config.pi.mcp.mkRemoteServer "https://mcp.cloudflare.com/mcp";
        };
      }
    )
  ];
}
