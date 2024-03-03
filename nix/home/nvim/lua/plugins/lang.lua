return {
	{
		-- add additional treesitter parsers not already included in the defaults
		-- https://www.lazyvim.org/plugins/treesitter#nvim-treesitter
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"go",
				"nix",
				"hcl",
			},
		},
	},
	{
		-- go specific
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		opts = {
			-- https://nvimdev.github.io/lspsaga/lightbulb
			lightbulb = {
				virtual_text = false, -- disable the lightbulb only at the end of the line
			},
		},
		-- config = function(_, opts)
		-- 	require("lspsaga").setup(opts)
		-- end,
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		-- lsp
		"neovim/nvim-lspconfig",
		event = "LazyFile",
		opts = {
			capabilities = {},
			servers = {
				lua_ls = {},
				bashls = {},
				golangci_lint_ls = {},
				terraformls = {
					-- overwrite default lazyvim tf lang extension to also include hcl files
					filetypes = { "terraform", "terraform-vars", "hcl" },
				},
				nil_ls = {
					autostart = true,
					settings = {
						["nil"] = {
							formatting = {
								command = { "nixpkgs-fmt" },
							},
						},
					},
				},
				-- nixd = {},
			},
		},
		-- stylua: ignore
		init = function()
			-- https://github.com/neovim/nvim-lspconfig/tree/master#suggested-configuration
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			keys[#keys + 1] = { "<C-k>", false, mode = "i" } -- C-k is for navigating up in the completion menu
			-- keys[#keys + 1] = { "<leader>ca", false, mode = "n" }
			keys[#keys + 1] = { "<leader>cA", false, mode = "n" }

			-- keys[#keys + 1] = { "<C-f>", "<cmd>Lspsaga hover_doc<CR>", mode = "i" }
			keys[#keys + 1] = { "K",          "<cmd>Lspsaga hover_doc<CR>",            mode = "n", desc = "(Lspsaga) hover_doc"}
			keys[#keys + 1] = { "gD",         "<cmd>Lspsaga peek_definition<CR>",      mode = "n", desc = "(Lspsaga) peek_definition"}
			keys[#keys + 1] = { "gf",         "<cmd>Lspsaga finder<CR>",               mode = "n", desc = "(Lspsaga) finder"}
			keys[#keys + 1] = { "go",         "<cmd>Lspsaga outline<CR>",              mode = "n", desc = "(Lspsaga) outline"}
			keys[#keys + 1] = { "gt",         "<cmd>Lspsaga term_toggle<CR>",          mode = "n", desc = "(Lspsaga) term toggle"}
			keys[#keys + 1] = { "<leader>cj", "<cmd>Lspsaga diagnostic_jump_next<CR>", mode = "n", desc = "(Lspsaga) diagnostic_jump_next"}
			keys[#keys + 1] = { "<leader>ck", "<cmd>Lspsaga diagnostic_jump_prev<CR>", mode = "n", desc = "(Lspsaga) diagnostic_jump_prev"}
			keys[#keys + 1] = { "<leader>cA", "<cmd>Lspsaga code_action<CR>",          mode = "n", desc = "(Lspsaga) code_action"}
			-- keys[#keys + 1] = { "gR", "<cmd>Lspsaga rename ++project<CR>"     , mode = "n", desc = "(Lspsaga) rename ++project"}
			-- keys[#keys + 1] = { "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", mode = "n", desc = "(Lspsaga) show_line_diagnostics"}
		end,
	},
	{
		-- it's like a generic language server?
		-- https://www.lazyvim.org/extras/lsp/none-ls
		"nvimtools/none-ls.nvim",
		event = "LazyFile",
		opts = function(_, opts)
			local nls = require("null-ls")

			-- so basically shfmt is included by default, but we want to change the args (added below)
			-- so what this does is get the default nonels sources (and those injected by lazyvim extras)
			-- but ignores the default shfmt
			local defaults = { ["shfmt"] = true }
			local sources = {}
			for _, s in pairs(opts.sources) do
				if defaults[s.name] == nil then
					vim.list_extend(sources, { s })
				end
			end

			-- alternatively I guess we can just add all the nonels extras ourselves here:
			-- https://www.lazyvim.org/extras/lang/go#none-lsnvim-optional
			-- https://www.lazyvim.org/extras/lang/terraform#none-lsnvim-optional
			--
			-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
			-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
			vim.list_extend(sources or {}, {
				-- nix
				-- nls.builtins.diagnostics.statix,
				-- nls.builtins.diagnostics.deadnix,
				nls.builtins.formatting.shfmt.with({
					filetypes = { "sh", "bash" },
					extra_args = { "-s", "-ln", "auto", "-i", "8", "-ci" },
				}),
				nls.builtins.formatting.taplo,
				nls.builtins.formatting.terrafmt, -- markdown nested tf blocks
				nls.builtins.formatting.trim_newlines.with({ filetypes = { "*" } }),
				nls.builtins.formatting.trim_whitespace.with({ filetypes = { "*" } }),
				nls.builtins.formatting.textlint,
				-- nls.builtins.formatting.yamllint,
				-- nls.builtins.formatting.yamlfix,
				-- nls.builtins.formatting.yamlfmt,
				nls.builtins.hover.dictionary,
				nls.builtins.hover.printenv,
			})

			opts.sources = sources

			-- table.sort(opts.sources, function(a, b)
			-- 	return a.name < b.name
			-- end)
			-- for _, s in pairs(opts.sources) do
			-- 	print(s.name)
			-- end
		end,
	},
	{
		-- disable auto lsp installs via mason, but we can still manually install them as separate tools below
		-- however i prefer to install all these via home manager, otherwise i'm managing two package managers
		"williamboman/mason-lspconfig.nvim",
		enabled = false,
	},
	{
		-- package manager for nvim, but we use nix so it's not needed
		-- https://www.lazyvim.org/plugins/lsp#masonnvim-1
		"williamboman/mason.nvim",
		enabled = false,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				-- no need to install LSPs here, only additonal tooling
				-- the LSP servers are auto installed above also via Mason
				"shfmt",
				"shellcheck",
				"stylua",
			})
			opts.ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			}
			opts.pip = {
				upgrade_pip = false,
			}
		end,
	},
}
