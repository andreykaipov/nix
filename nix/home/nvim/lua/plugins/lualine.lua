return {
	{
		-- https://www.lazyvim.org/plugins/ui#lualinenvim
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"meuter/lualine-so-fancy.nvim",
		},
		init = function()
			-- hides the statusline so it doesn't flicker when lualine and reassigns it to the winbar
			vim.opt.laststatus = 0
			-- without a statusline, we force an empty winbar to prevent the text from hopping around
			-- after it loads in
			local win = vim.api.nvim_get_current_win()
			vim.wo[win].winbar = " "
			-- tabline isn't a problem but i don't need it
			vim.opt.showtabline = 0
		end,
		opts = function(_, opts)
			opts.options = {
				-- globalstatus = true,
				disabled_filetypes = {
					statusline = {
						-- "dashboard",
						"alpha",
						"starter",
						"neo-tree",
						"sagaoutline",
					},
				},
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" }, --│
			}
		end,
		config = function(_, opts)
			-- move the statusline into the winbar
			opts.winbar = opts.sections
			opts.inactive_winbar = opts.sections
			opts.options.disabled_filetypes.winbar = opts.options.disabled_filetypes.statusline
			-- remove the statusline
			opts.sections = {}
			opts.inactive_sections = {}
			--
			require("lualine").setup(opts)
		end,
	},
}
