local cmp = require("cmp")
local luasnip = require("luasnip")

local M = {}

M.has_words_before = function()
	cmp.unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
M.cmp_next = function(fallback)
	-- see :h cmp.select_next_item
	if cmp.visible() then
		if #cmp.get_entries() == 1 then
			-- if there's one completion entry, tab will select and replace insert it
			cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
		else
			-- don't insert the text when selecting next item
			-- ghost text is not shown
			cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
		end
	elseif luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	elseif M.has_words_before() then
		-- if there's words before when we press tab, invoke completion
		-- autoselect it if there's only one entry
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
M.cmp_prev = function(fallback)
	if cmp.visible() then
		cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
	elseif luasnip.jumpable(-1) then
		luasnip.jump(-1)
	else
		cmp.abort()
		fallback()
		cmp.abort()
	end
end
M.cmp_opts = function()
	local defaults = require("cmp.config.default")()
	return {
		preselect = cmp.PreselectMode.None,
		completion = {
			completeopt = table.concat(vim.opt.completeopt:get(), ","),
			keyword_length = 1,
			autocomplete = {
				cmp.TriggerEvent.TextChanged,
				cmp.TriggerEvent.InsertEnter,
			},
		},
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		window = {
			completion = {
				winhighlight = "Normal:Pmenu,CursorLine:CmpCursorLine,Search:None",
				col_offset = -3,
				side_padding = 0,
				scrollbar = true,
			},
			documentation = {
				border = "solid",
				winhighlight = "Normal:CmpDoc,FloatBorder:CmpDoc,Search:None",
				max_width = 80,
				max_height = 12,
			},
		},
		sources = cmp.config.sources({
			-- { name = "copilot" },
			{ name = "nvim_lsp" },
			{ name = "nvim_lsp_signature_help" },
			{ name = "luasnip" },
			{ name = "emoji" },
			{ name = "path" },
		}, {
			{ name = "buffer" },
		}),
		formatting = {
			fields = { "abbr", "menu", "kind" },
			format = function(_, item)
				local icons = require("lazyvim.config").icons.kinds
				if icons[item.kind] then
					item.kind = icons[item.kind] .. item.kind
				end
				return item
			end,
		},
		experimental = {
			-- ghost text is off for cmp since we reserve ghost text for copilot.vim.
			-- we use both the original copilot.vim and copilot-cmp because the former works on empty lines,
			-- while copilot-cmp offers copilot suggestions in cmp. 🤷
			ghost_text = false,
		},
		sorting = defaults.sorting,
		mapping = cmp.mapping.preset.insert({
			["<C-Space>"] = cmp.mapping.complete({ reason = cmp.ContextReason.Automatic }),
			["<C-e>"] = cmp.mapping(function(fallback)
				fallback()
			end, { "i", "s" }),
			["<C-c>"] = cmp.mapping.abort(),
			["<C-u>"] = cmp.mapping.scroll_docs(-4), -- up docs
			["<C-d>"] = cmp.mapping.scroll_docs(4), -- down docs
			["<C-k>"] = cmp.mapping(M.cmp_prev), -- using tab for copilot.vim is too convenient
			["<C-j>"] = cmp.mapping(M.cmp_next),
			["<CR>"] = cmp.mapping({
				i = function(fallback)
					if cmp.visible() then
						-- if #cmp.get_entries() == 1 then
						-- 	-- if there's only one choice
						-- 	cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
						-- elseif cmp.get_active_entry() then
						if cmp.get_active_entry() then
							-- if we're hovering over a completion choice
							-- select = false confirms only explicitly selected items
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
						else
							cmp.abort()
							fallback()
							cmp.abort()
						end
					else
						cmp.abort()
						fallback()
						cmp.abort()
					end
				end,
			}),
			["<C-CR>"] = function(fallback)
				if cmp.visible() then
					-- force carriage return
					-- this is useful for when we want to insert a newline without confirming the completion
					cmp.abort()
				end
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "i", true)
			end,
		}),
	}
end

return M
