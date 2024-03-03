local wezterm = require("wezterm")
local config = {}

config.color_scheme = "Batman"
config.default_prog = {
	"wsl.exe",
	"-d",
	"Ubuntu",
	"--",
	"BOOTSTRAP=1",
	"~/bin/_bootstrap.sh",
}

-- config.default_cwd = '/home/andrey'
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- wezterm ls-fonts --list-system
-- https://wezfurlong.org/wezterm/config/fonts.html#troubleshooting-fonts
config.font = wezterm.font_with_fallback({
	"CaskaydiaMono Nerd Font Mono",
	"JetBrains Mono",
})
config.warn_about_missing_glyphs = false

config.default_cursor_style = "BlinkingBar"

-- https://wezfurlong.org/wezterm/config/appearance.html
-- https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'Abernathy'
-- config.color_scheme = 'Adventure'
-- my colors from windows terminal for now
config.colors = {
	foreground = "#D3D7CF",
	background = "#000000",

	cursor_bg = "orange",
	cursor_fg = "black",
	cursor_border = "orange",

	selection_fg = "black",
	selection_bg = "#fffacd",

	scrollbar_thumb = "#222222",

	ansi = {
		"#000000",
		"#CC0000",
		"#4E9A06",
		"#C4A000",
		"#3465A4",
		"#75507B",
		"#06989A",
		"#D3D7CF",
	},
	brights = {
		"#555753",
		"#EF2929",
		"#8AE234",
		"#FCE94F",
		"#729FCF",
		"#AD7FA8",
		"#34E2E2",
		"#EEEEEC",
	},

	compose_cursor = "red",
}

return config
