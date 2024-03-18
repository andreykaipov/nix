return {
	{
		"whonore/vim-sentencer",
		ft = { "markdown", "tex", "text", "txt" },
		config = function()
			vim.g.sentencer_textwidth = -1 -- since we want one sentence per line, we don't want to wrap
			vim.g.sentencer_filetypes = { "*" } -- we only load this for the above fts anyway
			vim.g.sentencer_punctuation = ".!?:"
			vim.g.sentencer_ignore = {
				"i.e",
				"e.g",
				"vs",
				"Dr",
				"Mr",
				"Mrs",
				"Ms",
				"Prof",
			}

			vim.opt.formatoptions:append("n") -- better line wrapping sentences in list items
			-- from my old vim config: https://github.com/andreykaipov/self/blob/3ad8150e1b3433de88f955dd1aa7fac2581b89f0/.config/nvim/after/ftplugin/markdown.vim
			-- idk if i need this yet
			-- let &formatlistpat='^\s*\d\+\.\s\+\|^\s*[-*+]\s\+\|^\[^\ze[^\]]\+\]:'

			-- auto format with sentencer above after writing
			local preserve = function(command)
				-- save last search and cursor position
				local saved_search = vim.fn.getreg("/")
				local line_number = vim.fn.line(".")
				local col_number = vim.fn.col(".")
				-- do the business
				vim.cmd(command)
				-- restore previous search history and cursor position
				vim.fn.setreg("/", saved_search)
				vim.fn.cursor(line_number, col_number)
			end
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = require("util").augroup("autoformat-after-writing"),
				pattern = "*",
				desc = "",
				callback = function()
					preserve("normal gqq<CR>")
				end,
			})
		end,
	},
	{
		-- i can't decide if i hate how this makes my markdown look or not
		"lukas-reineke/headlines.nvim",
		enabled = true,
		opts = {
			markdown = {
				headline_highlights = false,
			},
		},
	},
}
