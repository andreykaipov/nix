# Neovim Configuration

A modular Neovim setup managed via Nix and built on [mini.nvim](https://github.com/nvim-mini/mini.nvim) as both the plugin manager and core plugin suite. Uses neovim-nightly.

## Structure

```
nvim/
├── default.nix              # Nix module: installs neovim-nightly, symlinks config, runs plugin bootstrap
├── init.lua                 # Entry point: user settings, module loader, hot-reload keymaps
├── stylua.toml              # StyLua formatter config (tabs, 120 cols, single quotes)
└── lua/custom/
    ├── minideps.lua          # Bootstraps mini.nvim + mini.deps plugin manager
    ├── basics.lua            # Core editor settings (undo, backup, numbers, clipboard, cursor restore)
    ├── navigation.lua        # Window/split navigation with tmux pane fallthrough
    ├── autosave.lua          # Auto-save on focus loss / insert leave + external change polling
    ├── colors.lua            # Colorscheme loading, tmux/wezterm color sync, inactive split dimming
    ├── editing.lua           # Comments, surround, pairs, alignment, icons, which-key
    ├── guides.lua            # Indent guides, indent scope, scrollbar with sign indicators
    ├── git.lua               # mini.git + mini.diff with gutter signs and diff overlay
    ├── pi.lua                # Pi coding agent integration via sidekick.nvim
    ├── buffers.lua           # Buffer close/reopen, layout-aware :q/:bd, empty buffer cleanup
    ├── nvim-tree.lua         # File explorer sidebar + bufferline tabs
    ├── picker.lua            # Fuzzy finder (mini.pick)
    ├── statusline.lua        # Statusline (mini.statusline)
    ├── treesitter.lua        # Treesitter syntax highlighting and parser management
    ├── lsp.lua               # LSP servers, completion, formatting, diagnostics
    └── scrollview-minidiff.lua  # Custom scrollbar signs for mini.diff git hunks
```

## Nix Integration

[default.nix](default.nix) installs neovim-nightly from a flake input and symlinks this entire directory as `~/.config/nvim`. It also:

- Installs `nodejs` (for copilot.lua) and `tree-sitter` as runtime dependencies
- Sets neovim as the default editor with `vi`/`vim` aliases
- Runs a headless `nvim --headless +qa` on home activation to bootstrap plugins
- Writes a color seed (`~/.local/share/nvim/color-seed`) at activation time so `randomhue` generates the same palette across all sessions until the next switch

## User Config

All user-facing settings live at the top of [init.lua](init.lua):

| Setting           | Default       | Description                               |
| ----------------- | ------------- | ----------------------------------------- |
| `leader`          | `Space`       | Leader key                                |
| `scrolloff`       | `20`          | Lines to keep visible above/below cursor  |
| `sidebar_width`   | `30`          | Default NvimTree sidebar width            |
| `color.colorscheme` | `randomhue` | Active colorscheme `{ name, lighter_shade [, black_bg] }` |
| `color.tmux.pane` | `subtle`      | Tmux pane border style (`subtle` or `chunky`) |
| `color.tmux.border` | `all`       | Tmux border visibility (`all` or `none`) |
| `color.tmux.bg`   | `inactive`    | Terminal bg source (`active` = Normal bg, `inactive` = dimmed) |

## Plugins

Plugins are managed by **mini.deps** (part of mini.nvim). On first launch, mini.nvim is cloned automatically.

### From mini.nvim

`mini.basics` · `mini.bufremove` · `mini.comment` · `mini.align` · `mini.icons` · `mini.pairs` · `mini.surround` · `mini.notify` · `mini.pick` · `mini.statusline` · `mini.indentscope` · `mini.git` · `mini.diff` · `mini.completion`

### External

| Plugin | Purpose |
| --- | --- |
| `folke/tokyonight.nvim` | Colorscheme |
| `oxfist/night-owl.nvim` | Colorscheme |
| `EdenEast/nightfox.nvim` | Colorscheme (carbonfox) |
| `olimorris/onedarkpro.nvim` | Colorscheme |
| `projekt0n/github-nvim-theme` | Colorscheme |
| `bluz71/vim-moonfly-colors` | Colorscheme |
| `andreykaipov/tmux-colorscheme-sync.nvim` | Syncs Neovim colors → tmux + wezterm |
| `nvim-tree/nvim-tree.lua` | File explorer sidebar |
| `akinsho/bufferline.nvim` | Buffer tab bar |
| `folke/which-key.nvim` | Keymap hints popup |
| `tpope/vim-sleuth` | Auto-detect indent settings |
| `lukas-reineke/indent-blankline.nvim` | Static indent guides |
| `dstein64/nvim-scrollview` | Scrollbar with sign indicators |
| `neovim/nvim-lspconfig` | LSP server configuration |
| `nvimtools/none-ls.nvim` | Formatters/linters as LSP sources |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting and code parsing |
| `VonHeikemen/ts-enable.nvim` | Treesitter auto-install helper |

## LSP Servers

Configured in [lsp.lua](lua/custom/lsp.lua): `lua_ls` · `gopls` · `golangci_lint_ls` · `terraformls` · `nixd` (with `nixfmt`) · `bashls` · `yamlls` · `jsonls`

Formatting sources via none-ls: `stylua` · `terraform_fmt` · `terraform_validate`

## Key Bindings

### General

| Key | Mode | Action |
| --- | --- | --- |
| `Space` | n | Leader |
| `<leader>cc` | n | Reload colorscheme (re-rolls if randomhue) |
| `<leader>cr` | n | Reload entire Lua config |
| `<leader>e` | n | Toggle file explorer sidebar |

### Navigation

| Key | Mode | Action |
| --- | --- | --- |
| `Alt+h/j/k/l` | n | Move between splits (falls through to tmux at edges) |
| `Ctrl+d / Ctrl+u` | n | Scroll half-page down/up (centered) |
| `n / N` | n | Next/prev search result (centered) |
| `H / L` | n | Previous/next buffer tab |
| `J / K` | v | Move selection down/up |

### Buffers

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>bc` | n | Close buffer (preserves layout) |
| `F1` | n | Close buffer (mapped from WezTerm Cmd+W) |
| `F2` | n | Reopen last closed buffer (Cmd+Shift+T) |
| `:q` / `:bd` | cmd | Layout-aware close (aliased to custom commands) |

### Fuzzy Finder

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>?` | n | Recent files |
| `<leader><space>` | n | Open buffers |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fd` | n | Diagnostics |
| `<leader>fs` | n | Buffer-local search |

### Editing

| Key | Mode | Action |
| --- | --- | --- |
| `gc` | n/v | Toggle comment (motion/textobject) |
| `C` | n/v | Toggle comment (current line / selection) |
| `ga` | n/v | Align with preview |
| `sa` / `sd` / `sr` | n | Surround add / delete / replace |

### Git

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>do` | n | Toggle diff overlay |

### LSP

| Key | Mode | Action |
| --- | --- | --- |
| `K` | n | Hover documentation |
| `gd` | n | Go to definition |
| `grd` | n | Go to declaration |
| `gq` | n/v | Format |
| `N` | n/v | Open diagnostic float |

### NvimTree

| Key | Mode | Action |
| --- | --- | --- |
| Left click | n | Open file/folder |
| `o` | n | Add file to buffer (keep tree focus) |
| `Tab` | n | Open file in editor pane (keep tree focus) |
| `O` | n | Open all marked files |

### OpenCode AI

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>oa` | n/x | Ask OpenCode |
| `<leader>os` | n/x | Select for OpenCode |
| `<leader>oo` | n/t | Toggle OpenCode pane |
| `go` | n/x | Send to OpenCode (operator) |
| `goo` | n | Send current line to OpenCode |

## Notable Behaviors

- **Auto-save**: Files save on focus loss, insert leave, buffer leave, and every 2 seconds
- **Cursor restore**: Reopening a file jumps to the last known cursor position
- **Tmux-aware navigation**: `Alt+hjkl` moves between Neovim splits first, then falls through to adjacent tmux panes
- **Tmux entry direction**: When entering Neovim from a tmux pane, focus jumps to the edge split closest to where you came from
- **Color sync**: Colorscheme changes propagate to tmux status bar and wezterm terminal background via OSC 11
- **Per-switch colorscheme**: `randomhue` is seeded from a file written at `nix run .#switch` time, so every session gets the same hue until the next switch. Run `colorscheme` from the shell or `<leader>cc` in nvim to re-roll on demand.
- **Inactive split dimming**: Unfocused splits use a lighter background matching tmux inactive pane style
- **Focus awareness**: Bufferline tabs and NvimTree dim appropriately when Neovim loses focus
- **Sidebar width persistence**: NvimTree width is cached to disk and restored across sessions
- **Layout-aware quit**: `:q` and `:bd` are overridden to use `MiniBufremove` when NvimTree is open, preventing layout collapse
- **Scrollbar git signs**: A custom scrollview integration shows mini.diff git hunks on the scrollbar
- **Black background**: Optionally force `#000000` background via the colorscheme config's third element
