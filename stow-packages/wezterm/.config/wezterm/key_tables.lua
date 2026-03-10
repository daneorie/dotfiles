-- WezTerm Key Tables Configuration
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

local function setup_key_tables(config)
	config.key_tables = {
		-- Resize pane mode with Colemak navigation
		resize_pane = {
			-- Arrow key navigation
			{ key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },

			-- Colemak navigation (n=left, e=down, i=up, o=right)
			{ key = "n",          mods = "NONE",                              action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "n",          mods = "SHIFT",                             action = act.AdjustPaneSize({ "Left", 5 }) },
			{ key = "e",          mods = "NONE",                              action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "e",          mods = "SHIFT",                             action = act.AdjustPaneSize({ "Down", 5 }) },
			{ key = "i",          mods = "NONE",                              action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "i",          mods = "SHIFT",                             action = act.AdjustPaneSize({ "Up", 5 }) },
			{ key = "o",          mods = "NONE",                              action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "o",          mods = "SHIFT",                             action = act.AdjustPaneSize({ "Right", 5 }) },

			-- Neovim pane resize commands (for when inside Neovim)
			-- Left resize (decrease width)
			{ key = "m",          mods = "NONE",                              action = act.Multiple(utils.map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,-,1,Enter")) },
			{ key = "m",          mods = "SHIFT",                             action = act.Multiple(utils.map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,-,5,Enter")) },

			-- Down resize (decrease height)
			{ key = ",",          mods = "NONE",                              action = act.Multiple(utils.map("Escape,:,r,e,s,i,z,e, ,-,1,Enter")) },
			{ key = "<",          mods = "SHIFT",                             action = act.Multiple(utils.map("Escape,:,r,e,s,i,z,e, ,-,5,Enter")) },

			-- Up resize (increase height)
			{ key = ".",          mods = "NONE",                              action = act.Multiple(utils.map("Escape,:,r,e,s,i,z,e, ,+,1,Enter")) },
			{ key = ">",          mods = "SHIFT",                             action = act.Multiple(utils.map("Escape,:,r,e,s,i,z,e, ,+,5,Enter")) },

			-- Right resize (increase width)
			{ key = "/",          mods = "NONE",                              action = act.Multiple(utils.map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,+,1,Enter")) },
			{ key = "?",          mods = "SHIFT",                             action = act.Multiple(utils.map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,+,5,Enter")) },

			-- Exit resize mode
			{ key = "Escape",     action = "PopKeyTable" },
		},

		-- Copy mode with Colemak navigation
		copy_mode = {
			{ key = "Tab",    mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
			{ key = "Tab",    mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "Enter",  mods = "NONE",  action = act.CopyMode("MoveToStartOfNextLine") },
			{ key = "Escape", mods = "NONE",  action = act.CopyMode("Close") },
			{ key = "Space",  mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "/",      mods = "NONE",  action = act.Search({ CaseSensitiveString = "" }) },
			{ key = "$",      mods = "NONE",  action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "$",      mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = ",",      mods = "NONE",  action = act.CopyMode("JumpReverse") },
			{ key = "0",      mods = "NONE",  action = act.CopyMode("MoveToStartOfLine") },
			{ key = ";",      mods = "NONE",  action = act.CopyMode("JumpAgain") },

			-- Vim-like navigation
			{ key = "F",      mods = "NONE",  action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
			{ key = "F",      mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
			{ key = "G",      mods = "NONE",  action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "G",      mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },

			-- Colemak viewport navigation
			{ key = "N",      mods = "NONE",  action = act.CopyMode("MoveToViewportTop") },
			{ key = "N",      mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
			{ key = "O",      mods = "NONE",  action = act.CopyMode("MoveToViewportBottom") },
			{ key = "O",      mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "M",      mods = "NONE",  action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "M",      mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },

			-- Selection modes
			{ key = "K",      mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
			{ key = "K",      mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
			{ key = "T",      mods = "NONE",  action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
			{ key = "T",      mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
			{ key = "V",      mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "V",      mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "^",      mods = "NONE",  action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "^",      mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },

			-- Exit copy mode
			{ key = "a",      mods = "NONE",  action = act.CopyMode("Close") },
			{ key = "c",      mods = "CTRL",  action = act.CopyMode("Close") },
			{ key = "g",      mods = "CTRL",  action = act.CopyMode("Close") },
			{ key = "h",      mods = "NONE",  action = act.CopyMode("Close") },
			{ key = "q",      mods = "NONE",  action = act.CopyMode("Close") },

			-- Movement commands
			{ key = "b",      mods = "NONE",  action = act.CopyMode("MoveBackwardWord") },
			{ key = "b",      mods = "META",  action = act.CopyMode("MoveBackwardWord") },
			{ key = "b",      mods = "CTRL",  action = act.CopyMode("PageUp") },
			{ key = "f",      mods = "NONE",  action = act.CopyMode({ JumpForward = { prev_char = false } }) },
			{ key = "f",      mods = "META",  action = act.CopyMode("MoveForwardWord") },
			{ key = "f",      mods = "CTRL",  action = act.CopyMode("PageDown") },
			{ key = "g",      mods = "NONE",  action = act.CopyMode("MoveToScrollbackTop") },
			{ key = "l",      mods = "NONE",  action = act.CopyMode("MoveForwardWordEnd") },

			-- Colemak movement (n=left, e=down, i=up, o=right)
			{ key = "n",      mods = "NONE",  action = act.CopyMode("MoveLeft") },
			{ key = "e",      mods = "NONE",  action = act.CopyMode("MoveDown") },
			{ key = "i",      mods = "NONE",  action = act.CopyMode("MoveUp") },
			{ key = "o",      mods = "NONE",  action = act.CopyMode("MoveRight") },

			-- Page navigation
			{ key = ",",      mods = "CTRL",  action = act.CopyMode("PageDown") },
			{ key = ".",      mods = "CTRL",  action = act.CopyMode("PageUp") },
			{ key = "u",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = 0.5 }) },
			{ key = "y",      mods = "CTRL",  action = act.CopyMode({ MoveByPage = -0.5 }) },
			{ key = "m",      mods = "META",  action = act.CopyMode("MoveToStartOfLineContent") },

			-- More movement
			{ key = "k",      mods = "NONE",  action = act.CopyMode("MoveToSelectionOtherEnd") },
			{ key = "t",      mods = "NONE",  action = act.CopyMode({ JumpForward = { prev_char = true } }) },
			{ key = "v",      mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "v",      mods = "CTRL",  action = act.CopyMode({ SetSelectionMode = "Block" }) },
			{ key = "w",      mods = "NONE",  action = act.CopyMode("MoveForwardWord") },

			-- Copy and exit
			{
				key = "y",
				mods = "NONE",
				action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
			},

			-- Standard navigation keys
			{ key = "PageUp",     mods = "NONE", action = act.CopyMode("PageUp") },
			{ key = "PageDown",   mods = "NONE", action = act.CopyMode("PageDown") },
			{ key = "End",        mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "Home",       mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
			{ key = "LeftArrow",  mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "LeftArrow",  mods = "META", action = act.CopyMode("MoveBackwardWord") },
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
			{ key = "RightArrow", mods = "META", action = act.CopyMode("MoveForwardWord") },
			{ key = "UpArrow",    mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "DownArrow",  mods = "NONE", action = act.CopyMode("MoveDown") },
		},

		-- Search mode
		search_mode = {
			{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
			{ key = "c",      mods = "CTRL", action = act.CopyMode("Close") },
			{ key = "h",      mods = "NONE", action = act.CopyMode("Close") },
			{ key = "q",      mods = "NONE", action = act.CopyMode("Close") },
			{ key = "Enter",  mods = "NONE", action = "ActivateCopyMode" },
		},
	}
end

return {
	setup_key_tables = setup_key_tables,
}
