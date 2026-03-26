/**
 * Permission Gate Extension
 *
 * Prompts for confirmation before:
 *   - Destructive/mutating bash commands (rm, git push, kubectl delete, terraform apply, etc.)
 *   - MCP tool calls that create, update, delete, or otherwise mutate state
 *
 * In non-interactive mode (no UI), mutations are blocked outright.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// ── Bash command patterns that require confirmation ─────────────────────────
const bashPatterns: [RegExp, string][] = [
  // File operations
  [/\brm\b/, "rm"],
  [/\brmdir\b/, "rmdir"],
  [/\bmv\s+\//, "mv (absolute path)"],

  // Git
  [/\bgit\s+push\b/, "git push"],
  [/\bgit\s+reset\s+--hard\b/, "git reset --hard"],
  [/\bgit\s+clean\b/, "git clean"],
  [/\bgit\s+rebase\b/, "git rebase"],
  [/\bgit\s+merge\b/, "git merge"],
  [/\bgit\s+(checkout\s+--|restore)\b/, "git restore/checkout"],

  // Kubernetes
  [/\bkubectl\s+(delete|apply|exec|edit|scale|rollout|patch|drain|cordon)\b/, "kubectl mutate"],
  [/\bhelm\s+(install|upgrade|uninstall|delete)\b/, "helm mutate"],

  // Terraform
  [/\bterraform\s+(apply|destroy|import|state)\b/, "terraform mutate"],

  // Docker
  [/\bdocker\s+(rm|rmi|stop|kill)\b/, "docker mutate"],

  // AWS CLI
  [/\baws\s+\S+\s+(delete-|remove-|terminate-|put-|create-|update-|modify-|stop-|reboot-)/, "aws mutate"],

  // Misc
  [/\bsudo\b/, "sudo"],
  [/\b(chmod|chown)\b/, "chmod/chown"],
  [/\bcurl\b.*\s+(-X\s+(POST|PUT|DELETE|PATCH)\b|--upload)/, "curl mutate"],
  [/\bkill(all)?\b/, "kill"],
  [/\bpkill\b/, "pkill"],
];

// Deny outright (even with confirmation)
const bashDeny: RegExp[] = [
  /\bterraform\s+destroy\b/,
  /\bdd\b/,
  /\bmkfs\b/,
];

// ── MCP tool names that require confirmation (substring match) ──────────────
// These cover Slack, Atlassian, ArgoCD, and general patterns.
const mcpMutationPatterns: RegExp[] = [
  /\b(create|update|delete|remove|add|edit|transition|mark|move|reply|uninstall|apply|patch|scale|rollout|drain)\b/i,
];

// Built-in tools that are always safe
const builtinTools = new Set(["bash", "read", "write", "edit", "mcp"]);

// ── Nice previews for specific MCP tools ────────────────────────────────────
function formatMcpConfirm(
  toolName: string,
  input: Record<string, unknown>,
): { title: string; preview: string } {
  // Slack message — show channel, thread, and message text
  if (input.tool === "slack_conversations_add_message") {
    const mcpArgs =
      typeof input.args === "string" ? JSON.parse(input.args) : input.args ?? {};
    const channel = (mcpArgs as Record<string, unknown>).channel_id ?? "unknown";
    const text = (mcpArgs as Record<string, unknown>).text ?? "";
    const thread = (mcpArgs as Record<string, unknown>).thread_ts ? " (thread)" : "";
    return { title: "Post to Slack?", preview: `Channel: ${channel}${thread}\n\n${text}` };
  }

  // Default — generic JSON preview
  const args = JSON.stringify(input, null, 2);
  const preview = args.length > 200 ? args.slice(0, 197) + "..." : args;
  return { title: `⚠️  ${toolName}`, preview };
}

export default function (pi: ExtensionAPI) {
  // Track approved commands/categories in this session
  const approvedCommands = new Set<string>();
  const approvedCategories = new Set<string>();
  let autoYes = false;

  pi.registerCommand("yolo", {
    description: "Toggle auto-approve all permission gates",
    handler: async (_args, ctx) => {
      autoYes = !autoYes;
      ctx.ui.notify(autoYes ? "Permission gate: auto-yes ON" : "Permission gate: auto-yes OFF", autoYes ? "warning" : "info");
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    // ── Bash commands ─────────────────────────────────────────────────────
    if (event.toolName === "bash") {
      const command = event.input.command as string;

      // Hard deny (even in auto-yes mode)
      const denied = bashDeny.find((p) => p.test(command));
      if (denied) {
        return { block: true, reason: `Command denied by policy: ${command}` };
      }

      // Soft gate
      const match = bashPatterns.find(([p]) => p.test(command));
      if (match) {
        const category = match[1];

        // Skip if auto-yes, exact command, or category is approved
        if (autoYes || approvedCommands.has(command) || approvedCategories.has(category)) return undefined;

        if (!ctx.hasUI) {
          return { block: true, reason: `Destructive command blocked (no UI): ${category}` };
        }
        const preview = command.length > 120 ? command.slice(0, 117) + "..." : command;
        const choice = await ctx.ui.select(
          `⚠️  ${category}: ${preview}`,
          ["Yes (just once)", "Yes (this command)", `Yes (all "${category}")`, "No"],
        );
        if (!choice || choice === "No") return { block: true, reason: "Blocked by user" };
        if (choice === "Yes (this command)") approvedCommands.add(command);
        if (choice === `Yes (all "${category}")`) approvedCategories.add(category);
      }

      return undefined;
    }

    // ── MCP tool calls (non-builtin) ──────────────────────────────────────
    if (!builtinTools.has(event.toolName)) {
      const isMutation = mcpMutationPatterns.some((p) => p.test(event.toolName));
      if (isMutation) {
        const mcpKey = `${event.toolName}::${JSON.stringify(event.input)}`;

        // Skip if auto-yes, exact call, or tool name is approved
        if (autoYes || approvedCommands.has(mcpKey) || approvedCategories.has(event.toolName)) return undefined;

        if (!ctx.hasUI) {
          return { block: true, reason: `MCP mutation blocked (no UI): ${event.toolName}` };
        }

        const { title, preview } = formatMcpConfirm(event.toolName, event.input);
        const choice = await ctx.ui.select(
          `${title}\n${preview}`,
          ["Yes (just once)", "Yes (this call)", `Yes (all "${event.toolName}")`, "No"],
        );
        if (!choice || choice === "No") return { block: true, reason: "Blocked by user" };
        if (choice === "Yes (this call)") approvedCommands.add(mcpKey);
        if (choice === `Yes (all "${event.toolName}")`) approvedCategories.add(event.toolName);
      }
    }

    return undefined;
  });
}
