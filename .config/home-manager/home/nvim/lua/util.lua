local M = require("lazyvim.util")

-- e.g. Util.ui.fg("Statement") to fetch the color for a specific highlight group
-- see: https://github.com/oxfist/night-owl.nvim/blob/main/lua/night-owl/theme.lua

function M.ui.bg(name)
	local hl = vim.api.nvim_get_hl(0, { name = name })
	local bg = hl and (hl.bg or hl.background)
	return bg and { bg = string.format("#%06x", bg) } or nil
end

function M.trim(s)
	return s:match("^%s*(.-)%s*$")
end

function M.header()
	local logo = M.trim([[
┃      ⹁⹁    ⹁⹁           ┃
┃      |'\__/'|     (`\   ┃
┃    = | 'ㅅ' | =    ) )  ┃
┃--- ◜◜◜----- ◜◜◜---------┃
	]])
	logo = string.rep("\n", 2) .. logo .. string.rep("\n", 1)
	return vim.split(logo, "\n")
end

return M
