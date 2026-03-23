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
  /\bgit\s+push\s+(--force|-f)\b/,
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
  pi.on("tool_call", async (event, ctx) => {
    // ── Bash commands ─────────────────────────────────────────────────────
    if (event.toolName === "bash") {
      const command = event.input.command as string;

      // Hard deny
      const denied = bashDeny.find((p) => p.test(command));
      if (denied) {
        return { block: true, reason: `Command denied by policy: ${command}` };
      }

      // Soft gate
      const match = bashPatterns.find(([p]) => p.test(command));
      if (match) {
        if (!ctx.hasUI) {
          return { block: true, reason: `Destructive command blocked (no UI): ${match[1]}` };
        }
        const ok = await ctx.ui.confirm(
          `⚠️  ${match[1]}`,
          command.length > 120 ? command.slice(0, 117) + "..." : command,
        );
        if (!ok) return { block: true, reason: "Blocked by user" };
      }

      return undefined;
    }

    // ── MCP tool calls (non-builtin) ──────────────────────────────────────
    if (!builtinTools.has(event.toolName)) {
      const isMutation = mcpMutationPatterns.some((p) => p.test(event.toolName));
      if (isMutation) {
        if (!ctx.hasUI) {
          return { block: true, reason: `MCP mutation blocked (no UI): ${event.toolName}` };
        }

        const { title, preview } = formatMcpConfirm(event.toolName, event.input);
        const ok = await ctx.ui.confirm(title, preview);
        if (!ok) return { block: true, reason: "Blocked by user" };
      }
    }

    return undefined;
  });
}
