-- Window/split navigation, tmux integration, and motion keymaps
local M = {}

function M.setup()
	-- Alt+hjkl to navigate between splits, falling through to tmux at edges
	local function nav(dir, tmux_dir)
		return function()
			local win = vim.api.nvim_get_current_win()
			vim.cmd('wincmd ' .. dir)
			if vim.api.nvim_get_current_win() == win then
				vim.fn.system('tmux select-pane -' .. tmux_dir)
			end
		end
	end
	vim.keymap.set('n', '<M-h>', nav('h', 'L'), { desc = 'Move left' })
	vim.keymap.set('n', '<M-j>', nav('j', 'D'), { desc = 'Move down' })
	vim.keymap.set('n', '<M-k>', nav('k', 'U'), { desc = 'Move up' })
	vim.keymap.set('n', '<M-l>', nav('l', 'R'), { desc = 'Move right' })
	vim.keymap.set('n', '<M-Left>', '<M-h>', { remap = true, desc = 'Move left' })
	vim.keymap.set('n', '<M-Down>', '<M-j>', { remap = true, desc = 'Move down' })
	vim.keymap.set('n', '<M-Up>', '<M-k>', { remap = true, desc = 'Move up' })
	vim.keymap.set('n', '<M-Right>', '<M-l>', { remap = true, desc = 'Move right' })

	-- Center jumps
	vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down (centered)' })
	vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up (centered)' })
	vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
	vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })

	-- Buffer switching (Shift+H/L)
	vim.keymap.set('n', 'H', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })
	vim.keymap.set('n', 'L', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })

	-- Move selection (J/K)
	vim.keymap.set('v', 'J', ":m '>+1<cr>'[V']=gv", { desc = 'Move selection down' })
	vim.keymap.set('v', 'K', ":m '<-2<cr>'[V']=gv", { desc = 'Move selection up' })

end

-- Query tmux @nav_dir and jump to the edge split closest to where
-- the user came from (so vim splits behave like tmux panes).
-- Called from colors.lua's FocusGained handler so the wincmd and
-- highlight resync happen in one uninterrupted callback.
function M.apply_tmux_nav_dir()
	local handle = io.popen('tmux display-message -p "#{@nav_dir}" \\; set-option -qu @nav_dir 2>/dev/null')
	local raw = handle and handle:read('*a') or ''
	if handle then handle:close() end
	local dir = raw:gsub('%s+', '')
	if dir == '' then
		return
	end
	local opposite = { h = 'l', l = 'h', j = 'k', k = 'j' }
	if opposite[dir] then
		vim.cmd('noautocmd 99wincmd ' .. opposite[dir])
	end
end

return M
