local Util = require("util")

local customize_colorscheme = function(f)
	local opt = vim.opt
	opt.signcolumn = "yes:1" -- always show sign column
	opt.cursorline = true -- highlight current line
	opt.cursorlineopt = "line,number" --
	-- opt.colorcolumn = table.concat(vim.fn.range(81, 120), ",") -- highlight column 81 to 120
	opt.colorcolumn = "120"
	opt.termguicolors = true
	opt.background = "dark"

	opt.guicursor = "\z
		n-c-v:block-Cursor,\z
		i-c-ve:ver25-Cursor-blinkwait600-blinkoff400-blinkon600,\z
		r-cr-o:hor20-Cursor-blinkwait600-blinkoff400-blinkon600\z
	"

	f()

	local colors = vim.api.nvim_create_augroup("colors", { clear = true })
	vim.api.nvim_create_autocmd({ "ColorScheme" }, {
		group = colors,
		pattern = "*",
		desc = "set custom highlights",
		callback = function()
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#0b0b0b" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#101010" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "yellow" })
			-- dirty yellow for the cursor
			vim.api.nvim_set_hl(0, "Cursor", { bg = "#5f5b26" }) -- #505050

			-- ggandor/leap.nvim
			-- vim.api.nvim_set_hl(0, "LeapBackdrop", { link = Util.ui.bg("Comment") })

			-- for nvim-cmp (see plugins/coding.lua)
			-- vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#808080" })

			vim.api.nvim_set_hl(0, "CmpCursorLine", { link = "PmenuSel" })
			vim.api.nvim_set_hl(0, "CmpDoc", { link = "PmenuSel", blend = 0 })
			vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "red" })
		end,
	})
end

return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "night-owl",
		},
	},
	{
		"oxfist/night-owl.nvim",
		opts = {},
		config = function(_, opts)
			customize_colorscheme(function()
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
