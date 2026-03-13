-- opencode.nvim AI assistant integration
local M = {}

function M.setup()
	MiniDeps.add('nickjvandyke/opencode.nvim')

	-- See :help opencode.nvim
	---@type opencode.Opts
	vim.g.opencode_opts = {
		server = {
			start = function()
				vim.fn.system('tmux split-window -h -l 40% "opencode --port"')
			end,
			stop = function()
				vim.fn.system('tmux kill-pane -t opencode 2>/dev/null')
			end,
			toggle = function()
				-- If there's already a pane running opencode, select it; otherwise create one
				local pane = vim.fn
				    .system(
				    'tmux list-panes -F "#{pane_id} #{pane_current_command}" | grep opencode | head -1 | cut -d" " -f1')
				    :gsub('%s+', '')
				if pane ~= '' then
					vim.fn.system('tmux select-pane -t ' .. pane)
				else
					vim.fn.system('tmux split-window -h -l 40% "opencode --port"')
				end
			end,
		},
	}
	vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
		require('opencode').ask(nil, { clear = true, submit = true })
	end, { desc = 'Ask opencode' })
	vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
		require('opencode').select()
	end, { desc = 'Opencode select' })
	vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
		require('opencode').toggle()
	end, { desc = 'Toggle opencode' })
	vim.keymap.set({ 'n', 'x' }, '<leader>og', function()
		return require('opencode').operator('@this ')
	end, { desc = 'Send to opencode', expr = true })
	vim.keymap.set('n', '<leader>ogg', function()
		return require('opencode').operator('@this ') .. '_'
	end, { desc = 'Send line to opencode', expr = true })
end

return M
