# Pi Configuration

## Customization

Pi has four customization mechanisms:

| Type | Location | Purpose | Loaded |
|------|----------|---------|--------|
| **Extensions** | `extensions/` | TypeScript code — adds tools, commands, event handlers, UI | At startup |
| **Skills** | `skills/` | Detailed instruction sets injected into the system prompt | On demand or auto |
| **Prompt Templates** | `prompts/` | Short message shortcuts, expanded with `/name` | On invocation |
| **Themes** | `themes/` | Color schemes for the TUI | Hot-reloaded |

### When to use what

- **Prompt template** when you want a shortcut for a message: `/debug why is X broken`
- **Skill** when the model needs domain knowledge to do something: API schemas, query syntax, voice guidelines
- **Extension** when you need code: custom tools, event hooks, UI components, model routing

### Subagents

The `pi-subagents` package (`npm:pi-subagents`) provides the subagent tool,
which spawns isolated pi processes with their own model, tools, and system prompt.

- **Agents** (`agents/*.md`) define the roster — name, model, thinking level, tools, system prompt
- **Prompt templates** (`prompts/*.md`) chain agents into workflows

#### Agent Roster

| Agent | Model | Thinking | Tools | Purpose |
|-------|-------|----------|-------|---------|
| **scout** | Haiku 4.5 | off | read, grep, find, ls, bash, write | Fast codebase recon, returns compressed context |
| **planner** | Opus 4.6 | high | read, grep, find, ls, write | Creates implementation plans (read-only) |
| **worker** | Sonnet 4.6 | medium | all | Implements changes |
| **reviewer** | Opus 4.6 | high | read, grep, find, ls, bash | Code review and quality analysis |
| **debugger** | Opus 4.6 | high | read, grep, find, ls, bash | Deep debugging and root cause analysis (read-only) |
| **context-builder** | Sonnet 4.6 | medium | read, grep, find, ls, bash, web_search | Analyzes requirements and codebase |
| **researcher** | Sonnet 4.6 | medium | read, write, web_search, fetch_content | Web research and synthesis |

#### Usage

pi-subagents provides `/run`, `/chain`, `/parallel` commands with tab completion:

```
/run scout find all the nix overlay code
/chain scout "find auth code" -> planner -> worker
/parallel scout "scan shell config" -> scout "scan nvim config"
/run debugger why is the nix build failing
```

Or invoke via `/agents` to open the agent management overlay.

### Key files

| File | Managed by | Editable? |
|------|-----------|-----------|
| `settings.json` | nix (generated) | No — edit nix config |
| `mcp.json` | nix (generated) | No — edit nix config |
| `keybindings.json` | repo (symlinked) | Yes |
| `extensions/` | repo (symlinked) | Yes |
| `skills/` | repo (symlinked) | Yes |
| `agents/` | repo (symlinked) | Yes |
| `prompts/` | repo (symlinked) | Yes |
| `themes/` | repo (symlinked) | Yes |
| `AGENTS.md` | repo (symlinked) | Yes — loaded into every session |
