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

			-- Disable semantic tokens for terraformls: terraform-ls returns invalid
			-- token lengths causing an infinite loop in str_utfindex on neovim nightly.
			-- https://github.com/neovim/neovim/issues/36257
			-- https://github.com/hashicorp/terraform-ls/issues/2094
			if client and client.name == 'terraformls' then
				client.server_capabilities.semanticTokensProvider = nil
			end

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
			source_func = 'omnifunc',
			auto_setup = false,
		},
		delay = { completion = 100, info = 100, signature = 50 },
	})

	-- Tab: trigger completion, or cycle through items, or insert a tab
	vim.keymap.set('i', '<Tab>', function()
		if vim.fn.pumvisible() == 1 then
			return '<C-n>'
		end
		local col = vim.fn.col('.') - 1
		if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
			return '<Tab>'
		elseif #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
			return '<C-x><C-o>'
		else
			return '<Tab>'
		end
	end, { expr = true, noremap = true })
	vim.keymap.set('i', '<S-Tab>', function()
		return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
	end, { expr = true, noremap = true })
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

	-- See :help MiniSnippets.config
	-- require('mini.snippets').setup({})
end

return M
