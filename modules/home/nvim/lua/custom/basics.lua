-- expanded from https://github.com/VonHeikemen/nvim-light/blob/main/configs/nightly.lua
--
-- Core editor settings
local M = {}

function M.setup()
	vim.g.user = {
		leader = ' ',
		event = 'UserGroup',
		guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor',
	}

	vim.api.nvim_create_augroup(vim.g.user.event, {})

	-- Leader key (must be set before mini.basics so it doesn't override)
	vim.g.mapleader = vim.g.user.leader

	-- Sensible defaults (undo, mouse, etc.)
	-- Must come before our overrides so we can customize on top.
	require('mini.basics').setup()

	-- Persistent undo and backup directories
	local undodir = vim.fn.stdpath('state') .. '/undo'
	local backupdir = vim.fn.stdpath('state') .. '/backup'
	vim.fn.mkdir(undodir, 'p')
	vim.fn.mkdir(backupdir, 'p')
	vim.o.undofile = true
	vim.o.undodir = undodir
	vim.o.backup = true
	vim.o.backupdir = backupdir
	vim.o.writebackup = true

	vim.o.number = true
	vim.o.relativenumber = true
	vim.o.scrolloff = vim.g.user.scrolloff or 20
	vim.o.winborder = 'rounded'
	vim.o.signcolumn = 'auto:2-5' -- so new gutter signs don't move the text
	vim.o.equalalways = false     -- don't auto-resize windows when opening/closing splits
	vim.o.cmdheight = 0           -- hide command line when not in use
	vim.o.laststatus = 3          -- single global statusline across all splits

	vim.o.cursorline = true
	vim.o.cursorlineopt = 'both' -- highlight entire line including line number
	vim.o.guicursor = vim.g.user.guicursor

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

	-- Cmd+S to save (WezTerm sends F3, see wezterm.lua)
	vim.keymap.set({ 'n', 'i', 'v' }, '<F3>', '<Cmd>wall<CR>', { desc = 'Save all files' })

	-- Disable netrw in favor of nvim-tree sidebar
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1

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
end

return M
