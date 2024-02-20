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
		-- lsp
		"neovim/nvim-lspconfig",
		event = "LazyFile",
		opts = {
			capabilities = {},
			servers = {
				lua_ls = {},
				bashls = {},
				terraformls = {
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
		init = function()
			-- https://github.com/neovim/nvim-lspconfig/tree/master#suggested-configuration
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			keys[#keys + 1] = { "<C-k>", false, mode = "i" } -- C-k is for navigating up in the completion menu
			keys[#keys + 1] = { "<C-f>", vim.lsp.buf.signature_help, mode = "i" } -- C-k is for navigating up in the completion menu
		end,
	},
	{
		-- it's like a generic language server?
		-- https://www.lazyvim.org/extras/lsp/none-ls
		"nvimtools/none-ls.nvim",
		event = "LazyFile",
		opts = function(_, opts)
			local nls = require("null-ls")

			-- remove default shfmt included by lazyvim
			local sources = {}
			for _, s in pairs(opts.sources) do
				if not string.match(s.name, "(shfmt)") then
					vim.list_extend(sources, { s })
				end
			end

			-- we don't want to just replace the sources because lazyvim extras extend this list before
			-- our plugins are loaded, so those will be overwritten.
			-- alternatively I guess we can just add all those on our own, see:
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
					extra_args = { "-s", "-ln", "posix", "-i", "8", "-ci" },
				}),
				nls.builtins.formatting.taplo,
				nls.builtins.formatting.terrafmt,
				nls.builtins.formatting.terraform_fmt,
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
