-- User Config
local ok, host_cs = pcall(dofile, vim.fn.stdpath('data') .. '/host.lua')
vim.g.user = {
	leader = ' ',
	scrolloff = 20,
	sidebar_width = 30,
	color = {
		-- colorscheme = { name, lighter_shade [, black_bg] }
<<<<<<< HEAD
		-- colorscheme = { 'tokyonight', 30, true },
		-- colorscheme = { 'night-owl', 30 },
		-- colorscheme = { 'github_dark_default', 30 },
		-- colorscheme = { 'minischeme', 30 },
		-- colorscheme = { 'minicyan', 30 },
		-- colorscheme = { 'minispring', 30 },
		-- colorscheme = { 'minisummer', 30 },
		colorscheme = { 'miniautumn', 30 },
		-- colorscheme = { 'miniwinter', 30 },
		-- colorscheme = { 'carbonfox', 10, true },
		-- colorscheme = { 'moonfly', 10, true },
		-- colorscheme = { 'onedark_dark', 10, true },
		-- colorscheme = { 'vaporwave', 10, true },
=======
		-- overridden by hosts/<name>/default.nix colorscheme when set
		colorscheme = ok and host_cs or { 'vaporwave', 10, true },
>>>>>>> d647e68 (nvim: load colorscheme from host config)
		tmux = {
			pane = 'subtle', -- subtle|chunky
			border = 'all', -- all|unfocused, when pane is chunky, 'unfocused' looks like 'all'
			bg = 'inactive', -- active|inactive, sets tmux status bg + wezterm terminal bg
		},
	},
}

-- Bootstrap mini.nvim
if not require('custom.minideps').setup() then
	vim.notify('Failed to bootstrap mini.nvim', vim.log.levels.ERROR)
	return
end

-- Load custom modules
require('custom.basics').setup()
require('custom.navigation').setup()
require('custom.autosave').setup()
require('custom.colors').setup()
require('custom.editing').setup()
require('custom.guides').setup()
require('custom.git').setup()
require('custom.opencode').setup()
require('custom.buffers').setup()
require('custom.nvim-tree').setup()
require('custom.picker').setup()
require('custom.statusline').setup()
require('custom.treesitter').setup()
require('custom.lsp').setup()

-- Setup MiniNotify after all modules so it doesn't swallow MiniDeps install
-- logs during headless bootstrap (mini.notify is part of mini.nvim, so it
-- doesn't need a MiniDeps.add and has no install log of its own).
require('mini.notify').setup({
	lsp_progress = { enable = false },
})

-- Open notification history in a buffer that doesn't interfere with our buffer logic
vim.keymap.set('n', '<leader>nn', function()
	MiniNotify.show_history()
	vim.bo.buftype = ''
	vim.bo.bufhidden = 'wipe'
	vim.bo.modified = false
end, { desc = 'Notification history' })

-- Reload colorscheme and custom highlights without restarting
vim.keymap.set('n', '<leader>cc', function()
	package.loaded['custom.colors'] = nil
	require('custom.colors').setup()
end, { desc = 'Reload colorscheme' })

-- Reload entire lua config without restarting
vim.keymap.set('n', '<leader>cr', function()
	for name, _ in pairs(package.loaded) do
		if name:match('^custom%.') then
			package.loaded[name] = nil
		end
	end
	dofile(vim.fn.stdpath('config') .. '/init.lua')
	vim.notify('Config reloaded', vim.log.levels.INFO)
end, { desc = 'Reload config' })

-- Ensure trailing newline after headless plugin install output
if #vim.api.nvim_list_uis() == 0 then
	print('')
end
