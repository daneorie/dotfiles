-- WezTerm Utility Functions
local M = {}

-- Split string by separator
function M.split(inputstr, sep)
	if inputstr == "" then
		return {}
	end
	sep = sep or "%s"
	local t = {}
	for field, s in inputstr:gmatch("([^" .. sep .. "]*)(" .. sep .. "?)") do
		table.insert(t, field)
		if s == "" then
			return t
		end
	end
	return t
end

-- Check if table has specific value
function M.has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Convert hex to character
function M.hex_to_char(x)
	return string.char(tonumber(x, 16))
end

-- Unescape URL encoding
function M.unescape(url)
	return url:gsub("%%(%x%x)", M.hex_to_char)
end

-- Map string of keys to actions
function M.map(things)
	local wezterm = require("wezterm")
	local act = wezterm.action

	local t = {}
	for key in things:gmatch("([^,]+)") do
		table.insert(t, act.SendKey({ key = key }))
	end
	return t
end

-- Equivalent to POSIX basename(3)
function M.basename(s)
	local current_dir = tostring(s)
	if type(s) == "userdata" then
		current_dir = M.unescape(current_dir)
	end
	return current_dir:gsub("(.*[/\\])(.*)", "%2")
end

-- Platform detection helpers
function M.get_platform_config()
	local wezterm = require("wezterm")

	local SUPER, META
	local platform_config = {}

	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		SUPER = "META"
		META = "SUPER"
		platform_config.window_background_opacity = 0.8
		platform_config.text_background_opacity = 0.8
		platform_config.default_domain = "WSL:Ubuntu"
		platform_config.warn_about_missing_glyphs = false
		platform_config.allow_win32_input_mode = false
	else
		SUPER = "SUPER"
		META = "META"
	end

	return SUPER, META, platform_config
end

return M
