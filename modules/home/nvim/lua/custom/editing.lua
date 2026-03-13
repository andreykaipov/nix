-- Text editing plugins: comments, pairs, surround, alignment, sleuth
local M = {}

function M.setup()
	MiniDeps.add('tpope/vim-sleuth')

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

	-- See :help MiniIcons.config
	require('mini.icons').setup({
		style = 'glyph',
	})
	MiniIcons.mock_nvim_web_devicons()

	-- See :help MiniPairs.config
	require('mini.pairs').setup({})

	-- See :help MiniSurround.config
	require('mini.surround').setup({})

	-- See :help which-key.nvim-which-key-setup
	MiniDeps.add('folke/which-key.nvim')
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
end

return M
