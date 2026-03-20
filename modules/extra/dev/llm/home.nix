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

  mcpRemoteServer = url: {
    lifecycle = "lazy";
    inherit url;
    auth = "oauth";
  };

  mcpConfig = {
    settings = {
      toolPrefix = "short";
      idleTimeout = 10;
    };
    inherit (config.pi) mcpServers;
  };

  settingsConfig = {
    defaultThinkingLevel = "medium";
    theme = "auto";
    packages = [
      "npm:pi-mcp-adapter"
    ];
  }
  // config.pi.settings;
in
{
  options.pi = {
    mcp = {
      mkServer = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        description = "Helper: creates a lazy MCP server entry that sources zshenv.secrets";
        default = mcpServer;
      };
      mkRemoteServer = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        description = "Helper: creates a lazy remote MCP server entry with OAuth";
        default = mcpRemoteServer;
      };
      terraform = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        description = "Terraform MCP server definition";
        default = mcpServer "terraform-mcp-server stdio --toolsets= --tools=search_providers,get_provider_details,get_latest_provider_version,search_modules,get_module_details,get_latest_module_version,list_terraform_projects,list_workspaces,get_workspace_details,list_runs,get_run_details,get_plan_details,get_plan_logs,get_apply_details,get_apply_logs,list_workspace_variables,list_variable_sets,read_workspace_tags";
      };
      slack = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        description = "Slack MCP server definition";
        default = mcpServer "slack-mcp-server --transport stdio" // {
          exposeResources = false; # no resources to avoid bulk user queries
        };
      };
    };
    mcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      description = "MCP servers for pi's mcp.json";
      default = { };
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      description = "Additional settings to merge into pi's settings.json";
      default = { };
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
    # Symlink the rest of the configs so it's easier to edit on the fly
    home.file.".pi/agent/keybindings.json" = host.symlinkTo ./config/pi/keybindings.json;
    home.file.".pi/agent/themes" = host.symlinkTo ./config/pi/themes;
    home.file.".pi/agent/extensions" = host.symlinkTo ./config/pi/extensions;
    home.file.".pi/agent/skills" = host.symlinkTo ./config/pi/skills;

    # Patch pi-mcp-adapter with renderCall/renderResult (PR #8)
    home.activation.patchPiMcpAdapter = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      adapter="$HOME/.npm-global/lib/node_modules/pi-mcp-adapter/index.ts"
      patch_file="${./pi-mcp-adapter-render.patch}"
      if [ -f "$adapter" ]; then
        if ! grep -q "renderMcpToolCall" "$adapter" 2>/dev/null; then
          ${pkgs.patch}/bin/patch -s -p0 "$adapter" "$patch_file" 2>/dev/null && \
            echo "Patched pi-mcp-adapter with renderCall/renderResult" || \
            echo "Warning: pi-mcp-adapter patch failed (version mismatch?)"
        fi
      fi
    '';

  };
}
