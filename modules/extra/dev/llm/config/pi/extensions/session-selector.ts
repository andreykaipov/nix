/**
 * Session management — auto-naming + custom /list selector.
 *
 * Auto-naming: captures raw user input (before skill/template expansion) and
 * sets a friendly session name. Prevents skill XML from being the session name.
 *
 * /list: full-featured session selector with colorized names.
 * Supports: search (fuzzy, regex, "phrase"), sort modes (threaded/recent/fuzzy),
 * scope (current folder / all), delete, rename.
 *
 * Ctrl+L: opens /list as a keyboard shortcut.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { SessionManager, type SessionInfo } from "@mariozechner/pi-coding-agent";
import {
	Input, getEditorKeybindings, matchesKey,
	truncateToWidth, visibleWidth, fuzzyMatch,
} from "@mariozechner/pi-tui";
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { unlink } from "node:fs/promises";
import * as os from "node:os";

// ── Color palette ──────────────────────────────────────────────────
const PALETTE = [
	"\x1b[38;5;74m",  "\x1b[38;5;114m", "\x1b[38;5;180m", "\x1b[38;5;139m",
	"\x1b[38;5;109m", "\x1b[38;5;216m", "\x1b[38;5;146m",
	"\x1b[38;5;150m", "\x1b[38;5;174m", "\x1b[38;5;73m",  "\x1b[38;5;179m",
	"\x1b[38;5;108m", "\x1b[38;5;183m", "\x1b[38;5;116m",
];
const RST = "\x1b[39m";

function pickColor(text: string): string {
	let h = 0;
	for (let i = 0; i < text.length; i++) h = ((h << 5) - h + text.charCodeAt(i)) | 0;
	return PALETTE[Math.abs(h) % PALETTE.length];
}

// ── Helpers ────────────────────────────────────────────────────────
const MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

function formatDate(d: Date): string {
	let h = d.getHours();
	const ap = h >= 12 ? "pm" : "am";
	h = h % 12 || 12;
	return `${MONTHS[d.getMonth()]} ${String(d.getDate()).padStart(2)} ${String(h).padStart(2)}:${String(d.getMinutes()).padStart(2,"0")}${ap}`;
}

function formatAge(date: Date): string {
	const diffMs = Date.now() - date.getTime();
	const mins = Math.floor(diffMs / 60000);
	if (mins < 1) return "now";
	if (mins < 60) return `${mins}m`;
	const hrs = Math.floor(diffMs / 3600000);
	if (hrs < 24) return `${hrs}h`;
	const days = Math.floor(diffMs / 86400000);
	if (days < 7) return `${days}d`;
	if (days < 30) return `${Math.floor(days / 7)}w`;
	if (days < 365) return `${Math.floor(days / 30)}mo`;
	return `${Math.floor(days / 365)}y`;
}

function shortenPath(p: string): string {
	const home = os.homedir();
	return p.startsWith(home) ? `~${p.slice(home.length)}` : p;
}

// ── Search / filter ────────────────────────────────────────────────
type ParsedQuery =
	| { mode: "tokens"; tokens: { kind: "fuzzy"|"phrase"; value: string }[] }
	| { mode: "regex"; regex: RegExp | null; error?: string };

function parseQuery(q: string): ParsedQuery {
	const t = q.trim();
	if (!t) return { mode: "tokens", tokens: [] };
	if (t.startsWith("re:")) {
		const p = t.slice(3).trim();
		if (!p) return { mode: "regex", regex: null, error: "Empty regex" };
		try { return { mode: "regex", regex: new RegExp(p, "i") }; }
		catch (e) { return { mode: "regex", regex: null, error: String(e) }; }
	}
	const tokens: { kind: "fuzzy"|"phrase"; value: string }[] = [];
	let buf = "", inQ = false, unclosed = false;
	const flush = (k: "fuzzy"|"phrase") => { const v = buf.trim(); buf = ""; if (v) tokens.push({ kind: k, value: v }); };
	for (const ch of t) {
		if (ch === '"') { if (inQ) { flush("phrase"); inQ = false; } else { flush("fuzzy"); inQ = true; } continue; }
		if (!inQ && /\s/.test(ch)) { flush("fuzzy"); continue; }
		buf += ch;
	}
	if (inQ) unclosed = true;
	if (unclosed) return { mode: "tokens", tokens: t.split(/\s+/).filter(Boolean).map(v => ({ kind: "fuzzy", value: v })) };
	flush(inQ ? "phrase" : "fuzzy");
	return { mode: "tokens", tokens };
}

function matchSession(s: SessionInfo, parsed: ParsedQuery): { matches: boolean; score: number } {
	const text = `${s.id} ${s.name ?? ""} ${s.allMessagesText} ${s.cwd}`;
	if (parsed.mode === "regex") {
		if (!parsed.regex) return { matches: false, score: 0 };
		const idx = text.search(parsed.regex);
		return idx < 0 ? { matches: false, score: 0 } : { matches: true, score: idx * 0.1 };
	}
	if (parsed.tokens.length === 0) return { matches: true, score: 0 };
	let total = 0;
	const norm = text.toLowerCase().replace(/\s+/g, " ").trim();
	for (const tok of parsed.tokens) {
		if (tok.kind === "phrase") {
			const idx = norm.indexOf(tok.value.toLowerCase().replace(/\s+/g, " ").trim());
			if (idx < 0) return { matches: false, score: 0 };
			total += idx * 0.1;
		} else {
			const m = fuzzyMatch(tok.value, text);
			if (!m.matches) return { matches: false, score: 0 };
			total += m.score;
		}
	}
	return { matches: true, score: total };
}

function filterSort(sessions: SessionInfo[], query: string, sort: "threaded"|"recent"|"relevance"): SessionInfo[] {
	const trimmed = query.trim();
	if (!trimmed) return sessions;
	const parsed = parseQuery(query);
	if (parsed.mode === "regex" && parsed.error) return [];
	if (sort === "recent" || sort === "threaded") return sessions.filter(s => matchSession(s, parsed).matches);
	const scored: { session: SessionInfo; score: number }[] = [];
	for (const s of sessions) { const r = matchSession(s, parsed); if (r.matches) scored.push({ session: s, score: r.score }); }
	scored.sort((a, b) => a.score !== b.score ? a.score - b.score : b.session.modified.getTime() - a.session.modified.getTime());
	return scored.map(r => r.session);
}

// ── Delete ─────────────────────────────────────────────────────────
async function deleteSessionFile(path: string): Promise<boolean> {
	const r = spawnSync("trash", [path], { encoding: "utf-8" });
	if (r.status === 0 || !existsSync(path)) return true;
	try { await unlink(path); return true; } catch { return false; }
}

// ── Tree structure (threaded mode) ─────────────────────────────────
interface TreeNode { session: SessionInfo; children: TreeNode[]; }
interface FlatNode { session: SessionInfo; depth: number; isLast: boolean; ancestorContinues: boolean[]; }

function buildSessionTree(sessions: SessionInfo[]): TreeNode[] {
	const byPath = new Map<string, TreeNode>();
	for (const s of sessions) byPath.set(s.path, { session: s, children: [] });
	const roots: TreeNode[] = [];
	for (const s of sessions) {
		const node = byPath.get(s.path)!;
		const parent = s.parentSessionPath;
		if (parent && byPath.has(parent)) byPath.get(parent)!.children.push(node);
		else roots.push(node);
	}
	const sortNodes = (nodes: TreeNode[]) => {
		nodes.sort((a, b) => b.session.modified.getTime() - a.session.modified.getTime());
		for (const n of nodes) sortNodes(n.children);
	};
	sortNodes(roots);
	return roots;
}

function flattenTree(roots: TreeNode[]): FlatNode[] {
	const result: FlatNode[] = [];
	const walk = (node: TreeNode, depth: number, ancestorContinues: boolean[], isLast: boolean) => {
		result.push({ session: node.session, depth, isLast, ancestorContinues });
		for (let i = 0; i < node.children.length; i++) {
			const childIsLast = i === node.children.length - 1;
			const continues = depth > 0 ? !isLast : false;
			walk(node.children[i], depth + 1, [...ancestorContinues, continues], childIsLast);
		}
	};
	for (let i = 0; i < roots.length; i++) walk(roots[i], 0, [], i === roots.length - 1);
	return result;
}

function buildTreePrefix(node: FlatNode): string {
	if (node.depth === 0) return "";
	const parts = node.ancestorContinues.map(c => c ? "│  " : "   ");
	return parts.join("") + (node.isLast ? "└─ " : "├─ ");
}

// ── Shared selector UI ─────────────────────────────────────────────
async function showSessionSelector(
	ctx: ExtensionContext,
	initialCurrentSessions: SessionInfo[],
	initialAllSessions: SessionInfo[] | null,
	currentPath: string | undefined,
): Promise<string | null> {
	let scope: "current" | "all" = "all";
	let sortMode: "threaded" | "recent" | "relevance" = "threaded";
	let currentSessions = initialCurrentSessions;
	let allSessions = initialAllSessions;

	return ctx.ui.custom<string | null>((tui, theme, _keybindings, done) => {
		const kb = getEditorKeybindings();
		const searchInput = new Input();
		let selectedIndex = 0;
		let filtered: FlatNode[] = [];
		let confirmingDelete: string | null = null;
		let renameMode = false;
		let renameTarget: string | null = null;
		const renameInput = new Input();
		let statusMsg: { text: string; color: string } | null = null;
		let statusTimeout: ReturnType<typeof setTimeout> | null = null;
		const maxVisible = 12;

		function getSessions(): SessionInfo[] {
			return scope === "all" ? (allSessions ?? []) : currentSessions;
		}

		function refilter() {
			const sessions = getSessions();
			const query = searchInput.getValue().trim();
			if (sortMode === "threaded" && !query) {
				filtered = flattenTree(buildSessionTree(sessions));
			} else {
				filtered = filterSort(sessions, searchInput.getValue(), sortMode)
					.map(s => ({ session: s, depth: 0, isLast: true, ancestorContinues: [] }));
			}
			selectedIndex = Math.min(selectedIndex, Math.max(0, filtered.length - 1));
		}

		refilter();

		function setStatus(text: string, color: string, ms = 2000) {
			if (statusTimeout) clearTimeout(statusTimeout);
			statusMsg = { text, color };
			statusTimeout = setTimeout(() => { statusMsg = null; tui.requestRender(); }, ms);
		}

		searchInput.onSubmit = () => {
			if (filtered[selectedIndex]) done(filtered[selectedIndex].session.path);
		};

		renameInput.onSubmit = (value: string) => {
			const next = value.trim();
			if (!next || !renameTarget) { renameMode = false; tui.requestRender(); return; }
			const mgr = SessionManager.open(renameTarget);
			mgr.appendSessionInfo(next);
			const update = (list: SessionInfo[] | null) => {
				if (!list) return;
				const s = list.find(s => s.path === renameTarget);
				if (s) s.name = next;
			};
			update(currentSessions);
			update(allSessions);
			renameMode = false;
			renameTarget = null;
			refilter();
			setStatus("Renamed", "accent");
			tui.requestRender();
		};

		return {
			get focused() { return true; },
			set focused(_v: boolean) {
				searchInput.focused = !renameMode;
				renameInput.focused = renameMode;
			},

			render(width: number): string[] {
				const clamp = (l: string) => visibleWidth(l) > width ? truncateToWidth(l, width) : l;
				const lines: string[] = [];
				const border = "─".repeat(width);
				lines.push(theme.fg("accent", border));

				if (renameMode) {
					lines.push(theme.bold(" Rename Session"));
					lines.push("");
					lines.push(...renameInput.render(width));
					lines.push("");
					lines.push(theme.fg("muted", " Enter to save · Esc to cancel"));
					lines.push(theme.fg("accent", border));
					return lines.map(clamp);
				}

				// Header
				const title = scope === "current" ? "Sessions (Current Folder)" : "Sessions (All)";
				const sortLabel = sortMode === "threaded" ? "Threaded" : sortMode === "recent" ? "Recent" : "Fuzzy";
				const scopeText = scope === "current"
					? `${theme.fg("accent","◉ Current")}${theme.fg("muted"," | ○ All")}`
					: `${theme.fg("muted","○ Current | ")}${theme.fg("accent","◉ All")}`;
				const sortText = `${theme.fg("muted","Sort: ")}${theme.fg("accent",sortLabel)}`;
				const rightHeader = truncateToWidth(`${scopeText}  ${sortText}`, width, "");
				const leftHeader = theme.bold(title);
				const availLeft = Math.max(0, width - visibleWidth(rightHeader) - 1);
				const leftTrunc = truncateToWidth(leftHeader, availLeft, "");
				const hdrSpacing = Math.max(1, width - visibleWidth(leftTrunc) - visibleWidth(rightHeader));
				lines.push(`${leftTrunc}${" ".repeat(hdrSpacing)}${rightHeader}`);
				lines.push("");
				lines.push(...searchInput.render(width));
				lines.push("");

				if (filtered.length === 0) {
					lines.push(theme.fg("muted", "  No matching sessions"));
					lines.push("");
					lines.push(theme.fg("accent", border));
					return lines.map(clamp);
				}

				// Session list
				const startIdx = Math.max(0, Math.min(
					selectedIndex - Math.floor(maxVisible / 2),
					filtered.length - maxVisible
				));
				const endIdx = Math.min(startIdx + maxVisible, filtered.length);

				let maxDirWidth = 0;
				if (scope === "all") {
					for (let i = startIdx; i < endIdx; i++) {
						const cwd = filtered[i].session.cwd;
						const dn = cwd ? (shortenPath(cwd).split("/").pop() || "").length : 0;
						if (dn > maxDirWidth) maxDirWidth = dn;
					}
					if (maxDirWidth > 0) maxDirWidth += 1;
				}

				for (let i = startIdx; i < endIdx; i++) {
					const node = filtered[i];
					const s = node.session;
					const isSelected = i === selectedIndex;
					const isCurrent = s.path === currentPath;
					const isDeleting = s.path === confirmingDelete;

					const displayText = (s.name ?? s.firstMessage).replace(/[\x00-\x1f\x7f]/g, " ").trim();
					const treePrefix = buildTreePrefix(node);
					const treePrefixWidth = visibleWidth(treePrefix);
					const dateCol = formatDate(s.modified).padEnd(15);
					const cursor = isSelected ? theme.fg("accent", "▶ ") : "  ";
					const dirName = (scope === "all" && s.cwd) ? shortenPath(s.cwd).split("/").pop() || "" : "";
					const dirColWidth = maxDirWidth;
					const dirCol = dirColWidth ? truncateToWidth(dirName, dirColWidth - 1).padEnd(dirColWidth) : "";
					const age = formatAge(s.modified);
					const countAge = `${String(s.messageCount).padStart(4)} ${age.padStart(3)}`;
					const countAgeWidth = visibleWidth(countAge);

					const available = Math.min(80, Math.max(10, width - 2 - 15 - dirColWidth - treePrefixWidth));
					const truncated = displayText.length > available
						? displayText.slice(0, Math.max(0, available - 3)) + "..."
						: displayText;

					const color = pickColor(displayText);
					let styledDate: string, styledDir: string, styledName: string, styledRight: string;
					if (isDeleting) {
						styledDate = theme.fg("error", dateCol);
						styledDir = dirColWidth ? theme.fg("error", dirCol) : "";
						styledName = theme.fg("error", truncated);
						styledRight = theme.fg("error", countAge);
					} else {
						styledDate = theme.fg("dim", dateCol);
						styledDir = dirColWidth ? theme.fg("muted", dirCol) : "";
						styledName = isCurrent
							? theme.bold(`${color}${truncated}${RST}`) + "  " + theme.fg("accent", "◀ active")
							: `${color}${truncated}${RST}`;
						styledRight = theme.fg("dim", countAge);
					}

					const leftPart = cursor + styledDate + styledDir + theme.fg("dim", treePrefix) + styledName;
					const leftWidth = visibleWidth(leftPart);
					const spacing = Math.max(1, width - leftWidth - countAgeWidth);
					let line = leftPart + " ".repeat(spacing) + styledRight;
					if (isCurrent) line = theme.bold(line);
					if (isSelected) line = theme.bg("selectedBg", line);
					lines.push(line);
				}

				if (filtered.length > maxVisible) {
					lines.push(theme.fg("muted", `  (${selectedIndex + 1}/${filtered.length})`));
				}

				// Footer
				lines.push("");
				if (statusMsg) {
					lines.push(theme.fg(statusMsg.color as any, ` ${statusMsg.text}`));
				} else if (confirmingDelete) {
					lines.push(theme.fg("error", " Delete session? [Enter] confirm · [Esc] cancel"));
				} else {
					const sep = theme.fg("muted", " · ");
					lines.push(theme.fg("dim", ` ${["↑↓ navigate","enter select","esc cancel","tab scope","ctrl+s sort","ctrl+d delete","ctrl+r rename"].join(sep)}`));
					lines.push(theme.fg("dim", ` re:<pattern> regex · "phrase" exact`));
				}
				lines.push(theme.fg("accent", border));
				return lines.map(clamp);
			},

			invalidate() {},

			handleInput(data: string) {
				if (renameMode) {
					if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
						renameMode = false; renameTarget = null;
					} else { renameInput.handleInput(data); }
					tui.requestRender(); return;
				}

				if (confirmingDelete) {
					if (kb.matches(data, "selectConfirm") || matchesKey(data, "enter")) {
						const path = confirmingDelete;
						confirmingDelete = null;
						deleteSessionFile(path).then(ok => {
							if (ok) {
								for (const list of [currentSessions, allSessions]) {
									if (!list) continue;
									const idx = list.findIndex(s => s.path === path);
									if (idx !== -1) list.splice(idx, 1);
								}
								refilter();
								setStatus("Session deleted", "accent");
							} else { setStatus("Delete failed", "error"); }
							tui.requestRender();
						});
					} else if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
						confirmingDelete = null;
					}
					tui.requestRender(); return;
				}

				if (matchesKey(data, "escape")) { done(null); }
				else if (kb.matches(data, "selectUp") || matchesKey(data, "up")) { selectedIndex = Math.max(0, selectedIndex - 1); }
				else if (kb.matches(data, "selectDown") || matchesKey(data, "down")) { selectedIndex = Math.min(filtered.length - 1, selectedIndex + 1); }
				else if (kb.matches(data, "selectPageUp")) { selectedIndex = Math.max(0, selectedIndex - maxVisible); }
				else if (kb.matches(data, "selectPageDown")) { selectedIndex = Math.min(filtered.length - 1, selectedIndex + maxVisible); }
				else if (kb.matches(data, "selectConfirm") || matchesKey(data, "enter")) {
					if (filtered[selectedIndex]) done(filtered[selectedIndex].session.path);
				}
				else if (kb.matches(data, "tab")) {
					if (scope === "current") {
						scope = "all";
						if (!allSessions) {
							setStatus("Loading all sessions...", "muted", 10000);
							tui.requestRender();
							SessionManager.listAll().then(list => {
								allSessions = list;
								allSessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
								statusMsg = null;
								refilter(); tui.requestRender();
							});
						} else { refilter(); }
					} else { scope = "current"; refilter(); }
				}
				else if (kb.matches(data, "toggleSessionSort") || matchesKey(data, "ctrl+s")) {
					sortMode = sortMode === "threaded" ? "recent" : sortMode === "recent" ? "relevance" : "threaded";
					refilter();
				}
				else if (kb.matches(data, "deleteSession") || matchesKey(data, "ctrl+d")) {
					const sel = filtered[selectedIndex];
					if (sel && sel.session.path !== currentPath) { confirmingDelete = sel.session.path; }
					else if (sel?.session.path === currentPath) { setStatus("Cannot delete active session", "error"); }
				}
				else if (matchesKey(data, "ctrl+r")) {
					const sel = filtered[selectedIndex];
					if (sel) {
						renameMode = true; renameTarget = sel.session.path;
						renameInput.setValue(sel.session.name ?? ""); renameInput.focused = true;
					}
				}
				else { searchInput.handleInput(data); refilter(); }
				tui.requestRender();
			},
		};
	});
}

// ── Extension ──────────────────────────────────────────────────────
export default function (pi: ExtensionAPI) {
	let named = false;

	// Auto-name on session start/switch
	pi.on("session_start", async (_event, _ctx) => {
		named = !!pi.getSessionName();
	});

	pi.on("session_switch", async () => { named = !!pi.getSessionName(); });

	// Auto-naming
	pi.on("input", async (event) => {
		if (named) return { action: "continue" as const };
		let text = event.text.trim();
		if (!text) return { action: "continue" as const };
		text = text.replace(/^\/skill:\S+\s*/, "").trim();
		if (!text) {
			const match = event.text.match(/^\/skill:(\S+)/);
			if (match) text = match[1];
		}
		if (!text || text.startsWith("/")) return { action: "continue" as const };
		pi.setSessionName(text.split("\n")[0].slice(0, 120));
		named = true;
		return { action: "continue" as const };
	});

	// Internal: switch session by path (shortcuts can't call switchSession directly)
	let pendingSwitchPath: string | null = null;

	pi.registerCommand("_session-switch", {
		description: "Switch to session by path (internal)",
		handler: async (_args, ctx) => {
			const path = pendingSwitchPath;
			pendingSwitchPath = null;
			if (path) await ctx.switchSession(path);
		},
	});

	// Ctrl+L shortcut — show session selector
	pi.registerShortcut("ctrl+l", {
		description: "Browse sessions",
		handler: async (ctx) => {
			const cwd = ctx.cwd;
			const sessionDir = ctx.sessionManager.getSessionDir();
			const currentPath = ctx.sessionManager.getSessionFile();
			const currentSessions = await SessionManager.list(cwd, sessionDir);
			currentSessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
			const allSessions = await SessionManager.listAll();
			allSessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
			if (allSessions.length === 0) { ctx.ui.notify("No sessions found", "info"); return; }
			const selected = await showSessionSelector(ctx, currentSessions, allSessions, currentPath);
			if (selected) {
				pendingSwitchPath = selected;
				// sendUserMessage skips command handling, so inject via editor + Enter.
				// Delay a tick to ensure the custom UI overlay is fully dismissed.
				await new Promise(r => setTimeout(r, 0));
				ctx.ui.setEditorText("/_session-switch");
				process.stdin.emit("data", "\r");
			}
		},
	});

	// /list command
	pi.registerCommand("list", {
		description: "Browse and select from past sessions",
		handler: async (_args, ctx) => {
			const cwd = ctx.cwd;
			const sessionDir = ctx.sessionManager.getSessionDir();
			const currentPath = ctx.sessionManager.getSessionFile();

			const currentSessions = await SessionManager.list(cwd, sessionDir);
			currentSessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());
			const allSessions = await SessionManager.listAll();
			allSessions.sort((a, b) => b.modified.getTime() - a.modified.getTime());

			if (allSessions.length === 0) {
				ctx.ui.notify("No sessions found", "info");
				return;
			}

			const selected = await showSessionSelector(ctx, currentSessions, allSessions, currentPath);
			if (selected) {
				await ctx.switchSession(selected);
			}
		},
	});
}
