return {
	{
		-- lazy vim prefers conform, falls back to lsp for formatting
		"stevearc/conform.nvim",
		enabled = true,
	},
	{
		-- trim trailing whitespace and lines
		"cappyzawa/trim.nvim",
		opts = {},
	},
	{
		"tpope/vim-sleuth",
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
