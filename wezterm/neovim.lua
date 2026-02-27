-- WezTerm Neovim Integration
local wezterm = require("wezterm")
local act = wezterm.action

-- Check if current pane is running Neovim
local function is_inside_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local function is_outside_vim(pane)
	return not is_inside_vim(pane)
end

-- Conditionally bind keys based on vim state
local function bind_if(cond, key, mods, action, alt_str)
	local function callback(win, pane)
		if cond(pane) then
			win:perform_action(action, pane)
		elseif alt_str then
			win:perform_action(act.SendString(alt_str), pane)
		else
			win:perform_action(act.SendKey({ key = key, mods = mods }), pane)
		end
	end

	return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

-- Get navigation keybindings for Colemak layout with Neovim integration
local function get_navigation_keys()
	return {
		-- Wezterm & NeoVim Pane Navigation (Colemak layout)
		bind_if(is_outside_vim, "n", "CTRL", act.ActivatePaneDirection("Left")),
		bind_if(is_outside_vim, "e", "CTRL", act.ActivatePaneDirection("Down")),
		bind_if(is_outside_vim, "i", "CTRL", act.ActivatePaneDirection("Up"), "\x33[105;5u"),
		bind_if(is_outside_vim, "o", "CTRL", act.ActivatePaneDirection("Right")),
	}
end

return {
	is_inside_vim = is_inside_vim,
	is_outside_vim = is_outside_vim,
	bind_if = bind_if,
	get_navigation_keys = get_navigation_keys,
}