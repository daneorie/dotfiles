local M = {}

local Terminal = require("toggleterm.terminal").Terminal
local ts_utils = require("nvim-treesitter.ts_utils")

local function get_vitest_command(args)
	args = args or ""
	return "npx vitest " .. args
end

local function run_vitest_in_terminal(args)
	local cmd = get_vitest_command(args)
	local vitest_terminal = Terminal:new({
		cmd = cmd,
		direction = "tab",
		close_on_exit = false,
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
	})
	vitest_terminal:open()
end

function M.run_all_tests()
	run_vitest_in_terminal("run")
end

function M.run_current_file()
	local current_file = vim.fn.expand("%:p")
	if current_file:match("%.test%.[jt]sx?$") or current_file:match("%.spec%.[jt]sx?$") then
		run_vitest_in_terminal("run " .. vim.fn.shellescape(current_file))
	else
		vim.notify("Current file is not a test file", vim.log.levels.WARN)
	end
end

function M.run_nearest_test()
	local current_file = vim.fn.expand("%:p")
	if not current_file:match("%.test%.[jt]sx?$") and not current_file:match("%.spec%.[jt]sx?$") then
		vim.notify("Current file is not a test file", vim.log.levels.WARN)
		return
	end

	local current_node = ts_utils.get_node_at_cursor()
	while current_node do
		-- Check if the node is a call_expression
		if current_node:type() == "call_expression" then
			local first_child = current_node:named_child(0)
			if first_child and first_child:type() == "identifier" then
				local func_name = vim.treesitter.get_node_text(first_child, vim.api.nvim_get_current_buf())
				-- Adjust these names based on your test framework usage.
				if func_name == "test" or func_name == "it" then
					-- Optionally, extract the test description from the arguments.
					local test_desc = "Unknown"
					-- Many test definitions have a string as the first argument.
					local arg_node = current_node:named_child(1)
					if arg_node then
						local first_arg = arg_node:named_child(0)
						if first_arg then
							test_desc = vim.treesitter.get_node_text(first_arg, vim.api.nvim_get_current_buf())
						end
					end
					run_vitest_in_terminal(
						"run " .. vim.fn.shellescape(current_file) .. " --testNamePattern=" .. test_desc
					)
				end
			end
		end
		current_node = current_node:parent()
	end
end

function M.watch_tests()
	run_vitest_in_terminal("")
end

function M.watch_current_file()
	local current_file = vim.fn.expand("%:p")
	if current_file:match("%.test%.[jt]sx?$") or current_file:match("%.spec%.[jt]sx?$") then
		run_vitest_in_terminal(vim.fn.shellescape(current_file))
	else
		vim.notify("Current file is not a test file", vim.log.levels.WARN)
	end
end

function M.run_failed_tests()
	run_vitest_in_terminal("run --reporter=verbose --run")
end

function M.javascript_runner()
	local options = {
		"Run All Tests",
		"Run Current File",
		"Run Nearest Test",
		"Watch All Tests",
		"Watch Current File",
		"Run Failed Tests",
	}

	vim.ui.select(options, {
		prompt = "Select Vitest Action:",
	}, function(choice)
		if choice == "Run All Tests" then
			M.run_all_tests()
		elseif choice == "Run Current File" then
			M.run_current_file()
		elseif choice == "Run Nearest Test" then
			M.run_nearest_test()
		elseif choice == "Watch All Tests" then
			M.watch_tests()
		elseif choice == "Watch Current File" then
			M.watch_current_file()
		elseif choice == "Run Failed Tests" then
			M.run_failed_tests()
		end
	end)
end

return M
