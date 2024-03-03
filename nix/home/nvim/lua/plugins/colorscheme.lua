local Util = require("util")
local colors = Util.colors

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

	local colors_group = vim.api.nvim_create_augroup("colors", { clear = true })
	vim.api.nvim_create_autocmd({ "ColorScheme" }, {
		group = colors_group,
		pattern = "*",
		desc = "set custom highlights",
		callback = function()
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#0b0b0b" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#101010" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "yellow" })
			-- dirty yellow for the cursor
			vim.api.nvim_set_hl(0, "Cursor", { bg = "#7f7b26" }) -- #505050 #5f5b26

			-- ggandor/leap.nvim
			-- vim.api.nvim_set_hl(0, "LeapBackdrop", { link = Util.ui.bg("Comment") })

			-- for nvim-cmp (see plugins/coding.lua)
			-- vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#808080" })

			vim.api.nvim_set_hl(0, "CmpCursorLine", { link = "PmenuSel" })
			vim.api.nvim_set_hl(0, "CmpDoc", { link = "PmenuSel", blend = 0 })
			vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "red" })

			-- telescope
			-- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = colors.dark })
			-- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.dark })
			-- vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = colors.light, bg = colors.dark })
			-- telescope prompt
			-- stylua: ignore
			vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.dark_blue_green, bg = colors.dark_blue_green })
			vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = colors.dark_blue_green })
			vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = colors.light })
			-- telescope preview
			vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = colors.dark, bg = colors.dark })
			vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = colors.dark })
			vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = colors.light })
			-- telescope results
			vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = colors.dark_blue, bg = colors.dark_blue })
			vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = colors.dark_blue })
			vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = colors.dark_blue })
			-- telescope misc
			vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.orange })
			vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "black", bg = colors.light_blue })
			vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = "black", bg = colors.light_blue })
			vim.api.nvim_set_hl(0, "TelescopeMultiSelection", { bg = "red" })
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
