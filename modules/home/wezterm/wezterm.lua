local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.use_ime = false

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
-- config.clean_exit_codes = { 140,141,142,143,144 }
-- config.exit_behavior_messaging = "Verbose"
-- config.exit_behavior = 'CloseOnCleanExit'

-- For example, changing the initial geometry for new windows:
config.initial_cols = 180
config.initial_rows = 45

-- or, changing the font size and color scheme.
-- config.font = wezterm.font("Comic Mono")
config.font = wezterm.font("ComicShannsMono Nerd Font")
config.font_size = 16
-- config.color_scheme = 'AdventureTime'
--
-- config.colors = {
--         -- Make the selection text color fully transparent.
--         -- When fully transparent, the current text color will be used.
--         -- Set the selection background color with alpha.
--         -- When selection_bg is transparent, it will be alpha blended over
--         -- the current cell background color, rather than replace it
--         -- selection_bg = "rgba(50% 50% 50% 50%)",
-- }
config.window_background_opacity = 0.99 -- not 1.0: macOS draws a border line with the opaque rendering path
-- config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_padding = { left = 10, right = 10, top = 5, bottom = 0 }

-- Read cached bg color written by nvim's colorscheme sync so the
-- terminal background is correct even before nvim starts.
local bg_cache = wezterm.home_dir .. "/.local/state/wezterm/bg-color.txt"
local f = io.open(bg_cache, "r")
if f then
	local color = f:read("*a")
	f:close()
	if color and #color > 0 then
		config.colors = config.colors or {}
		config.colors.background = color
	end
end

config.macos_window_background_blur = 0

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Pass middle-click through to apps (e.g. nvim bufferline close-tab)
config.mouse_bindings = {
	-- Single-click opens hyperlinks (when cursor is a hand)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	{
		event = { Up = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

config.keys = {
	-- Cmd+W / Cmd+Shift+T / Cmd+S → F1/F2/F3 so they don't shadow Ctrl-W, Alt-T, or get swallowed
	{ key = "w",          mods = "SUPER",       action = wezterm.action.SendKey({ key = "F1" }) },
	{ key = "t",          mods = "SUPER|SHIFT", action = wezterm.action.SendKey({ key = "F2" }) },
	{ key = "s",          mods = "SUPER",       action = wezterm.action.SendKey({ key = "F3" }) },
	{ key = "f",          mods = "SUPER|SHIFT", action = wezterm.action.SendKey({ key = "F4" }) },
	-- Disable WezTerm's default Alt+Arrow bindings so they pass through to tmux/nvim
	{ key = "LeftArrow",  mods = "ALT",         action = wezterm.action.SendKey({ key = "LeftArrow", mods = "ALT" }) },
	{ key = "RightArrow", mods = "ALT",         action = wezterm.action.SendKey({ key = "RightArrow", mods = "ALT" }) },
	{ key = "UpArrow",    mods = "ALT",         action = wezterm.action.SendKey({ key = "UpArrow", mods = "ALT" }) },
	{ key = "DownArrow",  mods = "ALT",         action = wezterm.action.SendKey({ key = "DownArrow", mods = "ALT" }) },
	-- Send CSI-u encoded Shift+Enter so tmux/pi can distinguish it from plain Enter
	{ key = "Enter",      mods = "SHIFT",       action = wezterm.action.SendString("\x1b[13;2u") },
}

-- Don't include trailing ) in URLs, e.g. "(https://example.com)" should
-- only link "https://example.com". URLs that contain paired () still work,
-- e.g. "https://example.com/page_(section)" links the full URL.
config.hyperlink_rules = {
	{ regex = [=[\b\w+://(?:[^\s()]*\([^\s()]*\))*[^\s()]*]=], format = "$0" },
	{ regex = [=[\b\w+@[\w-]+(\.[\w-]+)+\b]=],                 format = "mailto:$0" },
}

config.set_environment_variables = { BOOTSTRAP = "1" }
config.default_prog = { wezterm.config_dir .. "/bootstrap.sh" }

return config
