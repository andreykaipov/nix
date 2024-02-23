local Util = require("util")

-- the night-owl theme but with some colors swapped around
-- https://github.com/oxfist/night-owl.nvim/blob/2b7e78c34e25aea841d10ebc3ee19d6d558e9ec0/lua/lualine/themes/night-owl.lua
-- can import as follows alternatively and do the overwriting but i think redefining it is easier:
-- local theme = require("lualine.themes.night-owl")

local colors = {
	dark = "#010d18",
	light = "#d6deeb",
	magenta = "#c792ea",
	green = "#c5e478",
	yellow = "#e2b93d",
	orange = "#f78c6c",
	cyan = "#6ae9f0",
	dark_blue = "#0e293f",
	light_blue = "#5f7e97",
	dark_blue_green = "#006b6b",
}

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

local lsp_servers = function()
	local msg = "No Active LSP"
	local buf_clients = vim.lsp.get_active_clients()
	if next(buf_clients) == nil then
		return msg
	end

	local null_ls_installed, null_ls = pcall(require, "null-ls")
	local lsps_null = {}
	local lsps_other = {}
	for _, client in pairs(buf_clients) do
		if client.name == "null-ls" then
			if null_ls_installed then
				for _, source in ipairs(null_ls.get_source({ filetype = vim.bo.filetype })) do
					table.insert(lsps_null, source.name)
				end
			end
		else
			table.insert(lsps_other, client.name)
		end
	end

	table.sort(lsps_null)
	table.sort(lsps_other)

	local prefix = table.concat(lsps_other, ",")
	if prefix ~= "" then
		prefix = prefix .. "│"
	end

	local suffix = table.concat(lsps_null, ",")
	if suffix == "" then
		suffix = "empty"
	end
	if string.len(suffix) > 40 or vim.fn.winwidth(0) < 120 then
		suffix = "null_ls"
	end

	return prefix .. suffix
end

---@diagnostic disable: undefined-field

return {
	-- https://www.lazyvim.org/plugins/ui#lualinenvim
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"meuter/lualine-so-fancy.nvim",
	},
	event = "VeryLazy",
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
					lsp_servers,
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
