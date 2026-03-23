-- Tidal Cycles integration via vim-tidal (lazy, .tidal files only)
local M = {}

function M.setup()
	local deps = require('mini.deps')

	-- Download but don't load yet
	deps.add({
		source = 'tidalcycles/vim-tidal',
		depends = {},
	})

	-- Use terminal REPL inside nvim
	vim.g.tidal_target = 'terminal'

	-- Register .tidal filetype (since ftdetect won't run until packadd)
	vim.filetype.add({
		extension = { tidal = 'tidal' },
	})

	-- Load the plugin on first .tidal file
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'tidal',
		once = true,
		callback = function()
			vim.cmd('packadd vim-tidal')
			-- Re-trigger ftplugin/syntax for the current buffer
			vim.cmd('edit')
		end,
	})
end

return M
