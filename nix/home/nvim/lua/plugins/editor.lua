return {
	{
		-- highlights similar words when you hover over them
		"vim-illuminate",
		event = "VeryLazy",
		enabled = true,
		opts = {
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

			-- fix colors
			vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "green" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "gold2" })

			-- word diff in buffer
			vim.api.nvim_set_hl(0, "GitSignsAddLnInline", { bg = "DarkGreen" })
			vim.api.nvim_set_hl(0, "GitSignsChangeLnInline", { bg = "gold3" })
			vim.api.nvim_set_hl(0, "GitSignsDeleteLnInline", { bg = "maroon" })
		end,
	},
	{
		-- disable included default, leap and flit are more than enough
		"folke/flash.nvim",
		event = "VeryLazy",
		enabled = false,
	},
	{
		-- navigation, f and t alternative
		"ggandor/leap.nvim",
		event = "VeryLazy",
		dependencies = { "tpope/vim-repeat" },
		enabled = true,
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")

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
		-- navigation, better f and t
		"ggandor/flit.nvim",
		event = "VeryLazy",
		enabled = true,
		keys = function()
			local ret = {}
			for _, key in ipairs({ "f", "F", "t", "T" }) do
				ret[#ret + 1] = {
					key,
					mode = { "n", "x", "o" },
					desc = key,
				}
			end
			return ret
		end,
		opts = {
			labeled_modes = "nxo",
			multiline = true,
		},
		config = function(_, opts)
			require("flit").setup(opts)
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
	-- the following are default so i don't have to include them but leaving as a reminder
	{
		-- gcc - toggle comment in current line
		-- gc - toggle comment in normal and vis
		-- gc - comment textobject like dgc, gc5j, or gcva{
		"echasnovski/mini.comment",
		event = "VeryLazy",
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
				start = "gA",
			},
		},
		config = function(_, opts)
			require("mini.align").setup(opts)
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
			vim.keymap.set({ "x" }, "<leader>r", function()
				require("ssr").open()
			end, {
				desc = "Structural Search and Replace",
			})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		event = "VeryLazy",
		lazy = true,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		event = "VeryLazy",
		lazy = true,
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		-- https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/119#issuecomment-1873653249
		-- build = 'CFLAGS=-march=native make',
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		opts = function()
			local actions = require("telescope.actions")
			local actions_layout = require("telescope.actions.layout")
			return {
				defaults = {
					sort_mru = true,
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						center = {
							prompt_position = "top",
							width = 0.75,
							height = 0.75,
						},
						horizontal = {
							prompt_position = "top",
							width = 0.75,
							height = 0.75,
							preview_width = 0.65,
							preview_cutoff = 80,
						},
						vertical = {
							prompt_position = "bottom",
							width = 0.75,
							height = 0.9,
						},
					},
					border = true,
					multi_icon = "",
					entry_prefix = "   ",
					prompt_prefix = "   ",
					selection_caret = "  ",
					hl_result_eol = true,
					results_title = "",
					winblend = 0,
					wrap_results = true,
					mappings = {
						-- emacs-esque navigation in telescope
						i = {
							-- ["<esc>"] = actions.close,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-u>"] = false,
							["<C-f>"] = actions.preview_scrolling_up,
							["<C-b>"] = actions.preview_scrolling_down,
							["<C-p>"] = actions_layout.toggle_preview,
							-- ["<A-t>"] = open_selected_with_trouble,
							-- ["<A-i>"] = find_files_no_ignore,
							-- ["<A-h>"] = find_files_with_hidden,
							-- ["<C-Down>"] = actions.cycle_history_next,
							-- ["<C-Up>"] = actions.cycle_history_prev,
							-- ["<C-t>"] = open_with_trouble,
						},
						n = {
							["q"] = actions.close,
							["j"] = actions.move_selection_next,
							["k"] = actions.move_selection_previous,
						},
					},
				},
				pickers = {
					find_files = {},
				},
				extensions = {
					file_browser = {
						theme = "ivy",
						initial_mode = "normal",
						hijack_netrw = true,
					},
				},
			}
		end,
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("file_browser")
			require("telescope").load_extension("notify")
			vim.api.nvim_set_keymap(
				"n",
				"<leader>fb",
				":Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ noremap = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<localleader>n",
				":Telescope notify theme=ivy initial_mode=normal<CR>",
				{ desc = "Open notifications", noremap = true }
			)
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		event = "VeryLazy",
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
