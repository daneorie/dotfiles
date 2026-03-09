-- WezTerm Appearance Configuration
local utils = require("utils")

local function apply_appearance(config)
	-- Color scheme and transparency
	config.color_scheme = "nordfox"
	config.window_background_opacity = 0.6
	config.text_background_opacity = 0.6
	config.macos_window_background_blur = 40

	-- Window and tab bar settings
	config.tab_bar_at_bottom = true
	config.window_decorations = "RESIZE"
	config.use_fancy_tab_bar = false

	-- Keyboard enhancements
	config.enable_kitty_keyboard = true
	--config.enable_kitty_graphics = true

	-- Apply platform-specific overrides
	local _, _, platform_config = utils.get_platform_config()
	for key, value in pairs(platform_config) do
		config[key] = value
	end
end

return {
	apply_appearance = apply_appearance
}
