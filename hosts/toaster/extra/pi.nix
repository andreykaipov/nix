{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "amazon-bedrock";
        pi.mcpServers = {
          terraform = config.pi.mcpServer "terraform-mcp-server stdio";
          slack = config.pi.mcpServer "slack-mcp-server --transport stdio";
          atlassian = config.pi.mcpServer "uvx mcp-atlassian";
          argocd = config.pi.mcpServer "npx argocd-mcp@latest stdio";
          grafana = config.pi.mcpServer "uvx mcp-grafana";
        };
      }
    )
  ];
}