local util = require("util")

return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "night-owl",
		},
	},
	{
		"oxfist/night-owl.nvim",
		lazy = true,
		priority = 1000,
		opts = {},
		config = function(_, opts)
			util.theme.customize_colorscheme(function()
				require("night-owl").setup(opts)
			end)
		end,
	},
	{
		"folke/tokyonight.nvim",
		enabled = false,
		opts = {
			style = "night",
			transparent = true,
			styles = {
				-- sidebars = "transparent",
				-- floats = "transparent",
				-- hide_inactive_statusline = true,
				-- dim_inactive = true,
				keywords = { bold = true },
				functions = { bold = true },
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		enabled = false,
	},
	{
		-- https://github.com/rebelot/kanagawa.nvim#configuration
		"rebelot/kanagawa.nvim",
		enabled = false,
		opts = {
			transparent = true,
			background = {
				dark = "wave",
				light = "dragon",
			},
		},
	},
}
