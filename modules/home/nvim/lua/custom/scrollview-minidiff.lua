-- scrollview sign group for mini.diff (same pattern as scrollview's gitsigns contrib)
local api = vim.api
local fn = vim.fn
local scrollview = require('scrollview')

local M = {}

function M.setup(config)
	config = config or {}

	local defaults = {
		enabled = true,
		add_priority = 90,
		change_priority = 90,
		delete_priority = 90,
		add_symbol = '+',
		change_symbol = '~',
		delete_symbol = '-',
	}

	-- Use mini.diff's own sign highlights
	local cfg_add_hl = 'MiniDiffSignAdd'
	local cfg_change_hl = 'MiniDiffSignChange'
	local cfg_delete_hl = 'MiniDiffSignDelete'

	for key, val in pairs(defaults) do
		if config[key] == nil then
			config[key] = val
		end
	end

	local group = 'minidiff'
	scrollview.register_sign_group(group)

	local add = scrollview.register_sign_spec({
		extend = true,
		group = group,
		highlight = cfg_add_hl,
		priority = config.add_priority,
		symbol = config.add_symbol,
		variant = 'add',
	}).name

	local change = scrollview.register_sign_spec({
		extend = true,
		group = group,
		highlight = cfg_change_hl,
		priority = config.change_priority,
		symbol = config.change_symbol,
		variant = 'change',
	}).name

	local delete = scrollview.register_sign_spec({
		extend = true,
		group = group,
		highlight = cfg_delete_hl,
		priority = config.delete_priority,
		symbol = config.delete_symbol,
		variant = 'delete',
	}).name

	scrollview.set_sign_group_state(group, config.enabled)

	local function refresh()
		if not scrollview.is_sign_group_active(group) then
			return
		end
		for _, tabpage in ipairs(api.nvim_list_tabpages()) do
			for _, winid in ipairs(api.nvim_tabpage_list_wins(tabpage)) do
				local bufnr = api.nvim_win_get_buf(winid)
				local ok, summary = pcall(vim.b.__get, bufnr, 'minidiff_summary')
				if not ok then
					summary = nil
				end
				-- mini.diff exposes hunks via MiniDiff.get_buf_data()
				local lines_add = {}
				local lines_change = {}
				local lines_delete = {}
				local buf_data = nil
				pcall(function()
					buf_data = MiniDiff.get_buf_data(bufnr)
				end)
				if buf_data and buf_data.hunks then
					for _, hunk in ipairs(buf_data.hunks) do
						-- hunk fields: buf_start, buf_count, ref_start, ref_count
						if hunk.ref_count == 0 then
							-- pure add
							for line = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
								table.insert(lines_add, line)
							end
						elseif hunk.buf_count == 0 then
							-- pure delete
							table.insert(lines_delete, hunk.buf_start)
						else
							-- change: changed lines, then any extra added lines
							local changed = math.min(hunk.buf_count, hunk.ref_count)
							for line = hunk.buf_start, hunk.buf_start + changed - 1 do
								table.insert(lines_change, line)
							end
							if hunk.buf_count > hunk.ref_count then
								for line = hunk.buf_start + changed, hunk.buf_start + hunk.buf_count - 1 do
									table.insert(lines_add, line)
								end
							end
						end
					end
				end
				vim.b[bufnr][add] = lines_add
				vim.b[bufnr][change] = lines_change
				vim.b[bufnr][delete] = lines_delete
			end
		end
		vim.cmd('silent! ScrollViewRefresh')
	end

	-- Refresh on events that mini.diff updates on
	api.nvim_create_autocmd('User', {
		pattern = 'MiniDiffUpdated',
		callback = refresh,
	})
	-- Also refresh on buffer changes as a fallback
	api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
		callback = function()
			vim.defer_fn(refresh, 100)
		end,
	})
end

return M
