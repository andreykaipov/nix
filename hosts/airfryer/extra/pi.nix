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
          datadog = config.pi.mcp.mkRemoteServer "https://mcp.datadoghq.com/api/unstable/mcp-server/mcp";
          azure = config.pi.mcp.mkServer "npx -y @azure/mcp@latest server start";
          # Upstream bug: splunk-mcp uses splunklib's token= kwarg (for session keys)
          # instead of splunkToken= (for API/JWT tokens). Override get_splunk_connection
          # to use splunkToken= so splunklib sends "Bearer {t}" not "Splunk Bearer {t}".
          splunk = config.pi.mcp.mkServer ''
            uvx --from 'splunk-mcp @ git+https://github.com/hpreston/splunk-mcp@http' \
            python -c '
import splunk_mcp as s, splunklib.client as c
s.get_splunk_connection = lambda: c.connect(
  host=s.SPLUNK_HOST, port=s.SPLUNK_PORT, splunkToken=s.SPLUNK_TOKEN,
  scheme=s.SPLUNK_SCHEME, verify=s.VERIFY_SSL)
s.mcp.run()
'
          '';
        };
      }
    )
  ];
}
