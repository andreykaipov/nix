import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "mcp") return;

    const args = event.input as Record<string, unknown>;
    if (args.tool !== "slack_conversations_add_message") return;

    const mcpArgs = typeof args.args === "string" ? JSON.parse(args.args) : args.args;
    const channel = mcpArgs?.channel_id ?? "unknown";
    const text = mcpArgs?.text ?? "";
    const thread = mcpArgs?.thread_ts ? ` (thread)` : "";

    const preview = `Channel: ${channel}${thread}\n\n${text}`;
    const ok = await ctx.ui.confirm("Post to Slack?", preview);
    if (!ok) return { block: true, reason: "User cancelled Slack message" };
  });
}
