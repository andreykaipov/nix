return {
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
				terraformls = {},
				-- nixd = {},
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
			},
		},
		-- stylua: ignore
		init = function()
			-- https://github.com/neovim/nvim-lspconfig/tree/master#suggested-configuration
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			keys[#keys + 1] = { "<C-k>", false, mode = "i" } -- C-k is for navigating up in the completion menu
			-- keys[#keys + 1] = { "<leader>ca", false, mode = "n" }
			-- keys[#keys + 1] = { "<leader>cA", false, mode = "n" }

			-- keys[#keys + 1] = { "<C-f>", "<cmd>Lspsaga hover_doc<CR>", mode = "i" }
			-- keys[#keys + 1] = { "K",          "<cmd>Lspsaga hover_doc<CR>",            mode = "n", desc = "(Lspsaga) hover_doc"}
			-- keys[#keys + 1] = { "gD",         "<cmd>Lspsaga peek_definition<CR>",      mode = "n", desc = "(Lspsaga) peek_definition"}
			-- keys[#keys + 1] = { "gf",         "<cmd>Lspsaga finder<CR>",               mode = "n", desc = "(Lspsaga) finder"}
			-- keys[#keys + 1] = { "go",         "<cmd>Lspsaga outline<CR>",              mode = "n", desc = "(Lspsaga) outline"}
			-- keys[#keys + 1] = { "gt",         "<cmd>Lspsaga term_toggle<CR>",          mode = "n", desc = "(Lspsaga) term toggle"}
			-- keys[#keys + 1] = { "<leader>cj", "<cmd>Lspsaga diagnostic_jump_next<CR>", mode = "n", desc = "(Lspsaga) diagnostic_jump_next"}
			-- keys[#keys + 1] = { "<leader>ck", "<cmd>Lspsaga diagnostic_jump_prev<CR>", mode = "n", desc = "(Lspsaga) diagnostic_jump_prev"}
			-- keys[#keys + 1] = { "<leader>cA", "<cmd>Lspsaga code_action<CR>",          mode = "n", desc = "(Lspsaga) code_action"}
			-- keys[#keys + 1] = { "gR", "<cmd>Lspsaga rename ++project<CR>"     , mode = "n", desc = "(Lspsaga) rename ++project"}
			-- keys[#keys + 1] = { "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", mode = "n", desc = "(Lspsaga) show_line_diagnostics"}
		end,
	},
	{
		-- it's like a generic language server
		-- https://www.lazyvim.org/extras/lsp/none-ls
		"nvimtools/none-ls.nvim",
		event = "LazyFile",
		opts = function(_, opts)
			local nls = require("null-ls")
			-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
			-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md

			-- rather than list extending we overwrite them to have finer control
			-- i don't like every default none ls source lazynvim includes for us
			opts.sources = {
				nls.builtins.diagnostics.statix,
				nls.builtins.diagnostics.deadnix,
				nls.builtins.formatting.stylua,
				nls.builtins.formatting.shfmt.with({
					filetypes = { "sh", "bash" },
					extra_args = { "-s", "-ln", "auto", "-i", "8", "-ci" },
				}),
				nls.builtins.hover.printenv,
				nls.builtins.formatting.terraform_fmt.with({
					filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
				}),
				nls.builtins.diagnostics.terraform_validate.with({
					filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
				}),
				nls.builtins.formatting.goimports,
				nls.builtins.formatting.gofumpt,
				-- if using a lightbulb plugin like lspsaga, it will check every line if code actions like
				-- the following are available. make sure to silence those logs in noice
				nls.builtins.code_actions.gomodifytags,
				nls.builtins.code_actions.impl,
				--
				nls.builtins.diagnostics.yamllint,
				-- nls.builtins.formatting.yamlfix,
				-- nls.builtins.formatting.yamlfmt,
				--
				-- nls.builtins.diagnostics.markdownlint,
				-- nls.builtins.diagnostics.markdownlint_cli2,
				nls.builtins.formatting.textlint,
				nls.builtins.hover.dictionary,
			}

			-- table.sort(opts.sources, function(a, b)
			-- 	return a.name < b.name
			-- end)
			-- for _, s in pairs(opts.sources) do
			-- 	print(s.name)
			-- end
		end,
	},
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts)
			-- same idea here, i don't extend this table because i don't like the defaults
			-- and in some cases it's unnecessary because lsps do the same thing, like shellcheck in bashls
			opts.linters_by_ft = {
				nix = { "nix" },
				terraform = { "terraform_validate" },
				tf = { "terraform_validate" },
			}
			return opts
		end,
	},

	-- 	"nvimdev/lspsaga.nvim",
	-- 	event = "LspAttach",
	-- 	enabled = true,
	-- 	opts = {
	-- 		symbol_in_winbar = { -- docs are wrong it's SYMBOL no plural
	-- 			enable = false,
	-- 		},
	-- 		-- https://nvimdev.github.io/lspsaga/lightbulb
	-- 		lightbulb = {
	-- 			virtual_text = false, -- disable the lightbulb only at the end of the line
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("lspsaga").setup(opts)
	-- 	end,
	-- 	dependencies = {
	-- 		"neovim/nvim-lspconfig",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- }
}
