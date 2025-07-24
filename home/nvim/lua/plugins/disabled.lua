return {
	{ "folke/flash.nvim", enabled = false }, -- leap and flit are more than enough
	{ "williamboman/mason.nvim", enabled = false },
	{ "williamboman/mason-lspconfig.nvim", enabled = false },

	-- { "lukas-reineke/headlines.nvim", enabled = false, ft = { "markdown" } }, -- some issue with markdown
	-- { "nvim-treesitter/nvim-treesitter", enabled = false, ft = { "markdown" } }, -- some issue with markdown

	-- lazy vim added some new plugins idk what for
	{ "grug-far.nvim", enabled = false },
	{ "lazydev.nvim", enabled = false },
	{ "luvit-meta", enabled = false },
	{ "markdown.nvim", enabled = false },
	{ "mini.icons", enabled = false },
	{ "nvim-snippets", enabled = false },
	{ "ts-comments.nvim", enabled = false },

	-- not totally disabled, but this not being lazy bothers me
	-- apparently it breaks inverse search, but the only tex file i edit is my resume once in a million years
	-- https://www.lazyvim.org/extras/lang/tex#vimtex
	{ "lervag/vimtex", lazy = true, event = "InsertEnter", ft = { "tex" } },
}
