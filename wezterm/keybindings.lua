-- WezTerm Keybindings Configuration
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("wezterm.utils")
local neovim = require("wezterm.neovim")
local workspace = require("wezterm.workspace")

local function setup_keybindings(config)
	local SUPER, META = utils.get_platform_config()

	-- Leader key
	config.leader = { key = "Space", mods = META }

	-- Main keybindings
	config.keys = {
		-- LEADER KEYS
		{ key = "r",          mods = "LEADER",             action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
		{ key = "l",          mods = "LEADER",             action = act.EmitEvent("toggle-ligatures") },
		{ key = "t",          mods = "LEADER",             action = act.EmitEvent("toggle-transparency") },

		-- Basic usage
		{ key = "c",          mods = SUPER,                action = act.CopyTo("Clipboard") },
		{ key = "v",          mods = SUPER,                action = act.PasteFrom("Clipboard") },
		{ key = "q",          mods = SUPER,                action = act.QuitApplication },
		{ key = "n",          mods = SUPER .. "|SHIFT",    action = act.SpawnWindow },
		{ key = "n",          mods = SUPER .. "|" .. META, action = act.SwitchToWorkspace },
		{ key = "Enter",      mods = SUPER,                action = act.ActivateCopyMode },

		-- WezTerm navigation
		{ key = "[",          mods = SUPER,                action = act.ActivateTabRelative(-1) },
		{ key = "]",          mods = SUPER,                action = act.ActivateTabRelative(1) },
		{ key = "6",          mods = "CTRL",               action = act.ActivateLastTab },
		{ key = "d",          mods = SUPER,                action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "d",          mods = SUPER .. "|SHIFT",    action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "w",          mods = SUPER,                action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "t",          mods = SUPER,                action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "LeftArrow",  mods = SUPER,                action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "DownArrow",  mods = SUPER,                action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "UpArrow",    mods = SUPER,                action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "RightArrow", mods = SUPER,                action = act.AdjustPaneSize({ "Right", 5 }) },

		-- Special key sequences for overlapping shortcuts
		{ key = "[",          mods = "CTRL",               action = act.SendString("\x33[91;5u") }, -- ctrl-[ - overlaps ESC
		{ key = "h",          mods = "CTRL",               action = act.SendString("\x33[104;5u") }, -- ctrl-h - overlaps BS/Backspace
		{ key = "m",          mods = "CTRL",               action = act.SendString("\x33[109;5u") }, -- ctrl-m - overlaps CR/Enter

		-- Meta key sequences for Vim/terminal applications
		{ key = ";",          mods = SUPER,                action = act.SendString("\x1b;") },
		{ key = "a",          mods = SUPER,                action = act.SendString("\x1ba") },
		{ key = "b",          mods = SUPER,                action = act.SendString("\x1bb") },
		{ key = "e",          mods = SUPER,                action = act.SendString("\x1be") },
		{ key = "f",          mods = SUPER,                action = act.SendString("\x1bf") },
		{ key = "g",          mods = SUPER,                action = act.SendString("\x1bg") },
		{ key = "h",          mods = SUPER,                action = act.SendString("\x1bh") },
		{ key = "i",          mods = SUPER,                action = act.SendString("\x1bi") },
		{ key = "j",          mods = SUPER,                action = act.SendString("\x1bj") },
		{ key = "k",          mods = SUPER,                action = act.SendString("\x1bk") },
		{ key = "l",          mods = SUPER,                action = act.SendString("\x1bl") },
		{ key = "m",          mods = SUPER,                action = act.SendString("\x1bm") },
		{ key = "n",          mods = SUPER,                action = act.SendString("\x1bn") },
		{ key = "o",          mods = SUPER,                action = act.SendString("\x1bo") },
		{ key = "p",          mods = SUPER,                action = act.SendString("\x1bp") },
		{ key = "r",          mods = SUPER,                action = act.SendString("\x1br") },
		{ key = "s",          mods = SUPER,                action = act.SendString("\x1bs") },
		{ key = "u",          mods = SUPER,                action = act.SendString("\x1bu") },
		{ key = "x",          mods = SUPER,                action = act.SendString("\x1bx") },
		{ key = "y",          mods = SUPER,                action = act.SendString("\x1by") },
		{ key = "z",          mods = SUPER,                action = act.SendString("\x1bz") },

		-- Workspace management
		{ key = "w",          mods = "CTRL|SHIFT",         action = workspace.create_new_workspace() },
		{
			key = "t",
			mods = "CTRL|SHIFT",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{ key = "s", mods = SUPER .. "|SHIFT",      action = workspace.create_workspace_selector() },
		{ key = "s", mods = SUPER .. "|CTRL|SHIFT", action = workspace.switch_workspace_selector() },
	}

	-- Add Neovim navigation keys
	local nav_keys = neovim.get_navigation_keys()
	for _, key in ipairs(nav_keys) do
		table.insert(config.keys, key)
	end

	-- Add numbered tab activation (SUPER + 1-0)
	for i = 1, 10 do
		table.insert(config.keys, {
			key = tostring(i % 10),
			mods = SUPER,
			action = act.ActivateTab(i - 1),
		})
	end
end

return {
	setup_keybindings = setup_keybindings,
}
