-- WezTerm Event Handlers
local wezterm = require("wezterm")
local utils = require("utils")

-- Tab title formatting
local function format_title(title, is_active, max_width)
	local title_max = max_width - 4 -- 4 is for the bookends "|∙" and "∙|"
	title = title:sub(0, title_max)

	local background = { Background = { Color = "#1f1f28" } }
	local leftover_width = title_max - #title + 2 -- 2 is for the "∙" part of the bookends
	local pad_left_len = math.floor(leftover_width / 2)
	local pad_right_len = leftover_width - pad_left_len

	local padding = " "
	local left_end = "|" .. padding:rep(pad_left_len)
	local right_end = padding:rep(pad_right_len) .. "|"
	local formatted_title = {
		Text = left_end .. title .. right_end,
	}
	if is_active then
		return { background, { Foreground = { Color = "#957fb8" } }, formatted_title }
	else
		return { background, { Foreground = { Color = "#cad3f5" } }, formatted_title }
	end
end

-- Register all event handlers
local function setup_events()
	-- Format tab titles
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		-- if there is title already set, proceed with it
		if type(tab.tab_title) == "string" and #tab.tab_title > 0 then
			return format_title(tab.tab_title, tab.is_active, max_width)
		end

		local title = tab.active_pane.title
		if title == "nvim" then
			title = utils.basename(tab.active_pane.current_working_dir)
		end

		return format_title(title, tab.is_active, max_width)
	end)

	-- Toggle font ligatures
	wezterm.on("toggle-ligatures", function(window, pane)
		local overrides = window:get_config_overrides() or {}
		if not overrides.harfbuzz_features then
			overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
		else
			overrides.harfbuzz_features = nil
		end
		window:set_config_overrides(overrides)
	end)

	-- Toggle transparency
	wezterm.on("toggle-transparency", function(window, pane)
		local overrides = window:get_config_overrides() or {}
		if not overrides.window_background_opacity then
			overrides.window_background_opacity = 1.0
			overrides.text_background_opacity = 1.0
			overrides.macos_window_background_blur = 0
		else
			overrides.window_background_opacity = nil
			overrides.text_background_opacity = nil
			overrides.macos_window_background_blur = nil
		end
		window:set_config_overrides(overrides)
	end)

	-- Update status line with workspace, cwd, process, and time
	wezterm.on("update-status", function(window, pane)
		local key_table = window:active_key_table() or "default"
		window:set_left_status(" " .. key_table .. " ")

		local workspace = window:active_workspace() or ""
		local cwd = utils.basename(pane:get_current_working_dir()) or ""
		local cmd = utils.basename(pane:get_foreground_process_name()) or ""
		local time = wezterm.strftime("%H:%M")

		window:set_right_status(wezterm.format({
			{ Text = "| " },
			{ Text = wezterm.nerdfonts.oct_table .. "  " .. workspace },
			{ Text = " | " },
			{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
			{ Text = " | " },
			{ Foreground = { Color = "FFB86C" } },
			{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
			"ResetAttributes",
			{ Text = " | " },
			{ Text = wezterm.nerdfonts.md_clock .. "  " .. time },
			{ Text = " |" },
		}))
	end)
end

return {
	setup_events = setup_events,
}
