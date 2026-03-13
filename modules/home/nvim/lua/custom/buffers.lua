-- Buffer management: close, reopen, layout preservation
local M = {}

function M.setup()
	-- See :help MiniBufremove.config
	require('mini.bufremove').setup({})

	-- Track recently closed buffers for Ctrl+Shift+T reopen
	local closed_buffers = {}

	-- Close buffer and preserve window layout
	local function close_buffer()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.bo[buf].filetype
		-- Don't close special buffers (NvimTree, etc.)
		if ft == 'NvimTree' or vim.bo[buf].buftype ~= '' then
			return
		end
		local name = vim.api.nvim_buf_get_name(buf)
		if name ~= '' then
			table.insert(closed_buffers, name)
		end
		MiniBufremove.delete(buf, true)
	end

	local function reopen_buffer()
		while #closed_buffers > 0 do
			local name = table.remove(closed_buffers)
			if vim.uv.fs_stat(name) then
				vim.cmd.edit(vim.fn.fnameescape(name))
				return
			end
		end
	end

	vim.keymap.set('n', '<leader>bc', close_buffer, { desc = 'Close buffer' })
	-- F1/F2 are sent by WezTerm for Cmd+W / Cmd+Shift+T (see wezterm.lua)
	vim.keymap.set('n', '<F1>', close_buffer, { desc = 'Close buffer (Cmd+W)' })
	vim.keymap.set('n', '<F2>', reopen_buffer, { desc = 'Reopen closed buffer (Cmd+Shift+T)' })

	-- Override :q and :bd so they preserve window layout when NvimTree is open.
	-- Without this, :q closes the window (NvimTree fills the screen) and :bd
	-- uses the built-in bdelete which doesn't keep the split around.
	local function should_close_buffer_instead()
		local buf = vim.api.nvim_get_current_buf()
		if vim.bo[buf].filetype == 'NvimTree' or vim.bo[buf].buftype ~= '' then
			return false
		end
		-- Check if NvimTree is open in a visible window
		local nvimtree_open = false
		local normal_wins = 0
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_config(win).relative == '' then
				local wbuf = vim.api.nvim_win_get_buf(win)
				if vim.bo[wbuf].filetype == 'NvimTree' then
					nvimtree_open = true
				else
					normal_wins = normal_wins + 1
				end
			end
		end
		if normal_wins > 1 then
			return false -- multiple editor windows; :q should close this one
		end
		-- Single editor window with NvimTree: use MiniBufremove to keep layout
		return nvimtree_open
	end

	-- :q and :wq with NvimTree: when there's a single editor window alongside
	-- NvimTree, delete the buffer instead of closing the window (which would
	-- leave NvimTree filling the whole screen). If the buffer is [No Name] and
	-- unmodified, that means it's the last real buffer — quit nvim entirely.
	-- Without NvimTree (or with multiple splits), fall through to the real :q.
	local function quit_or_close(opts)
		if should_close_buffer_instead() then
			local buf = vim.api.nvim_get_current_buf()
			if vim.api.nvim_buf_get_name(buf) == '' and not vim.bo[buf].modified then
				vim.cmd('qa' .. (opts.bang and '!' or ''))
			else
				close_buffer()
			end
		else
			vim.cmd('q' .. (opts.bang and '!' or ''))
		end
	end

	vim.api.nvim_create_user_command('Q', quit_or_close, { bang = true })

	vim.api.nvim_create_user_command('Wq', function(opts)
		vim.cmd('w' .. (opts.bang and '!' or ''))
		quit_or_close(opts)
	end, { bang = true })

	vim.api.nvim_create_user_command('Bd', function()
		close_buffer()
	end, { bang = true })

	-- Rewrite :q/:wq/:bd at the command line so users don't need to learn new commands
	vim.cmd([[cnoreabbrev <expr> q  getcmdtype() == ':' && getcmdline() ==# 'q'  ? 'Q'  : 'q']])
	vim.cmd([[cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() ==# 'wq' ? 'Wq' : 'wq']])
	vim.cmd([[cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() ==# 'bd' ? 'Bd' : 'bd']])
	vim.cmd([[cnoreabbrev <expr> bdelete getcmdtype() == ':' && getcmdline() ==# 'bdelete' ? 'Bd' : 'bdelete']])

	-- Clean up [No Name] buffers when a real file is opened
	vim.api.nvim_create_autocmd('BufEnter', {
		group = vim.g.user.event,
		callback = function()
			local cur = vim.api.nvim_get_current_buf()
			if vim.api.nvim_buf_get_name(cur) == '' or not vim.bo[cur].buflisted then
				return
			end
			for _, b in ipairs(vim.api.nvim_list_bufs()) do
				if
				    b ~= cur
				    and vim.bo[b].buflisted
				    and vim.api.nvim_buf_get_name(b) == ''
				    and vim.bo[b].buftype == ''
				    and not vim.bo[b].modified
				then
					vim.api.nvim_buf_delete(b, {})
				end
			end
		end,
	})
end

return M
