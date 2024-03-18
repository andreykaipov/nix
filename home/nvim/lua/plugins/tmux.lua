return {
	{
		"andreykaipov/tmux-colorscheme-sync.nvim",
		event = "ColorScheme",
		opts = {
			tmux_source_file = "~/.config/tmux/styles.conf",
		},
		config = function(_, opts)
			local util = require("util")

			-- vim.api.nvim_create_autocmd({ "ColorScheme" }, {
			-- 	group = util.augroup("tmux-colorscheme-black"),
			-- 	pattern = "*",
			-- 	desc = "No matter the colorscheme, set the bg of Normal to black",
			-- 	callback = function()
			-- 		vim.api.nvim_set_hl(0, "Normal", { bg = "black" })
			-- 	end,
			-- })

			local normal = {}
			local normal_nc = {}
			local line_nr = {}
			vim.api.nvim_create_autocmd({ "ColorScheme" }, {
				group = util.augroup("get-original-colors"),
				pattern = "*",
				desc = "",
				callback = function()
					normal = util.ui.color("Normal")
					normal_nc = util.ui.color("NormalNC")
					line_nr = util.ui.color("LineNr")
				end,
			})
			vim.api.nvim_create_autocmd({ "FocusLost" }, {
				group = util.augroup("tmux-make-transparent"),
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
			vim.api.nvim_create_autocmd({ "FocusGained" }, {
				group = util.augroup("tmux-restore-transparency"),
				pattern = "*",
				desc = "Restores transparency to original colors of colorscheme",
				callback = function()
					vim.api.nvim_set_hl(0, "Normal", { bg = normal.bg })
					vim.api.nvim_set_hl(0, "NormalNC", { bg = normal_nc.bg })
					vim.api.nvim_set_hl(0, "LineNr", { bg = line_nr.bg })
				end,
			})

			require("tmux-colorscheme-sync").setup(opts)
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
