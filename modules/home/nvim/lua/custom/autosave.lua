-- Auto-save and reload files changed externally

local M = {}

function M.setup()
	vim.o.autoread = true

	-- Auto-save when leaving nvim, insert mode, or buffer
	vim.api.nvim_create_autocmd({ 'FocusLost', 'InsertLeave', 'BufLeave' }, {
		group = vim.g.user.event,
		command = 'silent! noautocmd wall',
	})

	-- Auto-save and poll for external changes every 2s
	local timer = vim.uv.new_timer()
	timer:start(
		0,
		2000,
		vim.schedule_wrap(function()
			if vim.fn.getcmdwintype() == '' then
				vim.cmd('silent! noautocmd wall')
				vim.cmd('silent! checktime')
			end
		end)
	)
end

return M
