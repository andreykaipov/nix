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
		-- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-surround.txt#L63
		"echasnovski/mini.surround",
		event = "VeryLazy",
		opts = {
			highlight_duration = 5000, -- ms
			-- lazyvim sets these to gz by default because of leap.nvim, but i'm using an alternative
			-- scheme for leap such that gs is still available
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`

				suffix_last = "l", -- Suffix to search with "prev" method
				suffix_next = "n", -- Suffix to search with "next" method
			},
		},
	},
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {
			mappings = {
				-- works also in visual mode if mapping differs from `comment_visual`
				textobject = "gc", -- like dgc ygc or even gcgc (the second gc)
				comment = "gc", -- toggle comment like gcip or gc5j gcva( or gcgc also (the first gc)
				comment_line = "C", -- toggle comment on current line
				comment_visual = "C", -- toggle comment on visual selection
			},
		},
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
	{
		-- navigation, f and t alternative
		"ggandor/leap.nvim",
		event = "VeryLazy",
		dependencies = { "tpope/vim-repeat" },
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			-- leap.add_default_mappings(true)
			vim.keymap.set("n", "s", "<Plug>(leap)")
			vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
			vim.keymap.set({ "x", "o" }, "s", "<Plug>(leap-forward)")
			vim.keymap.set({ "x", "o" }, "S", "<Plug>(leap-backward)")

			-- leap search across all windows
			vim.keymap.set("n", "gs", function()
				local focusable_windows = vim.tbl_filter(function(win)
					return vim.api.nvim_win_get_config(win).focusable
				end, vim.api.nvim_tabpage_list_wins(0))
				require("leap").leap({ target_windows = focusable_windows })
			end)
		end,
	},
	{
		-- structural search and replace
		"cshuaimin/ssr.nvim",
		event = "VeryLazy",
		module = "ssr",
		config = function()
			require("ssr").setup({
				border = "rounded",
				min_width = 50,
				min_height = 5,
				max_width = 120,
				max_height = 25,
				adjust_window = true,
				keymaps = {
					close = "q",
					next_match = "n",
					prev_match = "N",
					replace_confirm = "<cr>",
					replace_all = "<leader><cr>",
				},
			})
			vim.keymap.set({ "n", "x" }, "<leader>r", function()
				require("ssr").open()
			end, {
				desc = "Structural Search and Replace",
			})
		end,
	},
}
