-- Fuzzy finder: mini.pick
local M = {}

function M.setup()
	-- See :help MiniExtra
	-- require('mini.extra').setup({})

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
end

return M
