return {
	{
		"github/copilot.vim",
		event = { "InsertEnter", "VeryLazy" },
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
	{
		"L3MON4D3/LuaSnip",
		event = { "InsertEnter", "VeryLazy" },
		-- build = "make install_jsregexp",
		-- why does lazynvim add tab mappings here...
		-- if i try to lazyload this plugin, their default mappings conflict with copilot's default tab...
		-- it took way too long to figure that out
		-- use ^j and ^k instead
		keys = false,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "VeryLazy" },
		config = function(_, opts)
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- ref: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
			-- ghost text is off for cmp since we use copilot.vim, i like it more than copilot.lua
			opts.experimental.ghost_text = false
			opts.window = { completion = {}, documentation = {} }
			opts.window.completion.border = "solid"
			opts.window.documentation.border = "solid"
			opts.formatting.fields = { "abbr", "menu", "kind" }

			-- we can set Item here, but omitting noselect and setting preview in our completeopts is more robust
			-- because it will preselect the first item rather than the one sent by the LSP server.
			-- ref: https://github.com/hrsh7th/nvim-cmp/discussions/1670#discussioncomment-8406706
			opts.preselect = cmp.PreselectMode.None
			vim.opt.completeopt = "menu,menuone,noinsert,preview" -- noselect
			opts.completion.completeopt = table.concat(vim.opt.completeopt:get(), ",")
			opts.completion.autocomplete = {
				cmp.TriggerEvent.TextChanged,
				cmp.TriggerEvent.InsertEnter,
			}

			local has_words_before = function()
				cmp.unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end
			local has_words_after = function()
				return vim.api.nvim_get_current_line():sub(vim.fn.col("."), -1):match("%S") ~= nil

				-- could probably just check if cursor is at the end of the line with vim.fn.col(".") == vim.fn.col("$")
				-- but looking at the chars to ensure they're nonwhitespace is better i guess, hope not too slow
				-- cmp.unpack = unpack or table.unpack
				-- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				-- local current = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
				-- local chars_under_and_after_cursor = current:sub(col + 1, -1)
				-- return chars_under_and_after_cursor:match("%S") ~= nil
			end
			local cmp_next = function()
				-- see :h cmp.select_next_item
				if cmp.visible() then
					if #cmp.get_entries() == 1 then
						-- if there's one completion entry, tab will select and replace insert it
						cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
					else
						-- don't insert the text when selecting next item; ghost text is not shown
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					end
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					-- if there's words before when we press tab, invoke completion; autoselect it if there's only one entry
					cmp.complete()
					if #cmp.get_entries() == 1 then
						cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
					end
				else
					cmp.complete({
						reason = cmp.ContextReason.Manual,
					})
				end
			end
			local cmp_prev = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					cmp.abort()
					fallback()
				end
			end
			opts.mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete({ reason = cmp.ContextReason.Automatic }),
				["<C-e>"] = cmp.mapping(function(fallback)
					fallback()
				end, { "i", "s" }),
				["<C-c>"] = cmp.mapping.abort(),
				["<C-u>"] = cmp.mapping.scroll_docs(-4), -- up docs
				["<C-d>"] = cmp.mapping.scroll_docs(4), -- down docs
				["<C-k>"] = cmp.mapping(cmp_prev), -- using tab for copilot.vim is too convenient
				["<C-j>"] = cmp.mapping(cmp_next),
				-- i disabled the tab keys for luasnip because it broke things with copilot.vim
				-- i still want to use them though, but only if luasnip is active
				["<Tab>"] = cmp.mapping(function(fallback)
					if luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end),
				["<CR>"] = cmp.mapping({
					i = function(fallback)
						if cmp.visible() then
							-- if there's only one choice
							-- if #cmp.get_entries() == 1 then
							-- cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
							-- if has_words_after() then
							-- 	-- print("words after")
							-- 	-- very annoying to go back earlier in the line and edit it, and then press enter
							-- 	-- only to complete the text instead of inserting a newline, like in comments
							-- 	cmp.abort()
							-- 	fallback()
							if cmp.get_selected_entry() then
								-- print("selected entry")
								-- selected enetry seems to apply to both preselected entries and explicitly
								-- selected entries too, so we should use select true
								cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
							-- elseif cmp.get_active_entry() then
							-- 	print("active entry")
							-- 	-- active entry seems to mean it was explicitly selected so we should use select = false
							-- 	cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
							else
								cmp.abort()
								fallback()
							end
						else
							cmp.abort()
							fallback()
						end
					end,
				}),
				["<C-CR>"] = function()
					if cmp.visible() then
						-- force carriage return if we ever want to insert newline without confirming completion
						cmp.abort()
					end
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "i", true)
				end,
			})
			cmp.setup(opts)
		end,
	},
}
