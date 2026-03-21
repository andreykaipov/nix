-- Colorscheme setup and terminal color sync
local M = {}
M.transparent = false

function M.setup(opts)
	opts = opts or {}
	MiniDeps.add('folke/tokyonight.nvim')
	MiniDeps.add('oxfist/night-owl.nvim')
	MiniDeps.add('EdenEast/nightfox.nvim')
	MiniDeps.add('olimorris/onedarkpro.nvim')
	require('onedarkpro').setup({ options = { cursorline = true } }) -- why is cursorline false by default???
	MiniDeps.add('projekt0n/github-nvim-theme')
	MiniDeps.add('andreykaipov/tmux-colorscheme-sync.nvim')
	MiniDeps.add('bluz71/vim-moonfly-colors')

	local theme = vim.g.user.theme
	local cs = theme.colorscheme
	local scheme_name, lighter_shade, black_bg = cs[1], cs[2], cs[3]
	local tmux = theme.tmux or {}
	local tmux_bg = tmux.bg or 'inactive'

	-- Setup tmux-colorscheme-sync BEFORE setting the colorscheme so its
	-- ColorScheme autocmd fires on the initial colorscheme set. In interactive
	-- mode UIEnter would catch it later, but in headless mode UIEnter never
	-- fires, so the cache would never be written.
	local tcs_config = require('tmux-colorscheme-sync.config')

	require('tmux-colorscheme-sync').setup({
		state_file = '~/.config/tmux/styles/nvim-colors.conf',
		tmux_source_file = '~/.config/tmux/styles/main.conf',
		lighter_shade = lighter_shade,
		manage_focus = false, -- we handle FocusLost/FocusGained ourselves below
	})

	-- Source tmux styles before the colorscheme is set. This repaints the
	-- tmux pane bg to prevent a black flash on first render. main.conf
	-- handles transparent vs opaque via %if @transparent.
	if vim.env.TMUX then
		vim.fn.system({ 'tmux', 'source-file', vim.fn.expand('~/.config/tmux/styles/main.conf') })
	end

	-- For randomhue, use a fixed seed so every nvim session gets the same hue.
	-- The seed file is written by the activation script at nix switch time, so
	-- colors change per switch. <leader>cc passes reseed=true to re-roll on demand.
	if scheme_name == 'randomhue' then
		if opts.reseed then
			math.randomseed(vim.loop.hrtime())
		else
			local seed_file = vim.fn.stdpath('data') .. '/color-seed'
			local ok, content = pcall(vim.fn.readfile, seed_file)
			local seed = ok and tonumber(content[1]) or tonumber(os.date('%Y%m%d'))
			math.randomseed(seed)
		end
		local hues = require('mini.hues')
		local base = hues.gen_random_base_colors()
		hues.setup({
			background = base.background,
			foreground = base.foreground,
			n_hues = 8,
			saturation = vim.o.background == 'dark' and 'medium' or 'high',
			accent = 'bg',
		})
		vim.g.colors_name = 'randomhue'
		-- mini.hues.setup() doesn't fire ColorScheme (it's not a real colorscheme),
		-- so fire it manually for tmux-colorscheme-sync and other autocmds.
		vim.cmd('doautocmd ColorScheme')
	else
		vim.cmd.colorscheme(scheme_name)
	end

	-- Force black background if requested
	if black_bg then
		local function apply_black_bg()
			for _, group in ipairs({ 'Normal', 'SignColumn', 'LineNr' }) do
				vim.api.nvim_set_hl(
					0,
					group,
					vim.tbl_extend('force', vim.api.nvim_get_hl(0, { name = group }),
						{ bg = '#000000' })
				)
			end
		end
		vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_black_bg })
		apply_black_bg()
	end

	-- -- Subtler diff overlay colors (mini.diff)
	-- vim.api.nvim_set_hl(0, 'MiniDiffOverAdd', { bg = '#1a2e1a' })
	-- vim.api.nvim_set_hl(0, 'MiniDiffOverChange', { bg = '#2a2e1a' })
	-- vim.api.nvim_set_hl(0, 'MiniDiffOverContext', { bg = '#1a1e2e' })
	-- vim.api.nvim_set_hl(0, 'MiniDiffOverDelete', { bg = '#2e1a1a' })

	-- Cursorline across the entire gutter (must be after colorscheme to avoid being overridden)
	vim.api.nvim_set_hl(0, 'CursorLineSign', { link = 'CursorLine' })
	vim.api.nvim_set_hl(0, 'CursorLineFold', { link = 'CursorLine' })
	vim.api.nvim_set_hl(0, 'CursorLineNr', { link = 'CursorLine' })

	-- Sync terminal background via OSC 11.
	-- tmux_bg: 'active' uses Normal bg; 'inactive' (default) uses dimmed bg.
	-- This way when nvim goes transparent on FocusLost, the terminal bg
	-- shows through as the chosen color — matching tmux.
	local function sync_terminal_bg()
		local mapping = tcs_config.get_color_mapping()
		local bg
		if tmux_bg == 'active' then
			bg = mapping.normal.bg
		else
			bg = mapping.normal_lighter.bg
		end
		if not bg or bg == 'default' then
			return
		end
		local osc = string.format('\027]11;%s\027\\', bg)
		if vim.env.TMUX then
			osc = string.format('\027Ptmux;\027%s\027\\', osc)
		end
		vim.fn.chansend(vim.v.stderr, osc)
	end

	-- Dim inactive splits using the same bg tmux uses for inactive panes
	local function dim_inactive_splits()
		local dim_bg = tcs_config.get_color_mapping().normal_lighter.bg
		if not dim_bg or dim_bg == 'default' then
			return
		end

		vim.api.nvim_set_hl(0, 'NormalNC', { bg = dim_bg })

		-- Transparent cursor highlight for FocusLost cursor hiding
		vim.api.nvim_set_hl(0, 'CursorHidden', { blend = 100, nocombine = true })

		-- NvimTree: match editor bg when active, dim when inactive.
		-- NvimTree maps Normal:NvimTreeNormal and NormalNC:NvimTreeNormalNC
		-- in its winhighlight.
		local normal_bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
		local normal_bg_hex = normal_bg and string.format('#%06x', normal_bg) or nil

		-- Hide window separator: fg matches Normal bg so the line is invisible.
		-- Must also set NvimTreeWinSeparator because some colorschemes (e.g.
		-- tokyonight) define it explicitly, overriding the global WinSeparator
		-- for the NvimTree window.
		vim.api.nvim_set_hl(0, 'WinSeparator', { fg = normal_bg, bg = dim_bg })
		vim.api.nvim_set_hl(0, 'NvimTreeWinSeparator', { link = 'WinSeparator' })

		-- LESSON: set_nvimtree_bg merges bg into the existing NvimTreeNormal hl
		-- instead of replacing it. This is critical because nvim-tree.lua sets
		-- fg='#ffffff' on NvimTreeNormal/NC, and nvim_set_hl({bg=x}) would clear fg.
		-- The tmux-colorscheme-sync plugin was also fixed to do the same merge
		-- for focus_lost_highlights entries.
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
				if not M.transparent and vim.bo.filetype == 'NvimTree' then
					apply_nvimtree_dim()
				end
			end,
		})

		-- Dim SignColumn and LineNr in inactive windows (some colorschemes give them their own bg)
		local sc_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
		vim.api.nvim_set_hl(0, 'SignColumnNC', vim.tbl_extend('force', sc_hl, { bg = dim_bg }))
		local ln_hl = vim.api.nvim_get_hl(0, { name = 'LineNr' })
		vim.api.nvim_set_hl(0, 'LineNrNC', vim.tbl_extend('force', ln_hl, { bg = dim_bg }))

		-- Dim mini.diff sign highlights so git gutter signs match the inactive bg
		local diff_sign_groups = { 'MiniDiffSignAdd', 'MiniDiffSignChange', 'MiniDiffSignDelete' }
		local function create_diff_nc_variants()
			for _, name in ipairs(diff_sign_groups) do
				local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
				hl.bg = nil
				vim.api.nvim_set_hl(0, name .. 'NC', hl)
			end
		end
		create_diff_nc_variants()

		local wh = 'Normal:NormalNC,SignColumn:SignColumnNC,LineNr:LineNrNC'
		    .. ',MiniDiffSignAdd:MiniDiffSignAddNC'
		    .. ',MiniDiffSignChange:MiniDiffSignChangeNC'
		    .. ',MiniDiffSignDelete:MiniDiffSignDeleteNC'
		local function is_our_wh(s)
			return s == '' or s == wh
		end
		local function set_inactive_wh(win)
			if vim.api.nvim_win_is_valid(win) and is_our_wh(vim.wo[win].winhighlight) then
				vim.wo[win].winhighlight = wh
			end
		end
		local function clear_active_wh(win)
			if vim.api.nvim_win_is_valid(win) and is_our_wh(vim.wo[win].winhighlight) then
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
			-- Bold the Explorer title when NvimTree is focused
			local title_hl = vim.api.nvim_get_hl(0, { name = 'BufferLineExplorerTitle' })
			title_hl.bold = nvimtree_active
			vim.api.nvim_set_hl(0, 'BufferLineExplorerTitle', title_hl)
			refresh_scrollview()
		end

		-- Recreate NC variants once mini.diff initializes (covers
		-- startup race where git.lua loads after colors.lua).
		vim.api.nvim_create_autocmd('User', {
			group = group,
			pattern = 'MiniDiffUpdated',
			once = true,
			callback = create_diff_nc_variants,
		})
		vim.api.nvim_create_autocmd({ 'WinEnter', 'WinLeave' }, {
			group = group,
			callback = function()
				if not M.transparent then
					resync_all_windows()
				end
			end,
		})
		-- On FocusLost, everything is inactive — force NvimTreeNormal to dim.
		-- LESSON: When switching to a tmux pane, the Neovim window stays current
		-- (no WinLeave fires), so the selected tab stays "selected" not "visible".
		-- We must manually dim BufferLineBufferSelected and BufferLineCloseButtonSelected
		-- fg/bold to match the visible tab style, then restore on FocusGained.
		local selected_fg_cache = nil
		local close_btn_fg_cache = nil
		vim.api.nvim_create_autocmd('FocusLost', {
			group = group,
			callback = function()
				if M.transparent then
					return
				end
				-- Hide cursor so tmux caches a cursorless frame.
				-- Restored on BufEnter in nvim-tree.lua.
				vim.o.guicursor = 'a:CursorHidden'
				-- Undraw indentscope — it only redraws on CursorMoved/TextChanged,
				-- so leaving to tmux (no WinLeave) leaves the solid line visible.
				MiniIndentscope.undraw()
				-- Set all highlight groups to dim_bg so the frame tmux
				-- caches is uniformly dimmed.
				vim.api.nvim_set_hl(0, 'Normal', { bg = dim_bg })
				vim.api.nvim_set_hl(0, 'NormalNC', { bg = dim_bg })
				vim.api.nvim_set_hl(0, 'LineNr', { fg = ln_hl.fg, bg = dim_bg })
				vim.api.nvim_set_hl(0, 'SignColumn', vim.tbl_extend('force', sc_hl, { bg = dim_bg }))
				vim.api.nvim_set_hl(0, 'SignColumnNC', vim.tbl_extend('force', sc_hl, { bg = dim_bg }))
				-- Dim ALL windows (including current) so tmux caches an
				-- all-dimmed frame. This prevents the flicker where tmux
				-- shows the old "active" window from the cached frame
				-- before FocusGained fires and moves the cursor.
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					set_inactive_wh(win)
				end
				set_nvimtree_bg(dim_bg)
				refresh_scrollview()
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
		-- The @nav_dir wincmd and highlight restore MUST be in a single callback
		-- to avoid an intermediate redraw between them (which causes flicker).
		vim.api.nvim_create_autocmd('FocusGained', {
			group = group,
			callback = function()
				-- 1. Move cursor to edge split if entering from tmux.
				-- Must happen first so resync highlights the correct window.
				require('custom.navigation').apply_tmux_nav_dir()
				if M.transparent then
					return
				end
				-- 2. Restore all highlight groups in one shot.
				local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
				normal_hl.bg = normal_bg
				vim.api.nvim_set_hl(0, 'Normal', normal_hl)
				vim.api.nvim_set_hl(0, 'NormalNC', { bg = dim_bg })
				vim.api.nvim_set_hl(0, 'LineNr', ln_hl)
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
				-- 3. Resync winhighlight for all windows now that cursor + hls are correct.
				resync_all_windows()
				-- 4. The noautocmd wincmd suppressed BufEnter, so fire it
				-- for the current buffer to let other handlers run
				-- (e.g. nvim-tree.lua's guicursor restore).
				vim.api.nvim_exec_autocmds('BufEnter', { buffer = 0 })
				-- 5. Redraw indentscope (undone on FocusLost).
				-- CursorMoved doesn't fire on FocusGained alone.
				vim.api.nvim_exec_autocmds('CursorMoved', { buffer = 0 })
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

	-- Toggle nvim transparency (independent of wezterm/tmux toggle)
	local saved_hls = {}
	local transparent_groups = {
		'Normal',
		'NormalNC',
		'LineNr',
		'SignColumnNC',
		'LineNrNC',
		'NormalFloat',
		'EndOfBuffer',
		'WinSeparator',
		'StatusLine',
		'StatusLineNC',
		'TabLineFill',
		'NvimTreeNormal',
		'NvimTreeNormalNC',
		'BufferLineOffsetSeparator',
	}
	vim.keymap.set('n', '<leader>u', function()
		M.transparent = not M.transparent
		if M.transparent then
			for _, name in ipairs(transparent_groups) do
				saved_hls[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
				local hl = vim.tbl_extend('force', saved_hls[name], { bg = 'NONE' })
				vim.api.nvim_set_hl(0, name, hl)
			end
			vim.notify('Transparency on', vim.log.levels.INFO)
		else
			for _, name in ipairs(transparent_groups) do
				if saved_hls[name] then
					vim.api.nvim_set_hl(0, name, saved_hls[name])
				end
			end
			saved_hls = {}
			vim.notify('Transparency off', vim.log.levels.INFO)
		end
	end, { desc = 'Toggle transparency' })
end

return M
