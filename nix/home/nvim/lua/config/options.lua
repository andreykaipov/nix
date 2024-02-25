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

opt.tabstop = 8
opt.list = false

local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
local root = config_home .. "/nvim"
opt.undofile = true
opt.undodir = { root .. "/tmp/undo//" } -- preserve history after closing
opt.backup = true
opt.backupdir = { root .. "/tmp/bak//" }
opt.directory = { root .. "/tmp/swp//" }

local Util = require("lazyvim.util")
opt.relativenumber = false
