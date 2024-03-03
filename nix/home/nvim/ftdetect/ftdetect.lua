-- make some filetypes other filetypes so that LSPs and tools can pick them up
-- e.g. zsh is close enough to bash that we want it to be recognized by bash-ls & treesitter
vim.filetype.add({
	extension = {
		hcl = "terraform",
		zsh = "bash",
		sh = "sh", -- force sh-files with *sh-shebang to still get sh as filetype
	},
	filename = {
		["zshrc"] = "bash",
		["zshenv"] = "bash",
		[".zshrc"] = "bash",
		[".zshenv"] = "bash",
	},
})
