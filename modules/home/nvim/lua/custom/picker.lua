-- Fuzzy finder: mini.pick
local M = {}

function M.setup()
	-- See :help MiniExtra
	-- require('mini.extra').setup({})

	-- See :help MiniPick.config
	require('mini.pick').setup({
		mappings = {
			move_down = '<C-j>',
			move_up = '<C-k>',
		},
	})

	-- Allow Cmd+V (terminal paste) to work in mini.pick
	local orig_paste = vim.paste
	vim.paste = function(lines, phase)
		if not MiniPick.is_picker_active() then
			return orig_paste(lines, phase)
		end
		local text = table.concat(lines, ''):gsub('[\n\t]', ' ')
		local query = MiniPick.get_picker_query() or {}
		for i = 1, vim.fn.strchars(text) do
			table.insert(query, vim.fn.strcharpart(text, i - 1, 1))
		end
		MiniPick.set_picker_query(query)
	end

	-- See available pickers
	-- :help MiniPick.builtin
	-- :help MiniExtra.pickers
	vim.keymap.set('n', '<leader>?', '<cmd>Pick oldfiles<cr>', { desc = 'Search file history' })
	vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', { desc = 'Search open files' })
	vim.keymap.set('n', '<leader>ff', function()
		require('mini.pick').builtin.cli({
			command = { 'rg', '--files', '--no-ignore', '--hidden', '--glob', '!.git', '--color=never' },
		})
	end, { desc = 'Search all files' })
	vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Search in project' })

	-- Combined file + grep picker: searches both filenames and file contents
	local last_query = {}
	local function search_all()
		local pick = require('mini.pick')
		local cwd = vim.fn.getcwd()
		local rg_base = '--no-ignore --hidden --glob !.git --color=never'
		local sys = { kill = function() end }

		local match = function(_, _, query)
			sys:kill()
			last_query = query
			local querytick = pick.get_querytick()
			local q = table.concat(query)
			if #q == 0 then
				return pick.set_picker_items({}, { do_match = false, querytick = querytick })
			end

			local case = vim.o.ignorecase and (vim.o.smartcase and '--smart-case' or '--ignore-case') or
			'--case-sensitive'
			local escaped = q:gsub("'", "'\\''")
			local cmd = {
				'sh',
				'-c',
				string.format(
					"rg --files %s | grep -i '%s'; rg --column --line-number --no-heading --field-match-separator '\\x00' %s %s -- '%s'",
					rg_base,
					escaped,
					rg_base,
					case,
					escaped
				),
			}

			sys = pick.set_picker_items_from_cli(cmd, {
				set_items_opts = { do_match = false, querytick = querytick },
				spawn_opts = { cwd = cwd },
			})
		end

		local show = pick.config.source.show
		    or function(buf_id, items, query)
			    pick.default_show(buf_id, items, query, { show_icons = true })
		    end

		pick.start({
			source = {
				name = 'Search files and contents',
				items = {},
				match = match,
				show = show,
			},
		})
		-- set_picker_query must be called after start() opens the picker
	end

	local function search_all_restore()
		local saved = vim.deepcopy(last_query)
		vim.schedule(function()
			if #saved > 0 then
				require('mini.pick').set_picker_query(saved)
			end
		end)
		search_all()
	end
	vim.keymap.set('n', '<leader>fa', search_all, { desc = 'Search files and contents' })
	vim.keymap.set('n', '<F4>', search_all_restore, { desc = 'Search files and contents (Cmd+Shift+F)' })
	vim.keymap.set('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', { desc = 'Search diagnostics' })
	vim.keymap.set('n', '<leader>fs', '<cmd>Pick buf_lines<cr>', { desc = 'Buffer local search' })
end

return M
