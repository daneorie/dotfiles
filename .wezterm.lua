-- Pull in the wezterm API
local wezterm = require("wezterm")
local session_manager = require("wezterm-session-manager/session-manager")
local act = wezterm.action

-- Full-stack development tabs configuration
local fullstack_tabs = {
	{
		name = "backend",
		cwd = "./stacks/backend/api/lambdas/src",
		command = "v.",
	},
	{
		name = "frontend",
		cwd = "./web",
		command = "v.",
	},
	{
		name = "server",
		cwd = "./web",
		command = "npm run dev:sandbox",
	},
	{
		name = "opencode",
		cwd = ".",
		command = "opencode",
	},
}

-- Session Management
wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "nordfox"
config.window_background_opacity = 0.6
config.text_background_opacity = 0.6
config.macos_window_background_blur = 40
config.enable_kitty_keyboard = true
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false

local bare_repos = {
	"dotfiles",
	"plan-your-day",
	"global-fuelight-refuel-experience",
	"global-fuelight-refuel-experience/feat",
	"sports-fan365-backend",
	"sports-fan365-backend/feature",
	--"sports-fan365-backend-old",
	--"sports-fan365-backend-old/feature",
	"broski_orie",
	"captech-skills",
	"arcolla-backend",
	"arcolla-backend/feature",
	"arcolavfd-web",
	"arcolavfd-web/feature",
	"mtgt",
	--"advent-of-code-2023",
}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_inside_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local function is_outside_vim(pane)
	return not is_inside_vim(pane)
end

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

local format_title = function(title, is_active, max_width)
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

-- Equivalent to POSIX basename(3)
local function basename(s)
	local current_dir = tostring(s)
	if type(s) == "userdata" then
		current_dir = unescape(current_dir)
	end
	return current_dir:gsub("(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- if there is title already set, proceed with it
	if type(tab.tab_title) == "string" and #tab.tab_title > 0 then
		return format_title(tab.tab_title, tab.is_active, max_width)
	end

	local title = tab.active_pane.title
	if title == "nvim" then
		title = basename(tab.active_pane.current_working_dir)
	end

	return format_title(title, tab.is_active, max_width)
end)

wezterm.on("toggle-ligatures", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.harfbuzz_features then
		overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
	else
		overrides.harfbuzz_features = nil
	end
	window:set_config_overrides(overrides)
end)

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

-- Helper function to resolve relative paths
local function resolve_path(cwd, current_pane)
	if cwd:sub(1, 1) == "/" then
		-- Absolute path, return as-is
		return cwd
	elseif cwd:sub(1, 2) == "~/" then
		-- Home directory relative path
		return wezterm.home_dir .. "/" .. cwd:sub(3)
	else
		-- Relative path, combine with current working directory
		local current_cwd = current_pane:get_current_working_dir()
		if current_cwd then
			local current_path = current_cwd.file_path or tostring(current_cwd)
			-- Remove file:// prefix if present
			current_path = current_path:gsub("^file://", "")
			return current_path .. "/" .. cwd
		else
			-- Fallback to home directory if current path unavailable
			return wezterm.home_dir .. "/" .. cwd
		end
	end
end

-- Function to create a new tab at a specific position
local function spawn_tab_at_position(window, pane, position)
	local tab, new_pane, new_window = window:mux_window():spawn_tab({
		cwd = pane:get_current_working_dir(),
	})

	-- Move the new tab to the specified position
	local tabs = window:mux_window():tabs()
	local new_tab_index = #tabs - 1 -- New tab is at the end, 0-indexed

	-- If position is beyond current tabs, just leave it at the end
	if position >= #tabs then
		return
	end

	-- Move the tab to the desired position by swapping
	for i = new_tab_index, position + 1, -1 do
		window:perform_action(act.MoveTab(i - 1), pane)
	end
end

-- Function to move current tab left (swap with previous tab)
local function move_tab_left(window, pane)
	local current_tab_index = window:active_tab():tab_id()
	local tabs = window:mux_window():tabs()

	-- Find the current tab's position in the tabs array
	local current_position = nil
	for i, tab in ipairs(tabs) do
		if tab:tab_id() == current_tab_index then
			current_position = i - 1 -- Convert to 0-indexed
			break
		end
	end

	-- Move left if not at the beginning
	if current_position and current_position > 0 then
		window:perform_action(act.MoveTab(current_position - 1), pane)
	end
end

-- Function to move current tab right (swap with next tab)
local function move_tab_right(window, pane)
	local current_tab_index = window:active_tab():tab_id()
	local tabs = window:mux_window():tabs()

	-- Find the current tab's position in the tabs array
	local current_position = nil
	for i, tab in ipairs(tabs) do
		if tab:tab_id() == current_tab_index then
			current_position = i - 1 -- Convert to 0-indexed
			break
		end
	end

	-- Move right if not at the end
	if current_position and current_position < #tabs - 1 then
		window:perform_action(act.MoveTab(current_position + 1), pane)
	end
end

-- Setup full-stack development tabs
wezterm.on("setup-fullstack-tabs", function(window, pane)
	-- Check if tabs already exist to prevent duplicates
	local tabs = window:mux_window():tabs()
	local existing_tab_names = {}

	for _, tab in ipairs(tabs) do
		if tab:get_title() then
			existing_tab_names[tab:get_title()] = true
		end
	end

	-- Check if any of our target tabs already exist
	local has_existing_tabs = false
	for _, tab_config in ipairs(fullstack_tabs) do
		if existing_tab_names[tab_config.name] then
			has_existing_tabs = true
			break
		end
	end

	-- If setup already exists, do nothing
	if has_existing_tabs then
		wezterm.log_info("Full-stack tabs already exist, skipping setup")
		return
	end

	-- Create each tab with its configuration
	for i, tab_config in ipairs(fullstack_tabs) do
		local resolved_cwd = resolve_path(tab_config.cwd, pane)
		local tab, new_pane, new_window = window:mux_window():spawn_tab({
			cwd = resolved_cwd,
		})

		-- Set the tab title
		tab:set_title(tab_config.name)

		-- Send the command to the new pane
		if tab_config.command then
			new_pane:send_text(tab_config.command .. "\n")
		end

		wezterm.log_info("Created tab: " .. tab_config.name .. " in " .. resolved_cwd)
	end

	-- Switch back to the first tab
	window:perform_action(act.ActivateTab(0), pane)
end)

wezterm.on("update-status", function(window, pane)
	local key_table = window:active_key_table() or "default"
	window:set_left_status(" " .. key_table .. " ")

	local workspace = window:active_workspace() or ""
	local cwd = basename(pane:get_current_working_dir()) or ""
	local cmd = basename(pane:get_foreground_process_name()) or ""
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

local SUPER, META
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	SUPER = "META"
	META = "SUPER"
	config.window_background_opacity = 0.8
	config.text_background_opacity = 0.8
	config.default_domain = "WSL:Ubuntu"
	config.warn_about_missing_glyphs = false
	config.allow_win32_input_mode = false
else
	SUPER = "SUPER"
	META = "META"
end

config.leader = { key = "Space", mods = META }
config.keys = {
	-- LEADER
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "l", mods = "LEADER", action = act.EmitEvent("toggle-ligatures") },
	{ key = "t", mods = "LEADER", action = act.EmitEvent("toggle-transparency") },
	{ key = "f", mods = "LEADER", action = act.EmitEvent("setup-fullstack-tabs") },
	{ key = "s", mods = "LEADER|SHIFT", action = wezterm.action({ EmitEvent = "save_session" }) },
	{ key = "l", mods = "LEADER|SHIFT", action = wezterm.action({ EmitEvent = "load_session" }) },
	{ key = "r", mods = "LEADER|SHIFT", action = wezterm.action({ EmitEvent = "restore_session" }) },

	-- basic usage
	{ key = "c", mods = SUPER, action = act.CopyTo("Clipboard") },
	{ key = "v", mods = SUPER, action = act.PasteFrom("Clipboard") },
	{ key = "q", mods = SUPER, action = act.QuitApplication },
	{ key = "n", mods = SUPER .. "|SHIFT", action = act.SpawnWindow },
	{ key = "n", mods = SUPER .. "|" .. META, action = act.SwitchToWorkspace },
	{ key = "Enter", mods = SUPER, action = act.ActivateCopyMode },

	-- wezterm navigation
	{ key = "[", mods = SUPER, action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = SUPER, action = act.ActivateTabRelative(1) },
	{ key = "6", mods = "CTRL", action = act.ActivateLastTab },
	{ key = "d", mods = SUPER, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = SUPER .. "|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = SUPER, action = act.CloseCurrentPane({ confirm = true }) },
	-- Tab management
	{ key = "t", mods = SUPER, action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "{", mods = SUPER .. "|SHIFT", action = wezterm.action_callback(move_tab_left) },
	{ key = "}", mods = SUPER .. "|SHIFT", action = wezterm.action_callback(move_tab_right) },

	-- Create new tab at specific position (Cmd+Shift+Number)
	{
		key = "1",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 0)
		end),
	},
	{
		key = "2",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 1)
		end),
	},
	{
		key = "3",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 2)
		end),
	},
	{
		key = "4",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 3)
		end),
	},
	{
		key = "5",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 4)
		end),
	},
	{
		key = "6",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 5)
		end),
	},
	{
		key = "7",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 6)
		end),
	},
	{
		key = "8",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 7)
		end),
	},
	{
		key = "9",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 8)
		end),
	},
	{
		key = "0",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			spawn_tab_at_position(window, pane, 9)
		end),
	},
	{ key = "LeftArrow", mods = SUPER, action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "DownArrow", mods = SUPER, action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = SUPER, action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "RightArrow", mods = SUPER, action = act.AdjustPaneSize({ "Right", 5 }) },

	-- Wezterm & NeoVim Pane Navigation
	bind_if(is_outside_vim, "n", "CTRL", act.ActivatePaneDirection("Left")),
	bind_if(is_outside_vim, "e", "CTRL", act.ActivatePaneDirection("Down")),
	bind_if(is_outside_vim, "i", "CTRL", act.ActivatePaneDirection("Up"), "\x33[105;5u"),
	bind_if(is_outside_vim, "o", "CTRL", act.ActivatePaneDirection("Right")),

	-- 5u - ctrl -- these overlaps require \x33 instead of \x1b, which will need to be interpretted by NeoVim
	{ key = "[", mods = "CTRL", action = act.SendString("\x33[91;5u") }, -- ctrl-[ - overlaps ESC
	{ key = "h", mods = "CTRL", action = act.SendString("\x33[104;5u") }, -- ctrl-h - overlaps BS/Backspace
	--{ key = "i", mods = "CTRL", action = act.SendString("\x33[105;5u") }, -- ctrl-i - overlaps TAB
	{ key = "m", mods = "CTRL", action = act.SendString("\x33[109;5u") }, -- ctrl-m - overlaps CR/Enter

	{ key = ";", mods = SUPER, action = act.SendString("\x1b;") },
	{ key = "a", mods = SUPER, action = act.SendString("\x1ba") },
	{ key = "b", mods = SUPER, action = act.SendString("\x1bb") },
	--{ key = "c", mods = SUPER, action = act.SendString("\x1bc") },
	--{ key = "d", mods = SUPER, action = act.SendString("\x1bd") },
	{ key = "e", mods = SUPER, action = act.SendString("\x1be") },
	{ key = "f", mods = SUPER, action = act.SendString("\x1bf") },
	{ key = "g", mods = SUPER, action = act.SendString("\x1bg") },
	{ key = "h", mods = SUPER, action = act.SendString("\x1bh") },
	{ key = "i", mods = SUPER, action = act.SendString("\x1bi") },
	{ key = "j", mods = SUPER, action = act.SendString("\x1bj") },
	{ key = "k", mods = SUPER, action = act.SendString("\x1bk") },
	{ key = "l", mods = SUPER, action = act.SendString("\x1bl") },
	{ key = "m", mods = SUPER, action = act.SendString("\x1bm") },
	{ key = "n", mods = SUPER, action = act.SendString("\x1bn") },
	{ key = "o", mods = SUPER, action = act.SendString("\x1bo") },
	{ key = "p", mods = SUPER, action = act.SendString("\x1bp") },
	--{ key = "q", mods = SUPER, action = act.SendString("\x1bq") },
	{ key = "r", mods = SUPER, action = act.SendString("\x1br") },
	{ key = "s", mods = SUPER, action = act.SendString("\x1bs") },
	--{ key = "t", mods = SUPER, action = act.SendString("\x1bt") },
	{ key = "u", mods = SUPER, action = act.SendString("\x1bu") },
	--{ key = "v", mods = SUPER, action = act.SendString("\x1bv") },
	--{ key = "w", mods = SUPER, action = act.SendString("\x1bw") },
	{ key = "x", mods = SUPER, action = act.SendString("\x1bx") },
	{ key = "y", mods = SUPER, action = act.SendString("\x1by") },
	{ key = "z", mods = SUPER, action = act.SendString("\x1bz") },

	-- Prompt for a name to use for a new workspace and switch to it.
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},

	-- rename the tab
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- switch between a list of workspaces
	{
		key = "s",
		mods = SUPER .. "|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local home = wezterm.glob(wezterm.home_dir)[1]
			local workspaces = {
				{ id = home .. "/dotfiles||dotfiles", label = home .. "/dotfiles" },
				{ id = home .. "/wiki||wiki", label = home .. "/wiki" },
				{ id = home .. "/repos||repos", label = home .. "/repos" },
				{
					id = "|ssh -i ~/.ssh/personal.rsa daneorie@macbook-pro.local|personal",
					label = "ssh macbook-pro.local",
				},
			}

			-- Add all GitHub repos except the bare repos (worktrees)
			for _, path in ipairs(wezterm.glob(home .. "/repos/*")) do
				local name = path:gsub(".*/", "")
				if not has_value(bare_repos, name) then
					table.insert(workspaces, {
						id = path .. "||" .. path:gsub(home .. "/", ""),
						label = path,
					})
				end
			end

			local worktree_dirs = {
				"HEAD",
				"config",
				"description",
				"hooks",
				"info",
				"logs",
				"objects",
				"packed-refs",
				"refs",
				"worktrees",
			}

			for _, dir in ipairs(bare_repos) do
				for _, path in ipairs(wezterm.glob(home .. "/repos/" .. dir .. "/*")) do
					local name = path:gsub(".*/", "")
					if not has_value(worktree_dirs, name) then
						table.insert(workspaces, {
							id = path .. "||" .. path:gsub(home .. "/repos/", ""),
							label = path,
						})
					end
				end
			end

			window:perform_action(
				act.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id and not label then
							wezterm.log_info("cancelled")
						else
							local split_id = split(id, "|")
							local cwd = split_id[1]
							local args = split(split_id[2], " ")
							local name = split_id[3]
							wezterm.log_info("label = " .. label)
							wezterm.log_info("cwd = " .. cwd)
							for index, arg in ipairs(args) do
								wezterm.log_info("arg#" .. index .. " = " .. tostring(arg))
							end
							wezterm.log_info("name = " .. name)
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = name,
									spawn = {
										label = "Workspace: " .. label,
										args = args,
										cwd = cwd,
									},
								}),
								inner_pane
							)
						end
					end),
					title = "Choose Workspace",
					choices = workspaces,
					fuzzy = true,
				}),
				pane
			)
		end),
	},

	-- switch between open workspaces
	{
		key = "s",
		mods = SUPER .. "|CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local workspaces = {}
			local workspace_names = wezterm.mux.get_workspace_names()
			for _, workspace in ipairs(workspace_names) do
				table.insert(workspaces, {
					id = workspace,
					label = workspace,
				})
			end
			wezterm.log_info(workspaces)
			window:perform_action(
				act.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
						if not id and not label then
							wezterm.log_info("cancelled")
						else
							wezterm.log_info("label = " .. label)
							wezterm.log_info("name = " .. id)
							inner_window:perform_action(
								act.SwitchToWorkspace({
									name = id,
									spawn = {
										label = "Workspace: " .. label,
									},
								}),
								inner_pane
							)
						end
					end),
					title = "Choose Workspace",
					choices = workspaces,
					fuzzy = true,
				}),
				pane
			)
		end),
	},
}

for i = 1, 10 do
	-- SUPER + number to activate that numbered tab
	table.insert(config.keys, {
		key = tostring(i % 10),
		mods = SUPER,
		action = act.ActivateTab(i - 1),
	})
end

function split(inputstr, sep)
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

function has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function hex_to_char(x)
	return string.char(tonumber(x, 16))
end

function unescape(url)
	return url:gsub("%%(%x%x)", hex_to_char)
end

function map(things)
	local t = {}
	for key in things:gmatch("([^,]+)") do
		table.insert(t, act.SendKey({ key = key }))
	end
	return t
end

config.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "n", mods = "NONE", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "n", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },

		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "e", mods = "NONE", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "e", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },

		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "i", mods = "NONE", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "i", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },

		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "o", mods = "NONE", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "o", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

		-- Neovim panes
		--map({ "n", "v", "i" }, "<A-Left>", ":vertical resize -2<CR>") -- decrease width
		{ key = "m", mods = "NONE", action = act.Multiple(map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,-,1,Enter")) },
		{ key = "m", mods = "SHIFT", action = act.Multiple(map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,-,5,Enter")) },

		--map({ "n", "v", "i" }, "<A-Down>", ":resize -2<CR>") -- decrease height
		{ key = ",", mods = "NONE", action = act.Multiple(map("Escape,:,r,e,s,i,z,e, ,-,1,Enter")) },
		{ key = "<", mods = "SHIFT", action = act.Multiple(map("Escape,:,r,e,s,i,z,e, ,-,5,Enter")) },

		--map({ "n", "v", "i" }, "<A-Up>", ":resize +2<CR>") -- increase height
		{ key = ".", mods = "NONE", action = act.Multiple(map("Escape,:,r,e,s,i,z,e, ,+,1,Enter")) },
		{ key = ">", mods = "SHIFT", action = act.Multiple(map("Escape,:,r,e,s,i,z,e, ,+,5,Enter")) },

		--map({ "n", "v", "i" }, "<A-Right>", ":vertical resize +2<CR>") -- increase width
		{ key = "/", mods = "NONE", action = act.Multiple(map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,+,1,Enter")) },
		{ key = "?", mods = "SHIFT", action = act.Multiple(map("Escape,:,v,e,r,t,i,c,a,l, ,r,e,s,i,z,e, ,+,5,Enter")) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
	copy_mode = {
		{ key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "/", mods = "NONE", action = act.Search({ CaseSensitiveString = "" }) },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "N", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "N", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "K", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "K", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "a", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = META, action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "f", mods = META, action = act.CopyMode("MoveForwardWord") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "g", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "h", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
		{ key = "n", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "i", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = ",", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = ".", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "y", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		{ key = "m", mods = META, action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "LeftArrow", mods = META, action = act.CopyMode("MoveBackwardWord") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "RightArrow", mods = META, action = act.CopyMode("MoveForwardWord") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
	},
	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "h", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "Enter", mods = "NONE", action = "ActivateCopyMode" },
	},
}

-- and finally, return the configuration to wezterm
return config
