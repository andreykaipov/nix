-- User Config
vim.g.user = {
	leader = ' ',
	lighter_shade = 30,
	scrolloff = 20,
	sidebar_width = 30,
	-- colorscheme = 'tokyonight',
	-- colorscheme = 'night-owl',
	-- colorscheme = 'github_dark',
	-- colorscheme = 'github_dark_default',
	-- colorscheme = 'minischeme',
	-- colorscheme = 'minicyan',
	-- colorscheme = 'minispring',
	-- colorscheme = 'minisummer',
	colorscheme = 'miniautumn',
	-- colorscheme = 'miniwinter',
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
