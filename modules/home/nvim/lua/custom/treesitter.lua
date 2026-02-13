-- Treesitter syntax highlighting and parsing
local M = {}

function M.setup()
	MiniDeps.add('VonHeikemen/ts-enable.nvim')
	MiniDeps.add({
		source = 'nvim-treesitter/nvim-treesitter',
		checkout = 'main',
		hooks = {
			post_checkout = function()
				vim.cmd.TSUpdate()
			end,
		},
		auto_install = true,
	})

	-- NOTE: the list of supported parsers is in the documentation:
	-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
	local ts_parsers = {
		'lua',
		'vim',
		'vimdoc',
		'tf',
		'hcl',
		'go',
		'sh',
		'bash',
		'nix',
		'json',
		'yaml',
		'toml',
	}

	-- See :help ts-enable-config
	-- :checkhealth nvim-treesitter
	vim.g.ts_enable = {
		parsers = ts_parsers,
		auto_install = true,
		highlights = true,
	}
end

return M
