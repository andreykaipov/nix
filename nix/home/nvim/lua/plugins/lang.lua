return {
	{
		-- add additional treesitter parsers not already included in the defaults
		-- https://www.lazyvim.org/plugins/treesitter#nvim-treesitter
		"nvim-treesitter/nvim-treesitter",
		event = { "LazyFile", "VeryLazy" },
		opts = {
			ensure_installed = {
				"go",
				"nix",
				"hcl",
			},
		},
	},
	{
		-- go specific
		"ray-x/go.nvim",
		event = { "CmdlineEnter" },
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
		end,
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
}
