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

-- vim.o.cursorline = true
-- vim.o.cursorlineopt = 'line,number' --

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

MiniDeps.add('folke/tokyonight.nvim')
MiniDeps.add('oxfist/night-owl.nvim')
MiniDeps.add('EdenEast/nightfox.nvim')
MiniDeps.add('olimorris/onedarkpro.nvim')
MiniDeps.add('andreykaipov/tmux-colorscheme-sync.nvim')

MiniDeps.add('neovim/nvim-lspconfig')
MiniDeps.add({
	source = 'nvimtools/none-ls.nvim',
	depends = { 'nvim-lua/plenary.nvim' },
})

MiniDeps.add('lukas-reineke/indent-blankline.nvim')

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
MiniDeps.add({
	source = 'zbirenbaum/copilot.lua',
	depends = { 'copilotlsp-nvim/copilot-lsp' },
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

-- require('night-owl').setup()
-- vim.cmd.colorscheme('night-owl')
-- require('nightfox').setup({})
vim.cmd.colorscheme('onedark_dark')
require('tmux-colorscheme-sync').setup()

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

-- for more symbols, see :h ibl.config.indent.char
-- ╎┆┊│
require('mini.indentscope').setup({ symbol = '│' })
require('ibl').setup({ indent = { char = '┊', tab_char = '╎' } })

-- See :help MiniIcons.config
-- Change style to 'glyph' if you have a font with fancy icons
require('mini.icons').setup({
	style = 'ascii',
})

-- See :help MiniSurround.config
require('mini.surround').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
	lsp_progress = { enable = false },
})

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Close buffer and preserve window layout
vim.keymap.set('n', '<leader>bc', '<cmd>lua pcall(MiniBufremove.delete)<cr>', { desc = 'Close buffer' })

-- See :help MiniFiles.config
local mini_files = require('mini.files')
mini_files.setup({})

-- Toggle file explorer
-- See :help MiniFiles-navigation
vim.keymap.set('n', '<leader>e', function()
	if mini_files.close() then
		return
	end

	mini_files.open()
end, { desc = 'File explorer' })

-- See :help MiniPick.config
require('mini.pick').setup({})

-- See available pickers
-- :help MiniPick.builtin
-- :help MiniExtra.pickers
vim.keymap.set('n', '<leader>?', '<cmd>Pick oldfiles<cr>', { desc = 'Search file history' })
vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', { desc = 'Search open files' })
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Search all files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Search in project' })
vim.keymap.set('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>fs', '<cmd>Pick buf_lines<cr>', { desc = 'Buffer local search' })

-- See :help MiniStatusline.config
require('mini.statusline').setup({})

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

-- LSP setup
-- https://neovim.io/doc/user/lsp.html#lsp-attach
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	group = vim.g.user.event,
	callback = function(event)
		local opts = { buffer = event.buf }
		vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
		vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
		vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
		vim.keymap.set({ 'n', 'v', 'x' }, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
		vim.keymap.set({ 'n', 'v' }, 'N', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)

		local id = vim.tbl_get(event, 'data', 'client_id')
		local client = id and vim.lsp.get_client_by_id(id)

		if client and client:supports_method('textDocument/completion') then
			vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
		end

		vim.o.updatetime = 500
		vim.api.nvim_create_autocmd('CursorHold', {
			group = vim.g.user.event,
			buffer = event.buf,
			callback = function()
				vim.diagnostic.open_float({
					scope = 'line',
					focus = false,
				})
			end,
		})

		if
		    not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting')
		then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.g.user.event,
				buffer = event.buf,
				callback = function()
					vim.lsp.buf.format({
						-- async = false,
						bufnr = event.buf,
						id = event.data.id, -- id = client.id
						timeout_ms = 1000,
					})
				end,
			})
		end
		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	buffer = event.buf,
		-- 	callback = function()
		-- 		vim.lsp.buf.format({ async = false, id = event.data.client_id })
		-- 	end,
		-- })
	end,
})

MiniDeps.later(function()
	require('copilot').setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			trigger_on_accept = true,
			keymap = {
				accept = '<Tab>',
			},
			-- hide_during_completion = false,
		},
		nes = {
			enabled = true,
			auto_trigger = true,
			keymap = {
				accept_and_goto = '<C-i>',
				dismiss = '<Esc>',
			},
		},
	})
end)

-- See :help MiniCompletion.config
require('mini.completion').setup({
	lsp_completion = {
		source_func = 'completefunc',
		auto_setup = false,
	},
})
vim.keymap.set('i', '<C-j>', function()
	return vim.fn.pumvisible() == 1 and '<C-n>' or require('copilot.suggestion').next()
end, { expr = true, noremap = true })
vim.keymap.set('i', '<C-k>', function()
	return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-k>'
end, { expr = true, noremap = true })
vim.keymap.set('i', '<CR>', function()
	return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true, noremap = true })

local nls = require('null-ls')
nls.setup({
	sources = {
		nls.builtins.formatting.stylua,
		nls.builtins.formatting.terraform_fmt.with({
			filetypes = { 'terraform', 'tf', 'terraform-vars', 'hcl' },
		}),
		nls.builtins.diagnostics.terraform_validate.with({
			filetypes = { 'terraform', 'tf', 'terraform-vars', 'hcl' },
		}),
	},
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('golangci_lint_ls')
vim.lsp.enable('terraformls')
-- vim.lsp.enable('terraform_lsp') --
vim.lsp.config('nixd', {
	settings = {
		formatting = {
			command = 'nixfmt',
		},
	},
})
vim.lsp.enable('nixd')
vim.lsp.enable('bashls')
vim.lsp.enable('yamlls')
vim.lsp.enable('jsonls')
