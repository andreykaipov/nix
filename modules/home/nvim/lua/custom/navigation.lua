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

	-- When entering Neovim from a tmux pane, jump to the edge split closest
	-- to where we came from (so vim splits behave like tmux panes).
	-- tmux sets @nav_dir before select-pane; we read+clear it in one call.
	-- This must be synchronous so the wincmd runs before colors.lua's
	-- FocusGained resync — otherwise the resync highlights the stale
	-- active window and a redraw between the two causes a flicker.
	vim.api.nvim_create_autocmd('FocusGained', {
		group = vim.g.user.event,
		callback = function()
			local raw = vim.fn.system('tmux display-message -p "#{@nav_dir}" \\; set-option -qu @nav_dir')
			local dir = raw:gsub('%s+', '')
			if dir == '' then
				return
			end
			local opposite = { h = 'l', l = 'h', j = 'k', k = 'j' }
			if opposite[dir] then
				vim.cmd('noautocmd 99wincmd ' .. opposite[dir])
				-- noautocmd suppressed WinEnter/WinLeave, so the
				-- DimInactiveSplits winhighlight state is stale.
				-- Resync all windows: dim inactive, clear active.
				vim.api.nvim_exec_autocmds('User', { pattern = 'DimInactiveSplitsResync' })
			end
		end,
	})
end

return M
