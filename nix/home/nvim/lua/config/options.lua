-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Most options are bundled together with the relevant plugin configuration in lua/plugins
-- So this file essentially only has misc vim options that don't make sense anywhere else
--
--vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.is_posix = 1

local opt = vim.opt

opt.termguicolors = true
opt.tabstop = 8
opt.background = "dark"

local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
local root = config_home .. "/nvim"
opt.undofile = true
opt.undodir = { root .. "/tmp/undo//" } -- preserve history after closing
opt.backup = true
opt.backupdir = { root .. "/tmp/bak//" }
opt.directory = { root .. "/tmp/swp//" }

opt.number = true
opt.relativenumber = true -- <leader>uL to toggle
opt.scrolloff = 10

opt.list = false
opt.listchars = {
	tab = "→ ",
	space = "·",
	eol = "↲",
	nbsp = "␣",
	trail = "•",
	extends = "⟩",
	precedes = "⟨",
}

opt.signcolumn = "auto:3-5" -- so new gutter signs don't move the text
opt.cursorline = true -- highlight current line
opt.cursorlineopt = "line,number" --
opt.colorcolumn = "120" -- table.concat(vim.fn.range(81, 120), ",") -- highlight column 81 to 120
opt.textwidth = 0 -- don't auto wrap lines at 120 characters

opt.showcmd = true -- show (partial) command in status line
opt.wildmenu = true -- visual autocomplete for command menu

-- don't show netrw since neotree will load in soon after
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- use gw instead of gq:
-- https://vi.stackexchange.com/questions/39200/wrapping-comment-in-visual-mode-not-working-with-gq
-- https://github.com/neovim/neovim/pull/19677
-- :h fo-table
opt.formatoptions = opt.formatoptions + "croq1jlMn"
