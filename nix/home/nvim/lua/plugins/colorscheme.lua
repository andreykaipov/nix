local color_keys = function()
	-- stylua: ignore
	local ignored = { "zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
	"pablo", "murphy", "lunaperche", "koehler", "industry", "evening", "elflord",
	"desert", "default", "darkblue", "blue" }

	return {
		{
			"<leader>uu",
			function() -- prevent ignored colors from being displayed in the picker
				local target = vim.fn.getcompletion

				---@diagnostic disable-next-line: duplicate-set-field
				vim.fn.getcompletion = function()
					return vim.tbl_filter(function(color)
						return not vim.tbl_contains(ignored, color)
					end, target("", "color"))
				end

				require("lazyvim.util").telescope("colorscheme", { enable_preview = true })()
				vim.fn.getcompletion = target
			end,
			desc = "Colorscheme with preview",
		},
	}
end

return {
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = "catppuccin-mocha" },
	},
	{ "oxfist/night-owl.nvim", keys = color_keys() },
	{ "folke/tokyonight.nvim", keys = color_keys() },
	{ "Mofiqul/vscode.nvim", keys = color_keys() },
	{ "rebelot/kanagawa.nvim", keys = color_keys() },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		keys = color_keys(),
		opts = {
			transparent_background = false,
			integrations = {
				aerial = true,
				alpha = true,
				cmp = true,
				dashboard = true,
				flash = true,
				gitsigns = true,
				headlines = true,
				illuminate = true,
				indent_blankline = { enabled = true },
				leap = true,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				navic = { enabled = true, custom_bg = "lualine" },
				neotest = true,
				neotree = true,
				noice = true,
				notify = true,
				semantic_tokens = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
		},
	},
	{
		-- i like to use transparency and nvim-notify doesn't like this
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function(_, opts)
			opts.background_colour = "#000000"
			require("notify").setup(opts)
		end,
		keys = {
			{
				"<localleader><CR>",
				function()
					require("notify").dismiss({ silent = true, pending = true })
					vim.cmd("nohlsearch")
				end,
				desc = "Dismiss all notifications and search highlights (+clear)",
			},
		},
	},
}
