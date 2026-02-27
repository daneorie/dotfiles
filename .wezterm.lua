-- ~/.wezterm.lua - Main WezTerm Configuration File
-- This file loads modular configuration files

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Function to get the real directory of this config file (handles symlinks)
local function get_config_dir()
	-- Try to resolve the symlink using the shell
	local home = wezterm.home_dir
	local config_path = home .. "/.wezterm.lua"

	-- Check if the config file is a symlink and resolve it
	local handle = io.popen("readlink '" .. config_path .. "' 2>/dev/null")
	if handle then
		local real_path = handle:read("*l")
		handle:close()

		if real_path and real_path ~= "" then
			-- It's a symlink, extract the directory
			return real_path:match("(.+)/[^/]*$") or home .. "/dotfiles"
		end
	end

	-- Fallback: assume it's in the dotfiles directory
	return home .. "/dotfiles"
end

-- Add the config directory to Lua's package path for module loading
local config_dir = get_config_dir()
package.path = package.path .. ";" .. config_dir .. "/?.lua"

-- Load configuration modules
local appearance = require("wezterm.appearance")
local events = require("wezterm.events")
local keybindings = require("wezterm.keybindings")
local key_tables = require("wezterm.key_tables")

-- This table will hold the configuration
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Apply configuration modules
appearance.apply_appearance(config)
keybindings.setup_keybindings(config)
key_tables.setup_key_tables(config)

-- Setup event handlers
events.setup_events()

-- Return the configuration to wezterm
return config
