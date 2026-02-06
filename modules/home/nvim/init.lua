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
vim.o.equalalways = false -- don't auto-resize windows when opening/closing splits
vim.o.cmdheight = 0 -- hide command line when not in use
vim.o.laststatus = 3 -- single global statusline across all splits

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
vim.api.nvim_create_autocmd('FocusGained', {
	group = vim.g.user.event,
	callback = function()
		-- single tmux invocation: print @nav_dir then unset it (halves subprocess overhead)
		local dir = vim.fn
			.system({ 'tmux', 'display-message', '-p', '#{@nav_dir}', ';', 'set-option', '-qu', '@nav_dir' })
			:gsub('%s+', '')
		if dir == '' then
			return
		end
		-- opposite direction: e.g. pressed h (went left) → entered from right → go to rightmost split
		local opposite = { h = 'l', l = 'h', j = 'k', k = 'j' }
		if opposite[dir] then
			vim.cmd('99wincmd ' .. opposite[dir])
		end
	end,
})

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

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Close buffer and preserve window layout
local function close_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	-- Don't close special buffers (NvimTree, etc.)
	if ft == 'NvimTree' or vim.bo[buf].buftype ~= '' then
		return
	end
	MiniBufremove.delete(buf, true)
end
vim.keymap.set('n', '<leader>bc', close_buffer, { desc = 'Close buffer' })
vim.keymap.set('n', '<M-w>', close_buffer, { desc = 'Close buffer (Cmd+W)' })
vim.keymap.set('n', '<C-w>', close_buffer, { desc = 'Close buffer (Ctrl+W)', nowait = true })

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
