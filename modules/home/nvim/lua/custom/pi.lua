-- Pi coding agent + sidekick.nvim integration
local M = {}

function M.setup()
	MiniDeps.add('folke/sidekick.nvim')

	require('sidekick').setup({
		nes = { enabled = false },
		cli = {
			watch = true,
			win = {
				layout = 'right',
				split = { width = 0 },
			},
			mux = {
				backend = 'tmux',
				enabled = true,
				create = 'terminal',
			},
		},
	})

	vim.keymap.set({ 'n', 't' }, '<leader>oo', function()
		require('sidekick.cli').toggle({ name = 'pi', focus = true })
	end, { desc = 'Toggle pi' })

	vim.keymap.set({ 'n', 'x' }, '<leader>og', function()
		require('sidekick.cli').send({ msg = '{this}' })
	end, { desc = 'Send to pi' })

	vim.keymap.set({ 'n', 'x' }, '<leader>of', function()
		require('sidekick.cli').send({ msg = '{file}' })
	end, { desc = 'Send file to pi' })

	vim.keymap.set({ 'n', 'x' }, '<leader>op', function()
		require('sidekick.cli').prompt()
	end, { desc = 'Pi prompt' })

	vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
		require('sidekick.cli').select({ filter = { installed = true } })
	end, { desc = 'Select CLI tool' })

	vim.keymap.set({ 'n' }, '<leader>od', function()
		require('sidekick.cli').close()
	end, { desc = 'Detach CLI session' })

	-- Re-generate pi's auto theme from the tmux colorscheme cache.
	-- Pi hot-reloads the theme file automatically.
	local function sync_pi_theme()
		local cache = vim.fn.expand('~/.local/state/tmux/colorscheme-cache.conf')
		local ok, lines = pcall(vim.fn.readfile, cache)
		if not ok then return end
		local colors = {}
		for _, line in ipairs(lines) do
			local key, val = line:match("set %-g @nvim_color_(%S+)%s+'([^']+)'")
			if key then colors[key] = val end
		end
		if not colors.normal_bg then return end

		local theme_path = vim.fn.expand('~/.pi/agent/themes/auto.json')
		local existing = vim.fn.filereadable(theme_path) == 1
			and vim.fn.json_decode(vim.fn.readfile(theme_path))
			or nil
		if existing and existing.vars and existing.vars.lighterBg == colors.normal_lighter_bg then
			return
		end
		if existing then
			existing.vars.bg = colors.normal_bg
			existing.vars.lighterBg = colors.normal_lighter_bg or colors.normal_bg
			existing.vars.darkerBg = colors.normal_darker_bg or colors.normal_bg
			existing.vars.fg = colors.normal_fg or ''
			vim.fn.writefile(
				vim.split(vim.fn.json_encode(existing), '\n'),
				theme_path
			)
		end
	end

	-- Run on colorscheme change (200ms delay for tmux-colorscheme-sync to write first)
	vim.api.nvim_create_autocmd('ColorScheme', {
		callback = function()
			vim.defer_fn(sync_pi_theme, 200)
		end,
	})

	-- Run immediately on startup (cache already exists from previous session)
	sync_pi_theme()
end

return M
