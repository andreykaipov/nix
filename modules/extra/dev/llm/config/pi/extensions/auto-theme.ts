import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { writeFileSync, readFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";

// Read terminal colors from the tmux colorscheme cache (written by
// tmux-colorscheme-sync.nvim) and generate a matching pi theme.

const CACHE_FILE = join(
  process.env.HOME || "~",
  ".local/state/tmux/colorscheme-cache.conf"
);

function readCachedColors(): Record<string, string> {
  const colors: Record<string, string> = {};
  try {
    const content = readFileSync(CACHE_FILE, "utf-8");
    for (const line of content.split("\n")) {
      // set -g @nvim_color_normal_bg '#11262d'
      const match = line.match(
        /set -g @nvim_color_(\S+)\s+'([^']+)'/
      );
      if (match) colors[match[1]] = match[2];
    }
  } catch { }
  return colors;
}

function generateTheme(colors: Record<string, string>): object {
  const bg = colors.normal_bg || "";
  const lighterBg = colors.normal_lighter_bg || "";
  const darkerBg = colors.normal_bg || "";
  const fg = colors.normal_fg || "";
  const tablineBg = colors.tabline_bg || "";

  return {
    $schema:
      "https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json",
    name: "auto",
    vars: {
      cyan: "#00d7ff",
      blue: "#5f87ff",
      green: "#b5bd68",
      red: "#cc6666",
      yellow: "#ffff00",
      gray: "#808080",
      dimGray: "#666666",
      darkGray: "#505050",
      accent: "#8abeb7",
      bg,
      lighterBg,
      darkerBg,
      fg,
    },
    colors: {
      accent: "accent",
      border: "blue",
      borderAccent: "cyan",
      borderMuted: "darkGray",
      success: "green",
      error: "red",
      warning: "yellow",
      muted: "gray",
      dim: "dimGray",
      text: "",
      thinkingText: "gray",

      selectedBg: "lighterBg",
      userMessageBg: "lighterBg",
      userMessageText: "",
      customMessageBg: "lighterBg",
      customMessageText: "",
      customMessageLabel: "#9575cd",
      toolPendingBg: "darkerBg",
      toolSuccessBg: "darkerBg",
      toolErrorBg: "darkerBg",
      toolTitle: "",
      toolOutput: "gray",

      mdHeading: "#f0c674",
      mdLink: "#81a2be",
      mdLinkUrl: "dimGray",
      mdCode: "accent",
      mdCodeBlock: "green",
      mdCodeBlockBorder: "gray",
      mdQuote: "gray",
      mdQuoteBorder: "gray",
      mdHr: "gray",
      mdListBullet: "accent",

      toolDiffAdded: "green",
      toolDiffRemoved: "red",
      toolDiffContext: "gray",

      syntaxComment: "#6A9955",
      syntaxKeyword: "#569CD6",
      syntaxFunction: "#DCDCAA",
      syntaxVariable: "#9CDCFE",
      syntaxString: "#CE9178",
      syntaxNumber: "#B5CEA8",
      syntaxType: "#4EC9B0",
      syntaxOperator: "#D4D4D4",
      syntaxPunctuation: "#D4D4D4",

      thinkingOff: "darkGray",
      thinkingMinimal: "#6e6e6e",
      thinkingLow: "#5f87af",
      thinkingMedium: "#81a2be",
      thinkingHigh: "#b294bb",
      thinkingXhigh: "#d183e8",

      bashMode: "green",
    },
  };
}

export default function (pi: ExtensionAPI) {
  const themesDir = join(process.env.HOME || "~", ".pi", "agent", "themes");
  const themePath = join(themesDir, "auto.json");

  const colors = readCachedColors();
  if (colors.normal_bg) {
    const theme = generateTheme(colors);
    if (!existsSync(themesDir)) mkdirSync(themesDir, { recursive: true });
    writeFileSync(themePath, JSON.stringify(theme, null, "\t") + "\n");
  }
}
