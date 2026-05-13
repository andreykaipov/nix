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

### Key files

| File | Managed by | Editable? |
|------|-----------|-----------|
| `settings.json` | nix (generated) | No — edit nix config |
| `mcp.json` | nix (generated) | No — edit nix config |
| `keybindings.json` | repo (symlinked) | Yes |
| `extensions/` | repo (symlinked) | Yes |
| `skills/` | repo (symlinked) | Yes |
| `themes/` | repo (symlinked) | Yes |
| `AGENTS.md` | repo (symlinked) | Yes — loaded into every session |
