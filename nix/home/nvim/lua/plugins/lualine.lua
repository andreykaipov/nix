return {
	{
		-- https://www.lazyvim.org/plugins/ui#lualinenvim
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"meuter/lualine-so-fancy.nvim",
		},
		init = function()
			-- hides the statusline so it doesn't flicker when lualine and reassigns it to the winbar
			vim.opt.laststatus = 0
			-- without a statusline, we force an empty winbar to prevent the text from hopping around
			-- after it loads in
			local win = vim.api.nvim_get_current_win()
			vim.wo[win].winbar = " "
			-- tabline isn't a problem but i don't need it
			vim.opt.showtabline = 0
		end,
		config = function(_, opts)
			-- move the statusline into the winbar
			opts.winbar = opts.sections
			opts.inactive_winbar = opts.sections
			opts.options.disabled_filetypes.winbar = opts.options.disabled_filetypes.statusline
			-- remove the statusline
			opts.sections = {}
			opts.inactive_sections = {}
			--
			require("lualine").setup(opts)
		end,
		opts = function(_, opts)
			opts.options = {
				-- globalstatus = true,
				disabled_filetypes = {
					statusline = {
						-- "dashboard",
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
			-- local auto_theme_custom =
			-- auto_theme_custom.normal.c.bg = "none"
			-- the theme is set automatically based on the colorscheme when setup is called below,
			-- but we need to set it earlier to be able to make lualine transparent for any colorscheme
			opts.theme = require("lualine.themes.auto")
			opts.theme.normal.c = "none"
			opts.theme.visual.c = "none"
			opts.theme.insert.c = "none"
			opts.theme.replace.c = "none"
			opts.theme.command.c = "none"
			opts.theme.inactive.c = "none"

			local util = require("util")

			opts.sections.lualine_a = {
				{ "fancy_mode", width = 3 },
			}
			opts.sections.lualine_b = {
				{ "branch", padding = { left = 1, right = 0 } },
				{ "fancy_cwd", substitute_home = true },
			}
			opts.sections.lualine_c = {
				-- Util.lualine.root_dir(),
				{
					"filename",
					-- Util.lualine.pretty_path(),
					cond = function()
						local buffers = vim.api.nvim_list_bufs()
						for _, buf in pairs(buffers) do
							local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
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
					padding = { left = 1, right = 1 },
				},

				{ "filesize", padding = { left = 0, right = 0 }, color = { fg = util.ui.color("Statement").fg } },
				{ "progress", padding = { left = 1, right = 0 }, color = { fg = util.ui.color("Constant").fg } },
				{ "location", padding = { left = 1, right = 0 }, color = { fg = util.ui.color("Special").fg } },

				-- stylua: ignore
				{ function() return "%=" end, },
				-- stylua: ignore
				{ function() return "" end, },

				{ "fancy_diagnostics", padding = { left = 1, right = 1 }, separator = "│" },
				{ "fancy_diff", padding = { left = 1, right = 1 }, separator = "│" },
			}
			opts.sections.lualine_x = {
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
				{
					-- shows macro recording
					require("noice").api.status.mode.get,
					cond = function()
						return package.loaded["noice"] and require("noice").api.status.mode.has()
					end,
					color = util.ui.color("Constant"),
					padding = { left = 0, right = 1 },
				},
				{
					-- shows last vim command
					require("noice").api.status.command.get,
					cond = function()
						return package.loaded["noice"] and require("noice").api.status.command.has()
					end,
					color = { fg = util.ui.color("Statement").fg },
					padding = { left = 0, right = 1 },
				},
				{
					function()
						return "  " .. require("dap").status()
					end,
					cond = function()
						return package.loaded["dap"] and require("dap").status() ~= ""
					end,
					color = util.ui.color("Debug"),
					padding = { left = 0, right = 1 },
				},
			}
			opts.sections.lualine_y = {
				{
					function()
						return require("lazy.status").updates()
					end,
					cond = require("lazy.status").has_updates,
					separator = { left = "" },
					padding = { left = 0, right = 0 },
				},
			}
			opts.sections.lualine_z = {
				{
					"filetype",
					icon_only = true,
					padding = { left = 0, right = 0 },
					separator = { left = "" },
					color = { bg = "black" },
				},
				-- stylua: ignore
				{
					function() return util.lsp_servers({ lualine = true }) end,
					padding = { left = 0, right = 0 },
					separator = { left = "" },
					cond = function() return vim.fn.winwidth(0) > 120 end,
				},
				-- {
				-- 	function()
				-- 		return " " .. os.date("%R")
				-- 	end,
				-- 	padding = { left = 0, right = 1 },
				-- 	cond = function()
				-- 		return vim.fn.winwidth(0) > 120
				-- 	end,
				-- },
			}
		end,
	},
	{
		-- don't use a lazy event here
		"vimpostor/vim-tpipeline",
		dev = true,
		enabled = false,
		-- lazy = false,
		dependencies = { "nvim-lualine/lualine.nvim" },
		config = function()
			vim.g.tpipeline_autoembed = 0
			vim.g.tpipeline_usepane = 1
			vim.g.tpipeline_fillcentre = 1
			vim.g.tpipeline_split = 1
			vim.g.tpipeline_focuslost = 0
			vim.g.tpipeline_clearstl = 1
			-- vim.g.tpipeline_fillcentre = 1

			local group = vim.api.nvim_create_augroup("vim-tpipeline-cleanup", { clear = true })
			vim.api.nvim_create_autocmd({ "VimLeave" }, {
				group = group,
				pattern = "*",
				desc = "select tmux pane title back to original (empty)",
				callback = function()
					os.execute("tmux select-pane -T ''")
				end,
			})

			-- old settings of mine?
			-- vim.g.tpipeline_autoembed = 0
			-- vim.g.tpipeline_embedopts = { "status-justify absolute-centre" }
			-- vim.g.tpipeline_focuslost = 0
			-- vim.g.tpipeline_restore = 0
			-- vim.g.tpipeline_size = 500
			-- vim.g.tpipeline_split = 1
			-- vim.g.tpipeline_statusline = "%f"
			-- vim.g.tpipeline_tabline = 0
			-- vim.g.tpipeline_usepane = 1
			-- vim.opt.laststatus = 0
			-- vim.g.tpipeline_statusline = "#[bg=default]"
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. ""
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. "#[fg=brightcyan]%t%h%w%m%r " -- " %F
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. "#[fg=orange](%l,%c%V) %P "
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. "%="
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. "#[fg=brightmagenta]%y"
			-- vim.g.tpipeline_statusline = vim.g.tpipeline_statusline .. "#[fg=pink][%{&fileformat} %{&fileencoding?&fileencoding:&encoding}]"
		end,
	},
}
