local Util = require("util")
local colors = Util.theme.colors

local theme = {
	normal = {
		a = { bg = colors.magenta, fg = colors.dark },
		b = { bg = colors.dark, fg = colors.light },
		c = { bg = colors.dark_blue, fg = colors.light },
	},
	insert = {
		a = { bg = colors.green, fg = colors.dark },
		b = { bg = colors.dark, fg = colors.light },
		c = { bg = colors.dark_blue, fg = colors.light },
	},
	visual = {
		a = { bg = colors.yellow, fg = colors.dark },
		b = { bg = colors.dark, fg = colors.light },
		c = { bg = colors.dark_blue, fg = colors.light },
	},
	replace = {
		a = { bg = colors.orange, fg = colors.dark },
		b = { bg = colors.dark, fg = colors.light },
		c = { bg = colors.dark_blue, fg = colors.light },
	},
	command = {
		a = { bg = colors.cyan, fg = colors.dark },
		b = { bg = colors.dark, fg = colors.light },
		c = { bg = colors.dark_blue, fg = colors.light },
	},
	inactive = {
		a = { bg = colors.dark_blue, fg = colors.light_blue },
		b = { bg = colors.dark_blue, fg = colors.light_blue },
		c = { bg = colors.dark_blue, fg = colors.light_blue },
	},
}

---@diagnostic disable: undefined-field

return {
	-- https://www.lazyvim.org/plugins/ui#lualinenvim
	"nvim-lualine/lualine.nvim",
	-- if VeryLazy, there will be a white bar flicker that is more annoying than the "slightly longer" startup time
	event = "VimEnter",
	enabled = false,
	lazy = false,
	dependencies = {
		"meuter/lualine-so-fancy.nvim",
	},
	init = function()
		vim.g.lualine_laststatus = vim.o.laststatus
		if vim.fn.argc(-1) > 0 then
			-- set an empty statusline till lualine loads
			vim.o.statusline = " "
		else
			-- hide the statusline on the starter page
			vim.o.laststatus = 0
		end
	end,
	opts = function(_, defaultOpts)
		local opts = defaultOpts

		opts.options = {
			theme = theme,
			globalstatus = true,
			disabled_filetypes = {
				statusline = {
					"dashboard",
					"alpha",
					"starter",
					"neo-tree",
					"sagaoutline",
				},
			},
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" }, --│
		}

		-- extensions don't seem to work when i swap statusline with winbar :(
		-- opts.extensions = {
		-- 	"neo-tree",
		-- 	"lazy",
		-- }

		-- create the statusline
		opts.sections = {
			lualine_a = {
				{ "fancy_mode", width = 3 },
			},
			lualine_b = {
				{
					"branch",
					padding = { left = 1, right = 1 },
					separator = { right = "" },
				},
			},
			lualine_c = {
				-- Util.lualine.root_dir(),
				{
					Util.lualine.pretty_path(),
					cond = function()
						local buffers = vim.api.nvim_list_bufs()
						for _, buf in pairs(buffers) do
							local ft = vim.api.nvim_buf_get_option(buf, "ft")
							if ft == "neo-tree" then
								return false
							end
						end
						return true
					end,
					path = function()
						if vim.o.columns > 78 then
							return 2
						else
							return 0
						end
					end,
					padding = { left = 1, right = 0 },
				},

				{ "filesize", padding = { left = 1, right = 0 }, color = Util.ui.fg("Statement") },
				{ "progress", padding = { left = 1, right = 0 }, color = Util.ui.fg("Constant") },
				{ "location", padding = { left = 1, right = 0 }, color = Util.ui.fg("Special") },

				-- stylua: ignore
				{ function() return "%=" end, },
				{ "fancy_diagnostics", padding = { left = 0, right = 0 }, separator = "│" },
				{ "fancy_diff", padding = { left = 0, right = 0 }, separator = "│" },
				{ "filetype", icon_only = true, padding = { left = 0, right = 1 } },
				{
					function()
						return Util.lsp_servers({ lualine = true })
					end,
					padding = { left = 0, right = 0 },
				},
			},
			lualine_x = {
				-- stylua: ignore
				-- { function() return "%=" end, },
				{
					-- 'encoding': Don't display if encoding is UTF-8.
					function()
						local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
						return ret
					end,
					padding = { left = 0, right = 1 },
				},
				{
					-- fileformat: Don't display if unix
					function()
						local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
						return ret
					end,
					padding = { left = 0, right = 1 },
				},
				-- stylua: ignore
				{
					-- shows macro recording
					require("noice").api.status.mode.get,
					cond = function()
						return package.loaded["noice"] and
						    require("noice").api.status.mode.has()
					end,
					color = Util.ui.fg("Constant"),
					padding = { left = 0, right = 1 },
				},
				-- stylua: ignore
				{
					-- shows last vim command
					require("noice").api.status.command.get,
					cond = function()
						return package.loaded["noice"] and
						    require("noice").api.status.command.has()
					end,
					color = Util.ui.fg("Statement"),
					padding = { left = 0, right = 1 },
				},
				-- stylua: ignore
				{
					function() return "  " .. require("dap").status() end,
					cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
					color = Util.ui.fg("Debug"),
					padding = { left = 0, right = 1 },
				},
			},
			lualine_y = {
				{
					function()
						return " " .. require("lazy.status").updates()
					end,
					cond = require("lazy.status").has_updates,
					separator = { left = "" },
					padding = { left = 0, right = 1 },
				},
			},
			lualine_z = {
				{
					function()
						return " " .. os.date("%R")
					end,
					padding = { left = 0, right = 1 },
					cond = function()
						return vim.fn.winwidth(0) > 120
					end,
				},
			},
		}

		-- swap the statusline with winbar, and make it "sticky" by
		-- using it in both the active and inactive winbar
		opts.winbar = opts.sections
		opts.inactive_winbar = opts.sections
		opts.options.disabled_filetypes.winbar = opts.options.disabled_filetypes.statusline

		-- remove and hide the now empty statusline
		opts.sections = {}
		opts.inactive_sections = {}

		vim.opt.laststatus = 0
		vim.opt.showtabline = 1

		return opts
	end,
}
