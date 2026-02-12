-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

-- Learn more about Neovim lua api
-- https://neovim.io/doc/user/lua-guide.html
-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/

vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 20
vim.o.winborder = 'rounded'
vim.o.signcolumn = 'auto:2-5' -- so new gutter signs don't move the text
vim.o.equalalways = false     -- don't auto-resize windows when opening/closing splits
vim.o.cmdheight = 0           -- hide command line when not in use
vim.o.laststatus = 3          -- single global statusline across all splits

-- Alt+hjkl to navigate between splits, falling through to tmux at edges
local function nav(dir, tmux_dir)
	return function()
		local win = vim.api.nvim_get_current_win()
		vim.cmd('wincmd ' .. dir)
		if vim.api.nvim_get_current_win() == win then
			vim.fn.system('tmux select-pane -' .. tmux_dir)
		end
	end
end
vim.keymap.set('n', '<M-h>', nav('h', 'L'), { desc = 'Move left' })
vim.keymap.set('n', '<M-j>', nav('j', 'D'), { desc = 'Move down' })
vim.keymap.set('n', '<M-k>', nav('k', 'U'), { desc = 'Move up' })
vim.keymap.set('n', '<M-l>', nav('l', 'R'), { desc = 'Move right' })
vim.keymap.set('n', '<M-Left>', '<M-h>', { remap = true, desc = 'Move left' })
vim.keymap.set('n', '<M-Down>', '<M-j>', { remap = true, desc = 'Move down' })
vim.keymap.set('n', '<M-Up>', '<M-k>', { remap = true, desc = 'Move up' })
vim.keymap.set('n', '<M-Right>', '<M-l>', { remap = true, desc = 'Move right' })

-- Center jumps
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up (centered)' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })

-- Buffer switching (Shift+H/L)
vim.keymap.set('n', 'H', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', 'L', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })

-- Move selection (J/K)
vim.keymap.set('v', 'J', ":m '>+1<cr>'[V']=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<cr>'[V']=gv", { desc = 'Move selection up' })

vim.o.cursorline = true
vim.o.cursorlineopt = 'both' -- highlight entire line including line number

-- vim.o.ignorecase = true
-- vim.o.smartcase = true
-- vim.o.hlsearch = false
-- vim.o.tabstop = 2
-- vim.o.shiftwidth = 2
-- vim.o.showmode = false
-- vim.o.termguicolors = true
-- vim.o.timeoutlen = 300

-- Space as leader key
-- vim.g.mapleader = vim.keycode('<Space>')

-- Basic clipboard interaction
-- vim.keymap.set({'n', 'x'}, 'gy', '"+y', {desc = 'Copy to clipboard'})
-- vim.keymap.set({'n', 'x'}, 'gp', '"+p', {desc = 'Paste clipboard content'})

vim.g.is_posix = 1
vim.opt.clipboard = 'unnamedplus' -- share system clipboard

-- Disable netrw in favor of nvim-tree sidebar
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- User Config
-- ---
vim.g.user = {
	leaderkey = ' ',
	transparent = false,
	event = 'UserGroup',
	config = {
		undodir = vim.fn.stdpath('cache') .. '/undo',
	},
}

-- Global user group to register other custom autocmds
vim.api.nvim_create_augroup(vim.g.user.event, {})

-- When entering Neovim from a tmux pane, jump to the edge split closest
-- to where we came from (so vim splits behave like tmux panes).
-- tmux sets @nav_dir before select-pane; we read+clear it in one call.
-- This must be synchronous so the wincmd runs before colors.lua's
-- FocusGained resync — otherwise the resync highlights the stale
-- active window and a redraw between the two causes a flicker.
vim.api.nvim_create_autocmd('FocusGained', {
	group = vim.g.user.event,
	callback = function()
		local raw = vim.fn.system('tmux display-message -p "#{@nav_dir}" \\; set-option -qu @nav_dir')
		local dir = raw:gsub('%s+', '')
		if dir == '' then
			return
		end
		local opposite = { h = 'l', l = 'h', j = 'k', k = 'j' }
		if opposite[dir] then
			vim.cmd('noautocmd 99wincmd ' .. opposite[dir])
			-- noautocmd suppressed WinEnter/WinLeave, so the
			-- DimInactiveSplits winhighlight state is stale.
			-- Resync all windows: dim inactive, clear active.
			vim.api.nvim_exec_autocmds('User', { pattern = 'DimInactiveSplitsResync' })
		end
	end,
})

require('custom.autosave').setup()

-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler
-- (happens when dropping a file on gvim) and for a commit message (it's
-- likely a different one than last time).
vim.api.nvim_create_autocmd('BufReadPost', {
	group = vim.g.user.event,
	callback = function(args)
		local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
		local not_commit = vim.b[args.buf].filetype ~= 'commit'

		if valid_line and not_commit then
			vim.cmd([[normal! g`"]])
		end
	end,
})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

local mini = {}

mini.branch = 'main'
mini.packpath = vim.fn.stdpath('data') .. '/site'

function mini.require_deps()
	local mini_path = mini.packpath .. '/pack/deps/start/mini.nvim'

	if not vim.uv.fs_stat(mini_path) then
		print('Installing mini.nvim....')
		vim.fn.system({
			'git',
			'clone',
			'--filter=blob:none',
			'https://github.com/nvim-mini/mini.nvim',
			string.format('--branch=%s', mini.branch),
			mini_path,
		})

		vim.cmd('packadd mini.nvim | helptags ALL')
	end

	local ok, deps = pcall(require, 'mini.deps')
	if not ok then
		return {}
	end

	return deps
end

local MiniDeps = mini.require_deps()
if not MiniDeps.setup then
	return
end

-- See :help MiniDeps.config
MiniDeps.setup({
	path = {
		package = mini.packpath,
	},
})

MiniDeps.add('folke/which-key.nvim')
MiniDeps.add('VonHeikemen/ts-enable.nvim')

MiniDeps.add('tpope/vim-sleuth')
MiniDeps.add('nickjvandyke/opencode.nvim')
MiniDeps.add({
	source = 'nvim-mini/mini.nvim',
	checkout = mini.branch,
})
MiniDeps.add({
	source = 'nvim-treesitter/nvim-treesitter',
	checkout = 'main',
	hooks = {
		post_checkout = function()
			vim.cmd.TSUpdate()
		end,
	},
	auto_install = true,
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

require('custom.colors').setup()

require('mini.basics').setup()

require('mini.comment').setup({
	mappings = {
		-- works also in visual mode if mapping differs from `comment_visual`
		textobject = 'gc', -- like dgc ygc or even gcgc (the second gc)
		comment = 'gc', -- toggle comment like gcip or gc5j gcva( or gcgc also (the first gc)
		comment_line = 'C', -- toggle comment on current line
		comment_visual = 'C', -- toggle comment on visual selection
	},
})
require('mini.align').setup({
	-- swap the default mappings around, preview seems more responsive
	mappings = {
		start_with_preview = 'ga',
		start = 'gA',
	},
})

require('custom.guides').setup()

-- See :help MiniIcons.config
require('mini.icons').setup({
	style = 'glyph',
})
MiniIcons.mock_nvim_web_devicons()

-- See :help MiniPairs.config
require('mini.pairs').setup({})

-- See :help MiniSurround.config
require('mini.surround').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
	lsp_progress = { enable = false },
})

-- See :help MiniGit.config
require('mini.git').setup({})

-- See :help MiniDiff.config
require('mini.diff').setup({
	view = {
		style = 'sign',
		signs = { add = '+', change = '~', delete = '-' },
	},
})
vim.keymap.set('n', '<leader>do', function()
	vim.b.minidiff_overlay_manual = true
	MiniDiff.toggle_overlay()
end, { desc = 'Toggle diff overlay' })

-- Enable diff overlay by default on all buffers (unless manually toggled)
vim.api.nvim_create_autocmd('User', {
	group = vim.g.user.event,
	pattern = 'MiniDiffUpdated',
	callback = function(args)
		if vim.b[args.buf].minidiff_overlay_manual then
			return
		end
		local data = MiniDiff.get_buf_data(args.buf)
		if data and not data.overlay then
			MiniDiff.toggle_overlay(args.buf)
		end
	end,
	desc = 'Auto-enable diff overlay',
})

-- See :help opencode.nvim
---@type opencode.Opts
vim.g.opencode_opts = {
	server = {
		start = function()
			vim.fn.system('tmux split-window -h -l 40% "opencode --port"')
		end,
		stop = function()
			vim.fn.system('tmux kill-pane -t opencode 2>/dev/null')
		end,
		toggle = function()
			-- If there's already a pane running opencode, select it; otherwise create one
			local pane = vim.fn
			    .system(
			    'tmux list-panes -F "#{pane_id} #{pane_current_command}" | grep opencode | head -1 | cut -d" " -f1')
			    :gsub('%s+', '')
			if pane ~= '' then
				vim.fn.system('tmux select-pane -t ' .. pane)
			else
				vim.fn.system('tmux split-window -h -l 40% "opencode --port"')
			end
		end,
	},
}
vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
	require('opencode').ask(nil, { clear = true, submit = true })
end, { desc = 'Ask opencode' })
vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
	require('opencode').select()
end, { desc = 'Opencode select' })
vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
	require('opencode').toggle()
end, { desc = 'Toggle opencode' })
vim.keymap.set({ 'n', 'x' }, 'go', function()
	return require('opencode').operator('@this ')
end, { desc = 'Send to opencode', expr = true })
vim.keymap.set('n', 'goo', function()
	return require('opencode').operator('@this ') .. '_'
end, { desc = 'Send line to opencode', expr = true })

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Track recently closed buffers for Ctrl+Shift+T reopen
local closed_buffers = {}

-- Close buffer and preserve window layout
local function close_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	-- Don't close special buffers (NvimTree, etc.)
	if ft == 'NvimTree' or vim.bo[buf].buftype ~= '' then
		return
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if name ~= '' then
		table.insert(closed_buffers, name)
	end
	MiniBufremove.delete(buf, true)
end

local function reopen_buffer()
	while #closed_buffers > 0 do
		local name = table.remove(closed_buffers)
		if vim.uv.fs_stat(name) then
			vim.cmd.edit(vim.fn.fnameescape(name))
			return
		end
	end
end

vim.keymap.set('n', '<leader>bc', close_buffer, { desc = 'Close buffer' })
-- F1/F2 are sent by WezTerm for Cmd+W / Cmd+Shift+T (see wezterm.lua)
vim.keymap.set('n', '<F1>', close_buffer, { desc = 'Close buffer (Cmd+W)' })
vim.keymap.set('n', '<F2>', reopen_buffer, { desc = 'Reopen closed buffer (Cmd+Shift+T)' })

-- Override :q and :bd so they preserve window layout when NvimTree is open.
-- Without this, :q closes the window (NvimTree fills the screen) and :bd
-- uses the built-in bdelete which doesn't keep the split around.
local function should_close_buffer_instead()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].filetype == 'NvimTree' or vim.bo[buf].buftype ~= '' then
		return false
	end
	-- Check if NvimTree is open in a visible window
	local nvimtree_open = false
	local normal_wins = 0
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == '' then
			local wbuf = vim.api.nvim_win_get_buf(win)
			if vim.bo[wbuf].filetype == 'NvimTree' then
				nvimtree_open = true
			else
				normal_wins = normal_wins + 1
			end
		end
	end
	if normal_wins > 1 then
		return false -- multiple editor windows; :q should close this one
	end
	-- Single editor window with NvimTree: use MiniBufremove to keep layout
	return nvimtree_open
end

vim.api.nvim_create_user_command('Q', function(opts)
	if should_close_buffer_instead() then
		close_buffer()
	else
		vim.cmd('q' .. (opts.bang and '!' or ''))
	end
end, { bang = true })

vim.api.nvim_create_user_command('Bd', function()
	close_buffer()
end, { bang = true })

-- Rewrite :q/:bd at the command line so users don't need to learn new commands
vim.cmd([[cnoreabbrev <expr> q  getcmdtype() == ':' && getcmdline() ==# 'q'  ? 'Q'  : 'q']])
vim.cmd([[cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() ==# 'bd' ? 'Bd' : 'bd']])
vim.cmd([[cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() ==# 'bdelete' ? 'Bd' : 'bdelete']])

-- Clean up [No Name] buffers when a real file is opened
vim.api.nvim_create_autocmd('BufEnter', {
	group = vim.g.user.event,
	callback = function()
		local cur = vim.api.nvim_get_current_buf()
		if vim.api.nvim_buf_get_name(cur) == '' or not vim.bo[cur].buflisted then
			return
		end
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if b ~= cur
			    and vim.bo[b].buflisted
			    and vim.api.nvim_buf_get_name(b) == ''
			    and vim.bo[b].buftype == ''
			    and not vim.bo[b].modified then
				vim.api.nvim_buf_delete(b, {})
			end
		end
	end,
})

-- Sidebar file tree (VS Code style)
-- See :help nvim-tree
require('custom.nvim-tree').setup()

-- See :help MiniPick.config
require('mini.pick').setup({
	mappings = {
		move_down = '<C-j>',
		move_up = '<C-k>',
	},
})

-- See available pickers
-- :help MiniPick.builtin
-- :help MiniExtra.pickers
vim.keymap.set('n', '<leader>?', '<cmd>Pick oldfiles<cr>', { desc = 'Search file history' })
vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', { desc = 'Search open files' })
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Search all files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Search in project' })
vim.keymap.set('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>fs', '<cmd>Pick buf_lines<cr>', { desc = 'Buffer local search' })

require('custom.statusline').setup()

-- See :help MiniExtra
-- require('mini.extra').setup({})

-- See :help MiniSnippets.config
-- require('mini.snippets').setup({})

-- See :help which-key.nvim-which-key-setup
require('which-key').setup({
	icons = {
		mappings = false,
		keys = {
			Space = 'Space',
			Esc = 'Esc',
			BS = 'Backspace',
			C = 'Ctrl-',
		},
	},
})

require('which-key').add({
	{ '<leader>f', group = 'Fuzzy Find' },
	{ '<leader>b', group = 'Buffer' },
})

-- Reload colorscheme and custom highlights without restarting
vim.keymap.set('n', '<leader>cc', function()
	package.loaded['custom.colors'] = nil
	require('custom.colors').setup()
end, { desc = 'Reload colorscheme' })

-- Reload entire lua config without restarting
vim.keymap.set('n', '<leader>cr', function()
	for name, _ in pairs(package.loaded) do
		if name:match('^custom%.') then
			package.loaded[name] = nil
		end
	end
	dofile(vim.fn.stdpath('config') .. '/init.lua')
	vim.notify('Config reloaded', vim.log.levels.INFO)
end, { desc = 'Reload config' })

-- Treesitter setup
-- NOTE: the list of supported parsers is in the documentation:
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local ts_parsers = {
	'lua',
	'vim',
	'vimdoc',
	'tf',
	'hcl',
	'go',
	'sh',
	'bash',
	'nix',
	'json',
	'yaml',
	'toml',
}

-- See :help ts-enable-config
-- :checkhealth nvim-treesitter
vim.g.ts_enable = {
	parsers = ts_parsers,
	auto_install = true,
	highlights = true,
}

require('custom.lsp').setup()
