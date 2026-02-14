-- nvim-tree + bufferline setup with persistent width across file opens and toggles
local M = {}

function M.setup()
	MiniDeps.add('nvim-tree/nvim-tree.lua')
	MiniDeps.add('akinsho/bufferline.nvim')

	local width_cache = vim.fn.stdpath('cache') .. '/nvim-tree-width'
	local function load_width()
		local f = io.open(width_cache, 'r')
		if f then
			local w = tonumber(f:read('*a'))
			f:close()
			if w and w > 0 then
				return w
			end
		end
		return vim.g.user.sidebar_width or 30
	end
	local function save_width(w)
		-- Don't cache unreasonable widths (max half the nvim/tmux pane)
		local max_width = math.floor(vim.o.columns * 0.5)
		if w < 10 or w > max_width then
			return
		end
		local f = io.open(width_cache, 'w')
		if f then
			f:write(tostring(w))
			f:close()
		end
	end
	local default_width = vim.g.user.sidebar_width or 30
	local nvim_tree_width = math.min(load_width(), math.max(default_width, math.floor(vim.o.columns * 0.5)))

	require('nvim-tree').setup({
		on_attach = function(bufnr)
			local api = require('nvim-tree.api')
			api.config.mappings.default_on_attach(bufnr)
			-- Single click to open files/folders (like VS Code)
			vim.keymap.set('n', '<LeftRelease>', api.node.open.edit, {
				buffer = bufnr,
				noremap = true,
				silent = true,
				desc = 'Open',
			})
			-- Middle click in NvimTree: position cursor then open (like left click)
			vim.keymap.set('n', '<MiddleMouse>', '<LeftMouse>', {
				buffer = bufnr,
				noremap = true,
				silent = true,
			})
			vim.keymap.set('n', '<MiddleRelease>', '<LeftRelease>', {
				buffer = bufnr,
				noremap = true,
				silent = true,
			})
			-- Open file in buffer but keep focus on the tree
			local function add_file_to_buffer()
				local node = api.tree.get_node_under_cursor()
				if node and node.type == 'file' then
					vim.cmd('badd ' .. vim.fn.fnameescape(node.absolute_path))
					vim.cmd('BufferLineSortByDirectory')
				else
					api.node.open.edit()
				end
			end
			vim.keymap.set('n', 'o', add_file_to_buffer, { buffer = bufnr, noremap = true, silent = true, desc = 'Add file to buffer' })
			vim.keymap.set('n', '<Tab>', function()
				local node = api.tree.get_node_under_cursor()
				if node and node.type == 'file' then
					-- Find the first non-NvimTree window and display the file there
					local tree_win = vim.api.nvim_get_current_win()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if win ~= tree_win and vim.api.nvim_win_is_valid(win) then
							vim.api.nvim_win_set_buf(win, vim.fn.bufadd(node.absolute_path))
							vim.bo[vim.fn.bufadd(node.absolute_path)].buflisted = true
							break
						end
					end
					vim.cmd('BufferLineSortByDirectory')
				else
					api.node.open.edit()
				end
			end, { buffer = bufnr, noremap = true, silent = true, desc = 'Open file in pane (keep focus on tree)' })
			-- Open all marked files, or current file if none marked
			vim.keymap.set('n', 'O', function()
				local marks = api.marks.list()
				if #marks == 0 then
					api.node.open.edit()
					return
				end
				for _, node in ipairs(marks) do
					if node.type == 'file' then
						vim.cmd('badd ' .. vim.fn.fnameescape(node.absolute_path))
					end
				end
				api.marks.clear()
				vim.cmd('BufferLineSortByDirectory')
			end, { buffer = bufnr, noremap = true, silent = true, desc = 'Open all marked files' })
		end,
		actions = {
			open_file = {
				resize_window = false,
			},
		},
		update_focused_file = { enable = true },
		git = { enable = true, show_on_open_dirs = true },
		filters = { git_ignored = false },
		renderer = {
			indent_width = 1,
			highlight_git = 'name',
			icons = {
				padding = ' ',
				git_placement = 'right_align',
				glyphs = {
					git = {
						unstaged = 'M',
						staged = 'S',
						unmerged = '!',
						renamed = 'R',
						untracked = 'U',
						deleted = 'D',
						ignored = '◌',
					},
				},
			},
		},
		view = {
			signcolumn = 'no',
			width = nvim_tree_width,
		},
	})

	-- NvimTree git status colors
	vim.api.nvim_set_hl(0, 'NvimTreeGitNewIcon', { fg = '#98c379' })       -- untracked: green
	vim.api.nvim_set_hl(0, 'NvimTreeGitDirtyIcon', { fg = '#e5c07b' })     -- modified: yellow
	vim.api.nvim_set_hl(0, 'NvimTreeGitIgnoredIcon', { fg = '#5c6370' })   -- ignored: gray
	vim.api.nvim_set_hl(0, 'NvimTreeGitFileNewHL', { fg = '#98c379' })     -- untracked filename
	vim.api.nvim_set_hl(0, 'NvimTreeGitFileDirtyHL', { fg = '#e5c07b' })   -- modified filename
	vim.api.nvim_set_hl(0, 'NvimTreeGitFileIgnoredHL', { fg = '#5c6370' }) -- ignored filename
	vim.api.nvim_set_hl(0, 'NvimTreeGitStagedIcon', { fg = '#98c379' })    -- staged: green
	vim.api.nvim_set_hl(0, 'NvimTreeGitMergeIcon', { fg = '#e06c75' })     -- merge conflict: red
	vim.api.nvim_set_hl(0, 'NvimTreeGitDeletedIcon', { fg = '#e06c75' })   -- deleted: red
	vim.api.nvim_set_hl(0, 'NvimTreeGitRenamedIcon', { fg = '#98c379' })   -- renamed: green
	-- Clean / non-git files: white
	-- IMPORTANT: Set fg explicitly on both NvimTreeNormal AND NvimTreeNormalNC.
	-- colors.lua dynamically changes their bg (for dim/focus), and nvim_set_hl
	-- clears any attributes not specified. set_nvimtree_bg() in colors.lua merges
	-- bg into the existing hl to preserve fg, but NvimTreeNormalNC must have fg
	-- set here first or there's nothing to preserve. Don't use tbl_extend on the
	-- existing hl — it can inherit unwanted attrs like bold from the colorscheme.
	vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = vim.api.nvim_get_hl(0, { name = 'NvimTreeNormal' }).bg, fg = '#ffffff' })
	vim.api.nvim_set_hl(0, 'NvimTreeNormalNC', { bg = vim.api.nvim_get_hl(0, { name = 'NvimTreeNormalNC' }).bg, fg = '#ffffff' })
	vim.api.nvim_set_hl(0, 'NvimTreeFileName', { fg = '#ffffff' })         -- regular filenames: white
	vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { fg = '#ffffff' })       -- folder names: white
	vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { fg = '#ffffff' }) -- opened folder names: white
	vim.api.nvim_set_hl(0, 'NvimTreeEmptyFolderName', { fg = '#ffffff' })  -- empty folder names: white

	-- Override NvimTree window options that aren't exposed in view config
	require('nvim-tree.view').View.winopts.statuscolumn = ''

	-- Permanent highlight for the Explorer title — never modified by dim/focus logic.
	-- Uses a dedicated hl group so colors.lua and tmux-colorscheme-sync don't
	-- accidentally clear it when they update NvimTreeNormal or Normal.
	local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
	vim.api.nvim_set_hl(0, 'BufferLineExplorerTitle', { bg = normal_hl.bg, fg = normal_hl.fg })

	-- See :help bufferline-configuration
	require('bufferline').setup({
		options = {
			themable = false,
			middle_mouse_command = 'bdelete! %d',
			separator_style = 'thin',
			indicator = { style = 'none' },
			offsets = {
				{
					filetype = 'NvimTree',
					text = 'Explorer',
					text_align = 'center',
					padding = 0,
					highlight = 'BufferLineExplorerTitle',
					separator = true,
				},
			},
		},
		highlights = {
			fill = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			background = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			close_button = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			duplicate = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			modified = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			diagnostic = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			offset_separator = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
				fg = {
					attribute = 'bg',
					highlight = 'Normal',
				},
			},
			trunc_marker = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			tab_close = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
			},
			-- LESSON: When NvimTree is focused, the buffer's tab becomes "visible"
			-- (not "selected"). Bufferline's default visible bg is tint(normal_bg, -8)
			-- which is darker. Set *_visible bg to Normal so the tab looks the same
			-- whether you're in the buffer or NvimTree. This matches tmux pane switch
			-- behavior where the tab stays bright.
			buffer_selected = {
				italic = false,
			},
			buffer_visible = {
				bg = {
					attribute = 'bg',
					highlight = 'Normal',
				},
			},
			indicator_visible = {
				bg = {
					attribute = 'bg',
					highlight = 'Normal',
				},
			},
			close_button_visible = {
				bg = {
					attribute = 'bg',
					highlight = 'Normal',
				},
			},
			-- LESSON: 'thin' separator draws │ on both sides of each tab.
			-- The left │ of a tab uses that tab's separator_* highlight.
			-- The right │ of a tab is actually the left │ of the NEXT tab.
			-- With 'thick' style, ▐ and ▌ are used instead.
			-- fg draws the separator character, bg fills the cell behind it.
			separator = {
				bg = {
					attribute = 'bg',
					highlight = 'NormalNC',
				},
				fg = {
					attribute = 'bg',
					highlight = 'Normal',
				},
			}
		},
	})

	-- Hide bufferline when there's only one buffer AND NvimTree is closed.
	-- Show it whenever NvimTree is open (for the Explorer offset) or multiple buffers exist.
	local function update_showtabline()
		local nvimtree_open = false
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_config(win).relative == '' then
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == 'NvimTree' then
					nvimtree_open = true
					break
				end
			end
		end
		if nvimtree_open then
			vim.o.showtabline = 2
			return
		end
		local listed = 0
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[b].buflisted then
				listed = listed + 1
				if listed > 1 then
					vim.o.showtabline = 2
					return
				end
			end
		end
		vim.o.showtabline = 0
	end
	vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufAdd', 'BufDelete', 'FileType' }, {
		group = vim.g.user.event,
		callback = function() vim.schedule(update_showtabline) end,
	})
	update_showtabline()

	-- Scroll through bufferline tabs with mouse wheel when hovering the tab bar
	local function tabline_scroll(direction)
		return function()
			local pos = vim.fn.getmousepos()
			if pos.screenrow == 1 then
				vim.cmd('BufferLineCycle' .. direction)
			else
				-- Pass through normal scroll
				local key = direction == 'Next' and '<ScrollWheelDown>' or '<ScrollWheelUp>'
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
			end
		end
	end
	vim.keymap.set('n', '<ScrollWheelUp>', tabline_scroll('Prev'), { desc = 'Scroll tabline or file' })
	vim.keymap.set('n', '<ScrollWheelDown>', tabline_scroll('Next'), { desc = 'Scroll tabline or file' })

	-- Use a thin line cursor in NvimTree instead of a block
	-- To hide entirely: 'a:NvimTreeHiddenCursor' with highlight { blend = 100, nocombine = true }
	local saved_guicursor
	vim.api.nvim_create_autocmd('BufEnter', {
		group = vim.g.user.event,
		callback = function()
			if vim.bo.filetype == 'NvimTree' then
				saved_guicursor = vim.o.guicursor
				vim.o.guicursor = 'a:ver1'
			end
		end,
	})
	vim.api.nvim_create_autocmd('BufLeave', {
		group = vim.g.user.event,
		callback = function()
			if vim.bo.filetype == 'NvimTree' and saved_guicursor then
				vim.o.guicursor = saved_guicursor
			end
		end,
	})

	-- Track nvim-tree width on manual resize
	vim.api.nvim_create_autocmd('WinResized', {
		group = vim.g.user.event,
		callback = function()
			local max_width = math.floor(vim.o.columns * 0.5)
			for _, win in ipairs(vim.v.event.windows or {}) do
				if vim.api.nvim_win_is_valid(win) then
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == 'NvimTree' then
						local w = vim.api.nvim_win_get_width(win)
						-- Ignore unreasonable widths (e.g. full-screen from directory hijack)
						if w >= 10 and w <= max_width then
							nvim_tree_width = w
							save_width(nvim_tree_width)
						end
					end
				end
			end
		end,
	})

	local function restore_nvimtree_width()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype == 'NvimTree' then
				if vim.api.nvim_win_get_width(win) ~= nvim_tree_width then
					vim.api.nvim_win_set_width(win, nvim_tree_width)
				end
				return
			end
		end
	end

	vim.api.nvim_create_autocmd('BufEnter', {
		group = vim.g.user.event,
		callback = restore_nvimtree_width,
	})

	vim.keymap.set('n', '<leader>e', function()
		local api = require('nvim-tree.api')
		api.tree.toggle()
		-- defer to let nvim-tree finish rendering before we resize
		vim.defer_fn(function()
			restore_nvimtree_width()
			update_showtabline()
		end, 50)
	end, { desc = 'File explorer (sidebar)' })
end

return M
