vim.opt.completeopt = "menu,menuone,noinsert,noselect" -- preview

return {
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"sergioribera/cmp-dotenv",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"petertriho/cmp-git",
			"hrsh7th/cmp-buffer",
		},
		opts = require("util").cmp.cmp_opts(),
		config = function(_, opts)
			local cmp = require("cmp")
			for _, source in ipairs(opts.sources) do
				source.group_index = source.group_index or 1
			end
			cmp.setup(opts)
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({ { name = "git" } }, { { name = "buffer" } }),
			})
			cmp.setup.filetype("sh", {
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "luasnip" },
					{ name = "emoji" },
					-- { name = "dotenv" },
				}, { { name = "buffer" } }),
			})
			cmp.setup.cmdline({ "/", "?" }, {
				completion = { keyword_length = 1 },
				sources = {
					{ name = "nvim_lsp_document_symbol" },
					{ name = "buffer" },
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		build = "make install_jsregexp",
		-- version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- build = (jit.os:find("macos") and "make install_jsregexp" or nil),
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
	},
	{
		"github/copilot.vim",
		event = "InsertEnter",
		-- cmd = "Copilot",
		-- build = ":Copilot auth",
		config = function()
			-- vim.keymap.set("i", "<c-j>", 'copilot#accept("\\<cr>")', {
			-- 	expr = true,
			-- 	replace_keycodes = false,
			-- })
			-- vim.g.copilot_no_tab_map = true
			-- vim.keymap.set("i", "<c-j>", "<plug>(copilot-accept-line)")
			-- vim.keymap.set('i', '<c-i>', '<plug>(copilot-previous)')
			vim.keymap.set("i", "<s-tab>", "<plug>(copilot-suggest)")
			vim.keymap.set("i", "<c-l>", "<plug>(copilot-accept-word)")
			vim.keymap.set("i", "<c-o>", "<plug>(copilot-next)")
		end,
	},
}
