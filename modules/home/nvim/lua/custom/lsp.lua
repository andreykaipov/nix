-- LSP, completion, formatting, and diagnostics
local M = {}

function M.setup()
	MiniDeps.add('neovim/nvim-lspconfig')
	MiniDeps.add({
		source = 'nvimtools/none-ls.nvim',
		depends = { 'nvim-lua/plenary.nvim' },
	})

	-- https://neovim.io/doc/user/lsp.html#lsp-attach
	vim.api.nvim_create_autocmd('LspAttach', {
		desc = 'LSP actions',
		group = vim.g.user.event,
		callback = function(event)
			local opts = { buffer = event.buf }
			vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
			vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
			vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
			vim.keymap.set({ 'n', 'v', 'x' }, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
			vim.keymap.set({ 'n', 'v' }, 'N', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)

			local id = vim.tbl_get(event, 'data', 'client_id')
			local client = id and vim.lsp.get_client_by_id(id)

			if client and client:supports_method('textDocument/completion') then
				vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
			end

			vim.o.updatetime = 500
			vim.api.nvim_create_autocmd('CursorHold', {
				group = vim.g.user.event,
				buffer = event.buf,
				callback = function()
					-- vim.schedule(function()
						vim.diagnostic.open_float({
							scope = 'line',
							focus = false,
						})
					-- end)
				end,
			})

			if
				not client:supports_method('textDocument/willSaveWaitUntil')
				and client:supports_method('textDocument/formatting')
			then
				vim.api.nvim_create_autocmd('BufWritePre', {
					group = vim.g.user.event,
					buffer = event.buf,
					callback = function()
						vim.lsp.buf.format({
							bufnr = event.buf,
							id = event.data.id,
							timeout_ms = 1000,
						})
					end,
				})
			end
		end,
	})

	-- See :help MiniCompletion.config
	require('mini.completion').setup({
		lsp_completion = {
			source_func = 'completefunc',
			auto_setup = false,
		},
	})
	vim.keymap.set('i', '<C-j>', function()
		return vim.fn.pumvisible() == 1 and '<C-n>' or '<C-j>'
	end, { expr = true, noremap = true })
	vim.keymap.set('i', '<C-k>', function()
		return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-k>'
	end, { expr = true, noremap = true })
	vim.keymap.set('i', '<CR>', function()
		return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
	end, { expr = true, noremap = true })

	local nls = require('null-ls')
	nls.setup({
		sources = {
			nls.builtins.formatting.stylua,
			nls.builtins.formatting.terraform_fmt.with({
				filetypes = { 'terraform', 'tf', 'terraform-vars', 'hcl' },
			}),
			nls.builtins.diagnostics.terraform_validate.with({
				filetypes = { 'terraform', 'tf', 'terraform-vars', 'hcl' },
			}),
		},
	})

	-- Enable LSP servers
	vim.lsp.enable('lua_ls')
	vim.lsp.enable('gopls')
	vim.lsp.enable('golangci_lint_ls')
	vim.lsp.enable('terraformls')
	vim.lsp.config('nixd', {
		settings = {
			formatting = {
				command = 'nixfmt',
			},
		},
	})
	vim.lsp.enable('nixd')
	vim.lsp.enable('bashls')
	vim.lsp.enable('yamlls')
	vim.lsp.enable('jsonls')
end

return M
