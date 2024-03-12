local util = require("util")

return {
	{
		"andreykaipov/tmux-colorscheme-sync.nvim",
		event = "ColorScheme",
		dependencies = {
			-- "levoouh/tint.nvim",
			-- "lukas-reineke/indent-blankline.nvim", -- i erase some highlight groups this apparently depends on
		},
		version = "*",
		dev = true,
		opts = {
			tmux_source_file = "~/.config/tmux/styles.conf",
		},
		config = function(_, opts)
			require("tmux-colorscheme-sync").setup(opts)
			vim.api.nvim_create_autocmd({ "FocusLost" }, {
				group = util.augroup("tmux-transparency-1"),
				pattern = "*",
				desc = "Sets some nvim highlight groups to none",
				callback = function()
					vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
					vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
					vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
					-- TODO: make neotree transparent when focus is lost but i'm still in nvim
					-- don't think it's possible, when NeoTreeNormalNC is none, it takes the bg of Normal always
					-- might just use float windows for it anyway
					-- vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
					-- vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
				end,
			})
		end,
	},
	{
		"numToStr/Navigator.nvim",
		cmd = {
			"NavigatorLeft",
			"NavigatorDown",
			"NavigatorUp",
			"NavigatorRight",
			"NavigatorPrevious",
		},
		keys = {
			{ "<C-h>", "<cmd>NavigatorLeft<cr>" },
			{ "<C-j>", "<cmd>NavigatorDown<cr>" },
			{ "<C-k>", "<cmd>NavigatorUp<cr>" },
			{ "<C-l>", "<cmd>NavigatorRight<cr>" },
			{ "<C-w>", "<cmd>NavigatorPrevious<cr>" },
		},
		opts = function()
			return {
				-- Save modified buffer(s) when moving to mux
				auto_save = "current", -- nil, 'current', or 'all' buffers

				-- Disable navigation when the current mux pane is zoomed in
				disable_on_zoom = true,

				-- Multiplexer to use
				-- 'auto' - Chooses mux based on priority (default)
				-- table - Custom mux to use
				mux = "auto",
			}
		end,
	},
}
