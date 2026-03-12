-- mini.nvim bootstrap and plugin manager setup
local M = {}

M.branch = 'main'
M.packpath = vim.fn.stdpath('data') .. '/site'

function M.setup()
	local mini_path = M.packpath .. '/pack/deps/start/mini.nvim'

	if not vim.uv.fs_stat(mini_path) then
		print('Installing mini.nvim....')
		vim.fn.system({
			'git',
			'clone',
			'--filter=blob:none',
			'https://github.com/nvim-mini/mini.nvim',
			string.format('--branch=%s', M.branch),
			mini_path,
		})

		vim.cmd('packloadall! | helptags ALL')
		vim.cmd('echo "Installed `mini.nvim`" | redraw')
	end

	local ok, deps = pcall(require, 'mini.deps')
	if not ok then
		return false
	end

	-- See :help MiniDeps.config
	deps.setup({
		path = {
			package = M.packpath,
		},
	})

	deps.add({
		source = 'nvim-mini/mini.nvim',
		checkout = M.branch,
	})

	return true
end

return M
