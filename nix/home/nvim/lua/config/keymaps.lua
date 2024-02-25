-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local opt = vim.opt

-- -- vim.keymap.set("n", "<Space>", "<Nop>") -- unmap <Space> so we can use it as leader
--
--

-- command mode stuff
opt.showcmd = true -- show (partial) command in status line
opt.wildmenu = true -- visual autocomplete for command menu
vim.keymap.set("c", "<C-a>", "<Home>") -- use emacs style shortcuts in command mode
vim.keymap.set("c", "<C-f>", "<Right>") -- see :help tcsh-style
vim.keymap.set("c", "<C-b>", "<Left>")
vim.keymap.set("c", "<Esc>b", "<S-Left>")
vim.keymap.set("c", "<Esc>f", "<S-Right>")
vim.keymap.set("c", "<Esc><Bs>", "<C-w>")

-- select entire line but ignoring leading/trailing whitespace
-- different than <S-v>, which selects the entire line including whitespace
vim.keymap.set("n", "vv", "_vg_")
-- maintain visual block selection after indentations
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
-- allow moving entire visual block down or up
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- clear search highlights
vim.keymap.set("n", "<localleader><CR>", ":nohlsearch<Cr>")
-- keep searches centered
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

local util = require("util")

-- usage: :lua Dump(some_table)
function Dump(o)
	util.dump(o)
end

vim.api.nvim_create_user_command("LspPrint", function()
	local servers = util.lsp_servers()

	print("other_ls:")
	for _, source in ipairs(servers.other_ls) do
		print("  ", source)
	end

	print("null_ls:")
	for _, source in ipairs(servers.null_ls) do
		print("  ", source)
	end
end, {})
