/**
 * Accidental Send Guard - blocks very short messages that are likely typos.
 *
 * If you type something 3 characters or fewer (excluding whitespace) and press
 * Enter, it won't send to the model. Instead you'll get a notification and your
 * text is put back in the editor so you can keep typing.
 *
 * Slash commands (e.g. /model, /new) and ! shell commands are not affected.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const MIN_LENGTH = 4; // messages must be at least this many non-whitespace chars

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    // Only guard interactive input (not extension-injected or RPC)
    if (event.source !== "interactive") {
      return { action: "continue" };
    }

    const trimmed = event.text.trim();

    // Don't interfere with commands or shell escapes
    if (trimmed.startsWith("/") || trimmed.startsWith("!")) {
      return { action: "continue" };
    }

    // Check if the non-whitespace content is too short
    const nonWhitespace = trimmed.replace(/\s/g, "");
    if (nonWhitespace.length > 0 && nonWhitespace.length < MIN_LENGTH) {
      ctx.ui.notify(`Message too short (${nonWhitespace.length} char${nonWhitespace.length > 1 ? "s" : ""}) — probably a typo. Not sent.`, "warning");
      // Put the text back in the editor so the user can continue typing
      ctx.ui.setEditorText(event.text);
      return { action: "handled" };
    }

    return { action: "continue" };
  });
}
