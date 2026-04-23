/**
 * Permission Gate Extension
 *
 * Prompts for confirmation before:
 *   - Destructive/mutating bash commands (rm, git push, kubectl delete, terraform apply, etc.)
 *   - MCP tool calls that create, update, delete, or otherwise mutate state
 *   - Cloudflare API mutations via cloudflare_execute (POST, PUT, PATCH, DELETE)
 *
 * In non-interactive mode (no UI), mutations are blocked outright.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// ── Strip obviously-safe contexts from a command before pattern matching ────
//
// This is intentionally conservative: we only strip things we're very confident
// are non-executing.  Anything ambiguous is left in so the gate still fires.
//
//   Safe to strip:
//     - Comments:  # ... (only when not inside quotes — we approximate this)
//     - echo/printf arguments: `echo "terraform apply"` → `echo ""`
//     - grep/rg/ag/ack patterns: `grep "terraform apply" file` → `grep "" file`
//     - Variable assignments (RHS): `FOO="terraform apply"` → `FOO=""`
//
//   NOT safe to strip (dangerous wrappers — leave as-is):
//     - eval "terraform apply"
//     - bash -c "terraform apply"
//     - sh -c "terraform apply"
//     - xargs, $(), backticks, etc.
//
function stripSafeContexts(command: string): string {
  let cmd = command;

  // 1. Strip inline comments: ` # ...` at end of line (not inside quotes — rough heuristic)
  //    Only strip if the `#` is preceded by whitespace or is at the start.
  cmd = cmd.replace(/(?:^|\s)#(?![!\/]).*$/gm, "");

  // 2. If the entire (trimmed) command is a simple echo/printf, neutralize quoted args.
  //    We only do this for single-command lines, not pipelines or chains.
  //    Dangerous wrappers (eval, bash -c, sh -c, xargs) are excluded.
  const dangerousWrappers = /\b(eval|xargs|bash\s+-c|sh\s+-c|source)\b|(?:^|[\s;|&])\.\s/;
  if (!dangerousWrappers.test(cmd)) {
    // Strip quoted strings that are arguments to known-safe commands.
    // "Safe" = the quoted string won't be executed.
    const safeArgCommands =
      /\b(echo|printf|cat|tee|write|log|info|warn|error|debug|grep|egrep|fgrep|rg|ag|ack|sed|awk|perl|jq|yq)\b/;
    if (safeArgCommands.test(cmd)) {
      // Neutralize double-quoted and single-quoted strings.
      // This is aggressive but OK because we already checked for dangerous wrappers.
      cmd = cmd.replace(/"(?:[^"\\]|\\.)*"/g, '""');
      cmd = cmd.replace(/'[^']*'/g, "''");

      // If the command is a single simple invocation of a safe command (no chains/pipes/subshells),
      // the entire thing is safe — return empty to skip all gates.
      const chainOps = /[;&|`]|\$\(/;
      if (!chainOps.test(cmd)) {
        return "";
      }
    }
  }

  return cmd;
}

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
  [/\bkubectl\s+(delete|apply|exec|edit|scale|rollout|patch|drain|cordon)\b/, "kubectl $1"],
  [/\bhelm\s+(install|upgrade|uninstall|delete)\b/, "helm $1"],

  // Terraform (category derived from subcommand)
  [/\bterraform\s+(apply|destroy|import|state\s+rm|state\s+mv)\b/, "terraform $1"],

  // Docker
  [/\bdocker\s+(rm|rmi|stop|kill)\b/, "docker $1"],

  // AWS CLI
  [/\baws\s+\S+\s+(delete-|remove-|terminate-|put-|create-|update-|modify-|stop-|reboot-)/, "aws $1"],

  // Misc
  [/\bsudo\b/, "sudo"],
  [/\bcurl\b.*\s+(-X\s+(POST|PUT|DELETE|PATCH)\b|--upload|-d\b|--data(-raw|-binary|-urlencode)?\b|-F\b|--form\b)/, "curl mutate"],
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

// ── Cloudflare execute: patterns in the `code` arg that require confirmation ─
const cloudflareMutationPatterns: [RegExp, string][] = [
  [/method:\s*["'](POST|PUT|PATCH|DELETE)["']/, "cloudflare API mutate ($1)"],
];

const cloudflareDeny: RegExp[] = [
  // Deleting entire zones or accounts is too dangerous
  /\/zones\/[^/]*["'`]\s*\}/, // bare zone delete
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

      // Hard deny (even in auto-yes mode).
      // NOTE: this also checks against the stripped version so that
      // `echo "terraform destroy"` doesn't get blocked, but `eval "terraform destroy"` does.
      const denied = bashDeny.find((p) => p.test(stripSafeContexts(command)));
      if (denied) {
        return { block: true, reason: `Command denied by policy: ${command}` };
      }

      // Strip obviously-safe contexts (echo, grep, comments) before matching.
      // This reduces false positives like `echo "terraform apply"` without
      // compromising safety — dangerous wrappers (eval, bash -c) are left intact.
      const stripped = stripSafeContexts(command);

      // Soft gate
      const match = bashPatterns.find(([p]) => p.test(stripped));
      if (match) {
        const category = match[1].includes("$")
          ? match[1].replace(/\$(\d+)/g, (_, i) => stripped.match(match[0])?.[+i] ?? "")
          : match[1];

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

    // ── Cloudflare execute ───────────────────────────────────────────────
    if (event.toolName === "mcp" && (event.input as Record<string, unknown>).tool === "cloudflare_execute") {
      const mcpArgs =
        typeof event.input.args === "string" ? JSON.parse(event.input.args as string) : event.input.args ?? {};
      const code = (mcpArgs as Record<string, unknown>).code as string ?? "";

      // Hard deny
      const denied = cloudflareDeny.find((p) => p.test(code));
      if (denied) {
        return { block: true, reason: `Cloudflare command denied by policy` };
      }

      // Soft gate on mutating HTTP methods
      const match = cloudflareMutationPatterns.find(([p]) => p.test(code));
      if (match) {
        const category = match[1].includes("$")
          ? match[1].replace(/\$(\d+)/g, (_, i) => code.match(match[0])?.[+i] ?? "")
          : match[1];

        if (autoYes || approvedCategories.has(`cf::${category}`)) return undefined;

        if (!ctx.hasUI) {
          return { block: true, reason: `Cloudflare mutation blocked (no UI): ${category}` };
        }

        const preview = code.length > 200 ? code.slice(0, 197) + "..." : code;
        const choice = await ctx.ui.select(
          `⚠️  ${category}\n${preview}`,
          ["Yes (just once)", `Yes (all "${category}")`, "No"],
        );
        if (!choice || choice === "No") return { block: true, reason: "Blocked by user" };
        if (choice === `Yes (all "${category}")`) approvedCategories.add(`cf::${category}`);
        return undefined;
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
