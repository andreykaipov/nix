{
  pkgs,
  lib,
  host,
  config,
  ...
}:

let
  mcpServer = cmd: {
    lifecycle = "lazy";
    command = "bash";
    args = [
      "-c"
      ". ~/.config/zsh/config/zshenv.secrets && exec ${cmd}"
    ];
  };

  mcpConfig = {
    settings = {
      toolPrefix = "short";
      idleTimeout = 10;
    };
    inherit (config.pi) mcpServers;
  };

  settingsConfig = {
    defaultThinkingLevel = "high";
    theme = "auto";
  }
  // config.pi.settings;
in
{
  options.pi = {
    mcpServer = lib.mkOption {
      type = lib.types.raw;
      default = mcpServer;
      readOnly = true;
      description = "Helper: creates a lazy MCP server entry that sources zshenv.secrets";
    };
    mcpServers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "MCP servers for pi's mcp.json";
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings to merge into pi's settings.json";
    };
  };

  config = {
    home.packages = with pkgs; [
      llm-agents.pi
      spec-kit
      terraform-mcp-server
      slack-mcp-server
    ];

    home.file."bin-extra/slack-mcp-env" = host.symlinkTo ./slack-mcp-env;

    # Pi: ~/.pi/agent/
    home.file.".pi/agent/settings.json".text = builtins.toJSON settingsConfig;
    home.file.".pi/agent/mcp.json".text = builtins.toJSON mcpConfig;
    home.file.".pi/agent/themes" = host.symlinkTo ./config/pi/themes;
    home.file.".pi/agent/extensions" = host.symlinkTo ./config/pi/extensions;

    home.activation.piPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v pi &> /dev/null; then
        printf "installing pi packages... "
        pi install npm:pi-mcp-adapter 2>/dev/null || true
        echo "done"
      fi
    '';
  };
}
