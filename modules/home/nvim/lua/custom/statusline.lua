-- Statusline + tmux pane title sync
local M = {}

function M.setup()
	require('mini.statusline').setup({})

	-- Hide NvimTree buffer name and diff stats from the statusline
	local orig_section_filename = MiniStatusline.section_filename
	MiniStatusline.section_filename = function(args)
		if vim.bo.filetype == 'NvimTree' then
			return ''
		end
		return orig_section_filename(args)
	end
	MiniStatusline.section_diff = function()
		return ''
	end
end

return M
