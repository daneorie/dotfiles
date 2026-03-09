-- WezTerm Workspace Management
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

-- Repositories that use bare git repos (worktrees)
local bare_repos = {
	"mtgt",
	"advent-of-code-2023",
	"broski_orie",
	"autoscan",
}

-- Create workspace selector for new workspaces
local function create_workspace_selector()
	return wezterm.action_callback(function(window, pane)
		local home = wezterm.glob(wezterm.home_dir)[1]
		local workspaces = {
			{ id = home .. "/dotfiles||dotfiles",           label = home .. "/dotfiles" },
			{ id = home .. "/wiki||wiki",                   label = home .. "/wiki" },
			{ id = home .. "/repos||repos",                 label = home .. "/repos" },
			{ id = home .. "/.local/share/nvim/lazy||lazy", label = home .. "/.local/share/nvim/lazy" },
		}

		-- Add all GitHub repos except the bare repos (worktrees)
		for _, path in ipairs(wezterm.glob(home .. "/repos/*")) do
			local name = path:gsub(".*/", "")
			if not utils.has_value(bare_repos, name) then
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
				if not utils.has_value(worktree_dirs, name) then
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
						local split_id = utils.split(id, "|")
						local cwd = split_id[1]
						local args = utils.split(split_id[2], " ")
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
	end)
end

-- Create selector for existing workspaces
local function switch_workspace_selector()
	return wezterm.action_callback(function(window, pane)
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
	end)
end

-- Prompt for new workspace name
local function create_new_workspace()
	return act.PromptInputLine({
		description = wezterm.format({
			{ Attribute = { Intensity = "Bold" } },
			{ Foreground = { AnsiColor = "Fuchsia" } },
			{ Text = "Enter name for new workspace" },
		}),
		action = wezterm.action_callback(function(window, pane, line)
			if line then
				window:perform_action(
					act.SwitchToWorkspace({
						name = line,
					}),
					pane
				)
			end
		end),
	})
end

return {
	create_workspace_selector = create_workspace_selector,
	switch_workspace_selector = switch_workspace_selector,
	create_new_workspace = create_new_workspace,
}

