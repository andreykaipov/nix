-- Text editing plugins: comments, pairs, surround, alignment, sleuth
local M = {}

--- Strip trailing blank lines from a buffer without clearing existing highlights.
local function trim_trailing_blanks(buf)
	local count = vim.api.nvim_buf_line_count(buf)
	local last = count
	while last > 0 do
		local line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
		if line:match('%S') then break end
		last = last - 1
	end
	if last < count then
		vim.api.nvim_buf_set_lines(buf, last, count, false, {})
	end
end

function M.setup()
	MiniDeps.add('tpope/vim-sleuth')

	-- ANSI color rendering for tmux pane captures (see tmux-vim-copy-pane script)
	MiniDeps.add('m00qek/baleia.nvim')
	local baleia = require('baleia').setup({ async = false })
	vim.api.nvim_create_autocmd('BufReadPost', {
		pattern = '/tmp/tmux-pane-*',
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			-- Read lines, then replace via baleia which strips codes and highlights
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			baleia.buf_set_lines(buf, 0, -1, false, lines)
			trim_trailing_blanks(buf)
			vim.bo[buf].modified = false
			vim.cmd('normal! Gzz')
		end,
	})

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
