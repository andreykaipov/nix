return {
	{
		-- lazy vim prefers conform, falls back to lsp for formatting
		-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#lazy-loading-with-lazynvim
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		enabled = true,
	},
	{
		"tpope/vim-sleuth",
		event = { "BufRead" },
		config = function(_, opts)
			-- classic vim plugin, no setup() call necessary

			local opt = vim.opt
			opt.listchars = {
				tab = "→ ",
				space = "·",
				eol = "↲",
				nbsp = "␣",
				trail = "•",
				extends = "⟩",
				precedes = "⟨",
			}

			vim.keymap.set("n", "<localleader>l", ":set invlist<cr>") -- toggle listchars
		end,
	},
}
