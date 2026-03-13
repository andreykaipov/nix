-- Git integration: mini.git, mini.diff
local M = {}

function M.setup()
	-- See :help MiniGit.config
	require('mini.git').setup({})

	-- See :help MiniDiff.config
	require('mini.diff').setup({
		view = {
			style = 'sign',
			signs = { add = '+', change = '~', delete = '-' },
		},
	})

	vim.keymap.set('n', ',<CR>', function()
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
end

return M
