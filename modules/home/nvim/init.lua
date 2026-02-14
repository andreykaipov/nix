-- User Config
vim.g.user = {
	leader = ' ',
	scrolloff = 20,
	sidebar_width = 30,
	color = {
		-- colorscheme = { name, lighter_shade [, black_bg] }
		-- colorscheme = { 'tokyonight', 30, true },
		-- colorscheme = { 'night-owl', 30 },
		-- colorscheme = { 'github_dark_default', 30 },
		-- colorscheme = { 'minischeme', 30 },
		-- colorscheme = { 'minicyan', 30 },
		-- colorscheme = { 'minispring', 30 },
		-- colorscheme = { 'minisummer', 30 },
		-- colorscheme = { 'miniautumn', 30 },
		-- colorscheme = { 'miniwinter', 30 },
		-- colorscheme = { 'carbonfox', 10, true },
		-- colorscheme = { 'moonfly', 10, true },
		colorscheme = { 'onedark_dark', 10, true },
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
