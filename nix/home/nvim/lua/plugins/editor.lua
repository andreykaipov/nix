-- this has plugins mainly around both the look and feel and functionality of the editor

return {
	{
		-- highlights similar words when you hover over them
		"vim-illuminate",
		event = "VeryLazy",
		enabled = true,
		opts = {
			-- but not under my cursor
			under_cursor = false,
		},
	},
	{
		-- show the current line's indent guide
		"echasnovski/mini.indentscope",
		event = "VeryLazy",
		enabled = true,
		opts = {
			-- for more symbols, see :h ibl.config.indent.char
			symbol = "│",
		},
	},
	{
		-- show other lines' indent guides
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		enabled = true,
		opts = {
			indent = {
				char = "╎", -- ┊
				tab_char = "┆",
			},
		},
	},
	{
		-- git signs in the gutter
		-- https://www.lazyvim.org/plugins/editor#gitsignsnvim
		"lewis6991/gitsigns.nvim",
		event = "LazyFile",
		opts = {},
		config = function(_, opts)
			require("gitsigns").setup(opts)
			--
			-- 	-- fix colors
			vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "green" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "gold2" })
			--
			-- 	-- word diff in buffer
			vim.api.nvim_set_hl(0, "GitSignsAddLnInline", { bg = "DarkGreen" })
			vim.api.nvim_set_hl(0, "GitSignsChangeLnInline", { bg = "gold3" })
			vim.api.nvim_set_hl(0, "GitSignsDeleteLnInline", { bg = "maroon" })
		end,
	},
	{
		"echasnovski/mini.align",
		event = "VeryLazy",
		version = "*",
		-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md#default-config
		opts = {
			-- swap the default mappings around, preview seems more responsive
			mappings = {
				start_with_preview = "ga",
				start = "gA",
			},
		},
		config = function(_, opts)
			require("mini.align").setup(opts)
		end,
	},
	{
		-- rename surround mappings from gs to gz to prevent conflict with leap
		-- also see mini.ai below
		"echasnovski/mini.surround",
		event = "VeryLazy",
		opts = {
			highlight_duration = 5000, -- ms
			mappings = {
				add = "gza", -- Add surrounding in Normal and Visual modes
				delete = "gzd", -- Delete surrounding
				find = "gzf", -- Find surrounding (to the right)
				find_left = "gzF", -- Find surrounding (to the left)
				highlight = "gzh", -- "Highlight" surrounding
				replace = "gzr", -- Replace surrounding
				update_n_lines = "gzn", -- Update `n_lines`
			},
		},
	},
	{
		-- gcc - toggle comment in current line
		-- gc - toggle comment in normal and vis
		-- gc - comment textobject like dgc, gc5j, or gcva{
		"echasnovski/mini.comment",
		event = "VeryLazy",
	},
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {
			mappings = {
				["'"] = false,
				['"'] = false,
			},
		},
	},
	{
		-- better text objects
		-- select boundaries like vi" or vi( to select things inside of " or ()
		-- use va(round) to include boundary, and v(inside) for exclusivity
		-- van - around next
		-- val - around last
		--
		-- vaq - quotes
		-- vaf - functions
		-- vab - brackets, parens, "boundaries"
		-- va? - user prompt for left and right
		-- vaa - function arguments
		-- va - can work for any other character
		--
		-- can also use [c]hange motion - ci" to replace whatever is in quotes
		"echasnovski/mini.ai",
		event = "VeryLazy",
	},
	{
		"echasnovski/mini.align",
		event = "VeryLazy",
		version = "*",
		-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md#default-config
		opts = {
			-- swap the default mappings around, preview seems more responsive
			mappings = {
				start_with_preview = "ga",
				start = "ga",
			},
		},
		config = function(_, opts)
			require("mini.align").setup(opts)
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>e",
				function()
					local handle = io.popen(
						string.format("git rev-parse --show-toplevel 2>/dev/null || echo '%s'", vim.fn.expand("%:h"))
					)
					local dir = handle:read("*all")
					dir = dir:gsub("%s+", "")
					handle:close()
					require("neo-tree.command").execute({ position = "float", toggle = true, dir = dir })
				end,
				desc = "Explorer NeoTree (toplevel)",
				remap = true,
			},
		},
		opts = {
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						".gitignore",
						".gitmodules",
						".github",
						".envrc",
						".direnv",
					},
					never_show = {
						".git",
						"flake.lock",
						"devenv.lock",
						".devenv",
						".devenv.flake.nix",
						".pre-commit-config.yaml",
						"go.sum",
						"package-lock.json",
					},
				},
			},
		},
	},
}
