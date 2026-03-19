{
  home = [
    (
      { config, ... }:
      {
        pi.settings.defaultProvider = "copilot";
        pi.mcpServers = {
          terraform = config.pi.mcpServer "terraform-mcp-server stdio";
          slack = config.pi.mcpServer "slack-mcp-server --transport stdio";
        };
      }
    )
  ];
}