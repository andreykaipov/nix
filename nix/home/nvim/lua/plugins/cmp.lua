return {
	{
		"github/copilot.vim",
		event = "VeryLazy",
		-- priority = 200,
		-- cmd = "Copilot",
		-- build = ":Copilot auth",
		config = function()
			vim.keymap.set("i", "<s-tab>", "<plug>(copilot-suggest)")
			vim.keymap.set("i", "<c-e>", "<plug>(copilot-accept-line)")
			vim.keymap.set("i", "<c-w>", "<plug>(copilot-next)")

			-- vim.keymap.set("i", "<c-j>", 'copilot#accept("\\<cr>")', {
			-- 	expr = true,
			-- 	replace_keycodes = false,
			-- })
			-- vim.g.copilot_no_tab_map = true
			-- vim.keymap.set('i', '<c-i>', '<plug>(copilot-previous)')
			-- vim.keymap.set("i", "<c-l>", "<plug>(copilot-accept-word)")
		end,
	},
}
