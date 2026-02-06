-- Indent guides, indentscope, scrollbar
local M = {}

function M.setup()
	MiniDeps.add('lukas-reineke/indent-blankline.nvim')
	MiniDeps.add('dstein64/nvim-scrollview')

	-- Animated scope line (current indent block)
	require('mini.indentscope').setup({
		symbol = '│',
		draw = { animation = require('mini.indentscope').gen_animation.none() },
	})
	local incsearch_hl = vim.api.nvim_get_hl(0, { name = 'IncSearch' })
	local incsearch_color = incsearch_hl.bg and string.format('#%06x', incsearch_hl.bg)
		or incsearch_hl.fg and string.format('#%06x', incsearch_hl.fg)
		or '#ff9e64'
	vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = incsearch_color })

	-- Static indent guides
	-- for more symbols, see :h ibl.config.indent.char ╎┆┊│
	require('ibl').setup({ indent = { char = '┊', tab_char = '╎' } })

	-- Scrollbar with sign indicators
	-- Built-in sign groups: changelist, conflicts, cursor, diagnostics, folds,
	-- indent, keywords, latestchange, loclist, marks, quickfix, search, spell,
	-- textwidth, trail
	require('scrollview').setup({
		excluded_filetypes = { 'NvimTree' },
		signs_on_startup = { 'diagnostics', 'search', 'marks', 'changelist' },
		byte_limit = 1000000,
	})
	-- vim.api.nvim_set_hl(0, 'ScrollView', { link = 'IncSearch' })

	-- Git diff signs on the scrollbar via mini.diff
	require('custom.scrollview-minidiff').setup()
end

return M
