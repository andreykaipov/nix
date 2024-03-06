local M = {}

-- the night-owl theme but with some colors swapped around
-- https://github.com/oxfist/night-owl.nvim/blob/2b7e78c34e25aea841d10ebc3ee19d6d558e9ec0/lua/lualine/themes/night-owl.lua
-- can import as follows alternatively and do the overwriting but i think redefining it is easier:
-- local theme = require("lualine.themes.night-owl")
M.colors = {
	dark = "#010d18",
	light = "#d6deeb",
	magenta = "#c792ea",
	green = "#c5e478",
	yellow = "#e2b93d",
	orange = "#f78c6c",
	cyan = "#6ae9f0",
	dark_blue = "#0e293f",
	light_blue = "#5f7e97",
	dark_blue_green = "#006b6b",
}

M.customize_colorscheme = function(f)
	local opt = vim.opt
	opt.signcolumn = "yes:3-5" -- so new gutter signs don't move the text
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
			-- vim.api.nvim_set_hl(0, "Normal", { bg = M.colors.dark })
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
			vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = M.colors.dark_blue_green, bg = M.colors.dark_blue_green })
			vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = M.colors.dark_blue_green })
			vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = M.colors.light })
			-- telescope preview
			vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = M.colors.dark, bg = M.colors.dark })
			vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = M.colors.dark })
			vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = M.colors.light })
			-- telescope results
			vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = M.colors.dark_blue, bg = M.colors.dark_blue })
			vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = M.colors.dark_blue })
			vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = M.colors.dark_blue })
			-- telescope misc
			-- vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = M.colors.orange })
			-- vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "black", bg = M.colors.light_blue })
			vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = "black", bg = M.colors.light_blue })
			vim.api.nvim_set_hl(0, "TelescopeMultiSelection", { bg = "red" })
		end,
	})
end

return M
