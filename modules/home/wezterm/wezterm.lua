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
config.font_size = 16
-- config.color_scheme = 'AdventureTime'
--
config.colors = {

        -- Make the selection text color fully transparent.
        -- When fully transparent, the current text color will be used.
        -- Set the selection background color with alpha.
        -- When selection_bg is transparent, it will be alpha blended over
        -- the current cell background color, rather than replace it
        -- selection_bg = "rgba(50% 50% 50% 50%)",
}
config.window_background_opacity = 0.99 -- not 1.0: macOS draws a border line with the opaque rendering path
-- config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.macos_window_background_blur = 0

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.set_environment_variables = { BOOTSTRAP = "1" }
config.default_prog = { wezterm.config_dir .. "/bootstrap.sh" }

return config
