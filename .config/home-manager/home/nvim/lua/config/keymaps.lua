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

-- clear search highlights
vim.keymap.set("n", "<localleader><CR>", ":nohlsearch<Cr>")
-- keep searches centered
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
