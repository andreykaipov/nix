return {
	{
		"numToStr/Navigator.nvim",
		cmd = {
			"NavigatorLeft",
			"NavigatorDown",
			"NavigatorUp",
			"NavigatorRight",
			"NavigatorPrevious",
		},
		keys = {
			{ "<C-h>", "<cmd>NavigatorLeft<cr>" },
			{ "<C-j>", "<cmd>NavigatorDown<cr>" },
			{ "<C-k>", "<cmd>NavigatorUp<cr>" },
			{ "<C-l>", "<cmd>NavigatorRight<cr>" },
			{ "<C-w>", "<cmd>NavigatorPrevious<cr>" },
		},
		opts = function()
			return {
				-- Save modified buffer(s) when moving to mux
				auto_save = "current", -- nil, 'current', or 'all' buffers

				-- Disable navigation when the current mux pane is zoomed in
				disable_on_zoom = true,

				-- Multiplexer to use
				-- 'auto' - Chooses mux based on priority (default)
				-- table - Custom mux to use
				mux = "auto",
			}
		end,
	},
}
