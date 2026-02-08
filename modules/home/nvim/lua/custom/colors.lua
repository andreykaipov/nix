-- Colorscheme setup and terminal color sync
local M = {}

function M.setup()
	MiniDeps.add('folke/tokyonight.nvim')
	MiniDeps.add('oxfist/night-owl.nvim')
	MiniDeps.add('EdenEast/nightfox.nvim')
	MiniDeps.add('olimorris/onedarkpro.nvim')
	MiniDeps.add('projekt0n/github-nvim-theme')
	MiniDeps.add('andreykaipov/tmux-colorscheme-sync.nvim')

	-- require('night-owl').setup()
	-- require('nightfox').setup({})
	-- https://github.com/projekt0n/github-nvim-theme?tab=readme-ov-file#supported-colorschemes--comparisons
	require('github-theme').setup({
		options = {
			darken = {
				sidebars = { enable = false }, -- we handle NvimTree bg in dim_inactive_splits
			},
		},
	})
	-- vim.cmd.colorscheme('night-owl')
	-- vim.cmd.colorscheme('github_dark_default')
	-- vim.cmd.colorscheme('minisummer')
	-- vim.cmd.colorscheme('miniautumn')
	vim.cmd.colorscheme('github_dark')

	-- Cursorline across the entire gutter (must be after colorscheme to avoid being overridden)
	vim.api.nvim_set_hl(0, 'CursorLineSign', { link = 'CursorLine' })
	vim.api.nvim_set_hl(0, 'CursorLineFold', { link = 'CursorLine' })
	vim.api.nvim_set_hl(0, 'CursorLineNr', { link = 'CursorLine' })

	-- Sync tmux colors to match Neovim's colorscheme
	local tcs_config = require('tmux-colorscheme-sync.config')
	require('tmux-colorscheme-sync').setup({
		cache_file = '~/.local/state/tmux/colorscheme-cache.conf',
		tmux_source_file = '~/.config/tmux/styles.conf', -- re-source styles when colors change
		lighter_shade = 30,                -- inactive pane bg: percent lighter than active, effectively the color of the entire terminal
		-- Extra highlight groups to set to dim_bg on FocusLost (avoids flicker
		-- vs bg='none' since Neovim can redraw before FocusGained fires)
		focus_lost_highlights = {
			'SignColumn',
			'SignColumnNC',
			'NvimTreeNormal',
			'NvimTreeNormalNC',
		},
	})

	-- Sync terminal background to the inactive pane color via OSC 11.
	-- This way when nvim goes transparent on FocusLost, the terminal bg
	-- shows through as the dimmed inactive color — matching tmux.
	-- Also cache the color so wezterm can read it on cold start.
	local bg_cache_path = vim.fn.expand('~/.local/state/wezterm/bg-color.txt')
	local function sync_terminal_bg()
		local dim_bg = tcs_config.get_color_mapping().normal_lighter.bg
		if not dim_bg or dim_bg == 'default' then
			return
		end
		local osc = string.format('\027]11;%s\027\\', dim_bg)
		if vim.env.TMUX then
			osc = string.format('\027Ptmux;\027%s\027\\', osc)
		end
		vim.fn.chansend(vim.v.stderr, osc)
		-- Cache for wezterm cold start
		local dir = bg_cache_path:match('(.*/)')
		if dir then
			os.execute('mkdir -p ' .. dir)
		end
		local f = io.open(bg_cache_path, 'w')
		if f then
			f:write(dim_bg)
			f:close()
		end
	end

	-- Dim inactive splits using the same bg tmux uses for inactive panes
	local function dim_inactive_splits()
		local dim_bg = tcs_config.get_color_mapping().normal_lighter.bg
		if not dim_bg or dim_bg == 'default' then
			return
		end

		vim.api.nvim_set_hl(0, 'NormalNC', { bg = dim_bg })

		-- NvimTree: match editor bg when active, dim when inactive.
		-- NvimTree maps Normal:NvimTreeNormal and NormalNC:NvimTreeNormalNC
		-- in its winhighlight.
		local normal_bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
		local normal_bg_hex = normal_bg and string.format('#%06x', normal_bg) or nil
		local function set_nvimtree_bg(bg)
			local hl = vim.api.nvim_get_hl(0, { name = 'NvimTreeNormal' })
			hl.bg = bg
			vim.api.nvim_set_hl(0, 'NvimTreeNormal', hl)
		end
		local function apply_nvimtree_dim()
			set_nvimtree_bg(normal_bg_hex)
			local nc = vim.api.nvim_get_hl(0, { name = 'NvimTreeNormalNC' })
			nc.bg = dim_bg
			vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', nc)
		end
		-- Apply immediately (covers colorscheme changes)
		apply_nvimtree_dim()
		-- Re-apply on BufWinEnter for NvimTree since it resets winhighlight/highlights
		vim.api.nvim_create_autocmd('BufWinEnter', {
			pattern = '*',
			callback = function()
				if vim.bo.filetype == 'NvimTree' then
					apply_nvimtree_dim()
				end
			end,
		})

		-- Dim SignColumn in inactive windows (some colorschemes give it its own bg)
		local sc_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
		vim.api.nvim_set_hl(0, 'SignColumnNC', vim.tbl_extend('force', sc_hl, { bg = dim_bg }))

		local wh = 'Normal:NormalNC,SignColumn:SignColumnNC'
		local function set_inactive_wh(win)
			if vim.api.nvim_win_is_valid(win) and vim.wo[win].winhighlight == '' then
				vim.wo[win].winhighlight = wh
			end
		end
		local function clear_active_wh(win)
			if vim.api.nvim_win_is_valid(win) and vim.wo[win].winhighlight == wh then
				vim.wo[win].winhighlight = ''
			end
		end
		-- Refresh scrollview after winhighlight changes so its floats
		-- pick up the correct bg from the base window immediately.
		local function refresh_scrollview()
			vim.cmd('silent! ScrollViewRefresh')
		end

		local group = vim.api.nvim_create_augroup('DimInactiveSplits', { clear = true })

		-- Resync all windows and NvimTree title highlight.
		local function resync_all_windows()
			local cur = vim.api.nvim_get_current_win()
			local nvimtree_active = false
			if vim.api.nvim_win_is_valid(cur) and vim.bo[vim.api.nvim_win_get_buf(cur)].filetype == 'NvimTree' then
				nvimtree_active = true
			end
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if win == cur then
					clear_active_wh(win)
				else
					set_inactive_wh(win)
				end
			end
			-- Update NvimTreeNormal so the bufferline offset title bg matches
			set_nvimtree_bg(nvimtree_active and normal_bg_hex or dim_bg)
			refresh_scrollview()
		end

		vim.api.nvim_create_autocmd('User', {
			group = group,
			pattern = 'DimInactiveSplitsResync',
			callback = resync_all_windows,
		})
		vim.api.nvim_create_autocmd({ 'WinEnter', 'WinLeave' }, {
			group = group,
			callback = resync_all_windows,
		})
		-- On FocusLost, everything is inactive — force NvimTreeNormal to dim.
		-- Also dim selected tab fg so it matches visible tab behavior.
		local selected_fg_cache = nil
		local close_btn_fg_cache = nil
		vim.api.nvim_create_autocmd('FocusLost', {
			group = group,
			callback = function()
				resync_all_windows()
				set_nvimtree_bg(dim_bg)
				local vis = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferVisible' })
				local sel = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected' })
				if sel.fg then
					selected_fg_cache = sel.fg
					sel.fg = vis.fg
					sel.bold = false
					vim.api.nvim_set_hl(0, 'BufferLineBufferSelected', sel)
				end
				local close_sel = vim.api.nvim_get_hl(0, { name = 'BufferLineCloseButtonSelected' })
				local close_vis = vim.api.nvim_get_hl(0, { name = 'BufferLineCloseButtonVisible' })
				if close_sel.fg then
					close_btn_fg_cache = close_sel.fg
					close_sel.fg = close_vis.fg
					vim.api.nvim_set_hl(0, 'BufferLineCloseButtonSelected', close_sel)
				end
			end,
		})
		-- On FocusGained, also restore highlight groups the plugin may have changed.
		vim.api.nvim_create_autocmd('FocusGained', {
			group = group,
			callback = function()
				vim.api.nvim_set_hl(0, 'NormalNC', { bg = dim_bg })
				vim.api.nvim_set_hl(0, 'SignColumn', sc_hl)
				vim.api.nvim_set_hl(0, 'SignColumnNC', vim.tbl_extend('force', sc_hl, { bg = dim_bg }))
				apply_nvimtree_dim()
				if selected_fg_cache then
					local sel = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected' })
					sel.fg = selected_fg_cache
					sel.bold = true
					vim.api.nvim_set_hl(0, 'BufferLineBufferSelected', sel)
					selected_fg_cache = nil
				end
				if close_btn_fg_cache then
					local close_sel = vim.api.nvim_get_hl(0,
						{ name = 'BufferLineCloseButtonSelected' })
					close_sel.fg = close_btn_fg_cache
					vim.api.nvim_set_hl(0, 'BufferLineCloseButtonSelected', close_sel)
					close_btn_fg_cache = nil
				end
				resync_all_windows()
			end,
		})

		local cur = vim.api.nvim_get_current_win()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if win ~= cur then
				set_inactive_wh(win)
			end
		end
	end

	local function apply_highlights()
		sync_terminal_bg()
		dim_inactive_splits()
	end

	vim.api.nvim_create_autocmd('ColorScheme', {
		group = vim.g.user.event,
		callback = apply_highlights,
	})
	apply_highlights()
end

return M
