/**
 * Tests for Permission Gate Extension
 *
 * Run from ~/gh/nix:
 *   npx tsx --test modules/extra/dev/llm/config/pi/tests/permission-gate.test.ts
 *
 * Uses node:test + node:assert (no deps). Mocks ExtensionAPI to capture
 * the tool_call handler, then asserts block/allow for various scenarios.
 */

import { describe, it } from "node:test";
import assert from "node:assert/strict";

// ── Minimal mocks ───────────────────────────────────────────────────────────

type Handler = (event: any, ctx: any) => Promise<any>;

function createMockPi() {
  const handlers: Record<string, Handler[]> = {};
  const commands: Record<string, any> = {};

  return {
    on(event: string, handler: Handler) {
      (handlers[event] ??= []).push(handler);
    },
    registerCommand(name: string, opts: any) {
      commands[name] = opts;
    },
    _handlers: handlers,
    _commands: commands,
  };
}

function createMockCtx({ hasUI = true }: { hasUI?: boolean } = {}) {
  let lastSelect: { title: string; options: string[] } | undefined;
  let selectResponse: string | undefined = "Yes (just once)";

  return {
    hasUI,
    ui: {
      async select(title: string, options: string[]) {
        lastSelect = { title, options };
        return selectResponse;
      },
      notify() {},
    },
    _setSelectResponse(r: string | undefined) {
      selectResponse = r;
    },
    _getLastSelect() {
      return lastSelect;
    },
  };
}

// ── Load a fresh extension instance (new closure each time) ─────────────────

function loadFreshExtension() {
  const pi = createMockPi();

  // Re-import the default export. Since ESM caches the module, every call
  // gets the same *factory function*, but calling it with a fresh mock pi
  // creates a new closure (new approvedCommands, approvedCategories, autoYes).
  // We import once at the top and then call it per-test.
  return { pi };
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function mcpEvent(tool: string, args: Record<string, unknown> = {}) {
  return {
    toolName: "mcp",
    input: { tool, args: JSON.stringify(args) },
  };
}

function bashEvent(command: string) {
  return { toolName: "bash", input: { command } };
}

// Import the factory (module is cached, but calling it creates a fresh closure)
import extensionFactory from "../extensions/permission-gate.ts";

/** Create a fresh extension instance and return handler + yolo command */
function setup() {
  const pi = createMockPi();
  extensionFactory(pi as any);

  const handler = pi._handlers["tool_call"]![0];
  const yoloCmd = pi._commands["yolo"];
  return { handler, yoloCmd };
}

describe("permission-gate", () => {
  // ── MCP gateway (the bug that was fixed) ────────────────────────────────

  describe("MCP gateway inner tool gating", () => {
    it("gates slack_conversations_add_message (matches 'add')", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("slack_conversations_add_message", { channel_id: "C123", text: "hello" }), ctx);
      assert.ok(ctx._getLastSelect(), "Expected a confirmation prompt");
    });

    it("gates atlassian_jira_create_issue (matches 'create')", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("atlassian_jira_create_issue", { project: "CORE" }), ctx);
      assert.ok(ctx._getLastSelect(), "Expected a confirmation prompt");
    });

    it("gates atlassian_jira_transition_issue (matches 'transition')", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("atlassian_jira_transition_issue", { issue_key: "CORE-1" }), ctx);
      assert.ok(ctx._getLastSelect(), "Expected a confirmation prompt");
    });

    it("gates argocd_app_patch (matches 'patch')", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("argocd_app_patch", { app: "my-app" }), ctx);
      assert.ok(ctx._getLastSelect(), "Expected a confirmation prompt for 'patch'");
    });

    it("allows slack_conversations_history (read-only)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("slack_conversations_history", { channel_id: "C123" }), ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should NOT prompt for read-only tool");
    });

    it("allows slack_conversations_search_messages (read-only)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("slack_conversations_search_messages", { query: "test" }), ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should NOT prompt for search");
    });

    it("allows atlassian_jira_get_issue (read-only)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("atlassian_jira_get_issue", { issue_key: "CORE-1" }), ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should NOT prompt for get");
    });

    it("allows terraform_list_runs (read-only)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(mcpEvent("terraform_list_runs", { workspace_id: "ws-123" }), ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should NOT prompt for list");
    });

    it("blocks MCP mutation in non-interactive mode", async () => {
      const { handler } = setup();
      const ctx = createMockCtx({ hasUI: false });
      const result = await handler(mcpEvent("slack_conversations_add_message", { text: "hi" }), ctx);
      assert.ok(result?.block, "Should block mutation without UI");
      assert.match(result.reason, /slack_conversations_add_message/);
    });

    it("blocks when user selects No", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      ctx._setSelectResponse("No");
      const result = await handler(mcpEvent("slack_conversations_add_message", { text: "hi" }), ctx);
      assert.ok(result?.block, "Should block when user says No");
    });

    it("shows Slack-specific preview for add_message", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(
        mcpEvent("slack_conversations_add_message", {
          channel_id: "C010ZDG1ACB",
          text: "hey team, looks good",
          thread_ts: "1234.5678",
        }),
        ctx,
      );
      const prompt = ctx._getLastSelect();
      assert.ok(prompt, "Expected a prompt");
      assert.ok(prompt.title.includes("Post to Slack"), "Should show Slack-specific title");
      assert.ok(prompt.title.includes("C010ZDG1ACB"), "Should show channel");
      assert.ok(prompt.title.includes("(thread)"), "Should indicate thread");
      assert.ok(prompt.title.includes("hey team, looks good"), "Should show message text");
    });

    it("remembers 'Yes (all)' for inner tool name across calls", async () => {
      const { handler } = setup();

      // First call — user approves all for this tool
      const ctx1 = createMockCtx();
      ctx1._setSelectResponse('Yes (all "slack_conversations_add_message")');
      await handler(mcpEvent("slack_conversations_add_message", { text: "first" }), ctx1);
      assert.ok(ctx1._getLastSelect(), "First call should prompt");

      // Second call — same handler closure, should be auto-approved
      const ctx2 = createMockCtx();
      const result2 = await handler(mcpEvent("slack_conversations_add_message", { text: "second" }), ctx2);
      assert.equal(ctx2._getLastSelect(), undefined, "Second call should NOT prompt");
      assert.equal(result2, undefined, "Should allow without prompting");
    });
  });

  // ── Non-gateway direct tool calls ──────────────────────────────────────

  describe("non-gateway MCP tool calls (toolName != 'mcp')", () => {
    it("gates a direct mutation tool call", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler({ toolName: "some_create_resource", input: { name: "test" } }, ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for direct mutation tool");
    });

    it("allows a direct read-only tool call", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler({ toolName: "some_list_resources", input: {} }, ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should not prompt for non-mutation");
    });
  });

  // ── Bash gating ─────────────────────────────────────────────────────────

  describe("bash commands", () => {
    it("gates rm command", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(bashEvent("rm -rf /tmp/foo"), ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for rm");
    });

    it("gates git push", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(bashEvent("git push origin main"), ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for git push");
    });

    it("gates kubectl delete", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(bashEvent("kubectl delete pod my-pod"), ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for kubectl delete");
    });

    it("allows safe commands (ls, cat, grep)", async () => {
      const { handler } = setup();
      for (const cmd of ["ls -la", "cat foo.txt", "grep pattern file"]) {
        const ctx = createMockCtx();
        await handler(bashEvent(cmd), ctx);
        assert.equal(ctx._getLastSelect(), undefined, `Should not prompt for: ${cmd}`);
      }
    });

    it("does NOT gate rm inside echo (safe context stripping)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(bashEvent('echo "rm -rf /"'), ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should not prompt for echo'd rm");
    });

    it("DOES gate rm inside eval (dangerous wrapper)", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      await handler(bashEvent('eval "rm -rf /tmp"'), ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for eval'd rm");
    });

    it("hard-denies terraform destroy", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      const result = await handler(bashEvent("terraform destroy"), ctx);
      assert.ok(result?.block, "Should hard-block terraform destroy");
    });

    it("blocks dangerous bash in non-interactive mode", async () => {
      const { handler } = setup();
      const ctx = createMockCtx({ hasUI: false });
      const result = await handler(bashEvent("git push origin main"), ctx);
      assert.ok(result?.block, "Should block without UI");
    });
  });

  // ── Cloudflare gating ──────────────────────────────────────────────────

  describe("cloudflare_execute", () => {
    it("gates POST requests", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      const event = {
        toolName: "mcp",
        input: {
          tool: "cloudflare_execute",
          args: JSON.stringify({ code: `await fetch(url, { method: "POST", body: data })` }),
        },
      };
      await handler(event, ctx);
      assert.ok(ctx._getLastSelect(), "Should prompt for CF POST");
    });

    it("allows GET requests", async () => {
      const { handler } = setup();
      const ctx = createMockCtx();
      const event = {
        toolName: "mcp",
        input: {
          tool: "cloudflare_execute",
          args: JSON.stringify({ code: `await fetch(url, { method: "GET" })` }),
        },
      };
      await handler(event, ctx);
      assert.equal(ctx._getLastSelect(), undefined, "Should not prompt for CF GET");
    });
  });

  // ── Builtin tools passthrough ──────────────────────────────────────────

  describe("builtin tools", () => {
    for (const tool of ["read", "write", "edit"]) {
      it(`allows ${tool} without prompting`, async () => {
        const { handler } = setup();
        const ctx = createMockCtx();
        await handler({ toolName: tool, input: { path: "/foo" } }, ctx);
        assert.equal(ctx._getLastSelect(), undefined);
      });
    }
  });

  // ── Yolo mode ──────────────────────────────────────────────────────────

  describe("yolo mode (auto-yes)", () => {
    it("skips all soft gates when yolo is on", async () => {
      const { handler, yoloCmd } = setup();

      // Toggle yolo on
      await yoloCmd.handler("", createMockCtx());

      // MCP mutation — should pass without prompt
      const ctx1 = createMockCtx();
      await handler(mcpEvent("slack_conversations_add_message", { text: "hi" }), ctx1);
      assert.equal(ctx1._getLastSelect(), undefined, "Yolo should skip MCP gate");

      // Bash mutation — should pass without prompt
      const ctx2 = createMockCtx();
      await handler(bashEvent("git push"), ctx2);
      assert.equal(ctx2._getLastSelect(), undefined, "Yolo should skip bash gate");
    });

    it("still hard-denies terraform destroy in yolo mode", async () => {
      const { handler, yoloCmd } = setup();
      await yoloCmd.handler("", createMockCtx());

      const ctx = createMockCtx();
      const result = await handler(bashEvent("terraform destroy"), ctx);
      assert.ok(result?.block, "terraform destroy should be blocked even in yolo");
    });
  });

  // ── Regression: the original bug ───────────────────────────────────────

  describe("REGRESSION: MCP gateway mutations must be gated", () => {
    const mutationTools = [
      "slack_conversations_add_message",
      "atlassian_jira_create_issue",
      "atlassian_jira_transition_issue",
      "atlassian_confluence_update_page",
      "atlassian_confluence_delete_page",
      "argocd_app_patch",
      "grafana_create_dashboard",
      "miro_create_sticky_note",
      "miro_delete_item",
      "terraform_apply_run",
    ];

    for (const tool of mutationTools) {
      it(`gates ${tool} through MCP gateway`, async () => {
        const { handler } = setup();
        const ctx = createMockCtx();
        await handler(mcpEvent(tool, {}), ctx);
        assert.ok(
          ctx._getLastSelect(),
          `REGRESSION: ${tool} via MCP gateway was NOT gated. ` +
            `The 'mcp' builtin bypass must not skip inner tool mutation checks.`,
        );
      });
    }

    const readOnlyTools = [
      "slack_conversations_history",
      "slack_conversations_search_messages",
      "atlassian_jira_get_issue",
      "atlassian_confluence_get_page",
      "terraform_list_runs",
      "terraform_get_run_details",
      "grafana_get_dashboard",
    ];

    for (const tool of readOnlyTools) {
      it(`allows ${tool} through MCP gateway without prompting`, async () => {
        const { handler } = setup();
        const ctx = createMockCtx();
        await handler(mcpEvent(tool, {}), ctx);
        assert.equal(ctx._getLastSelect(), undefined, `False positive: ${tool} should NOT be gated`);
      });
    }
  });
});
