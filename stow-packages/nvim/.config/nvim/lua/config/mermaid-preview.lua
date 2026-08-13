local M = {}

-- Configuration
M.config = {
	markdown_mode = "cursor", -- "cursor" | "all"
}

-- Persistent state
M._wezterm_pane_id = nil  -- Store the WezTerm pane ID for the preview
M._temp_path = nil
M._autocmd_group = nil
M._original_bufnr = nil  -- Track which buffer opened the pane

--- Extracts the mermaid block under the cursor in a markdown file
--- Returns a table of lines
local function extract_cursor_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Find opening fence (backward from cursor)
	local start_line = nil
	for i = cursor_line, 1, -1 do
		if lines[i]:match("^%s*```%s*mermaid") then
			start_line = i
			break
		end
	end

	if not start_line then
		vim.notify("No mermaid block found before cursor", vim.log.levels.WARN)
		return nil
	end

	-- Find closing fence (forward from cursor)
	local end_line = nil
	for i = cursor_line, #lines do
		if i > start_line and lines[i]:match("^%s*```%s*$") then
			end_line = i
			break
		end
	end

	if not end_line then
		vim.notify("No closing fence found after cursor", vim.log.levels.WARN)
		return nil
	end

	-- Extract the mermaid content (excluding the fences)
	local mermaid_lines = {}
	for i = start_line + 1, end_line - 1 do
		table.insert(mermaid_lines, lines[i])
	end

	if #mermaid_lines == 0 then
		vim.notify("Mermaid block is empty", vim.log.levels.WARN)
		return nil
	end

	return mermaid_lines
end

--- Extracts all mermaid blocks from a markdown file
--- Returns a list of { lines = {...}, index = 1, 2, 3, ... }
local function extract_all_blocks()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local blocks = {}
	local i = 1

	while i <= #lines do
		if lines[i]:match("^%s*```%s*mermaid") then
			local start_line = i
			local block_lines = {}

			-- Find closing fence
			i = i + 1
			while i <= #lines and not lines[i]:match("^%s*```%s*$") do
				table.insert(block_lines, lines[i])
				i = i + 1
			end

			if #block_lines > 0 then
				table.insert(blocks, {
					lines = block_lines,
					index = #blocks + 1,
				})
			end
		end
		i = i + 1
	end

	if #blocks == 0 then
		vim.notify("No mermaid blocks found in this file", vim.log.levels.WARN)
		return nil
	end

	return blocks
end

--- Gets the pixel width of a WezTerm pane by ID
local function get_pane_pixel_width(pane_id)
	local handle = io.popen("wezterm cli list --format json 2>/dev/null")
	if not handle then return nil end
	local json = handle:read("*a")
	handle:close()
	-- JSON structure: { "pane_id": N, ..., "size": { "pixel_width": N, ... } }
	-- Find the size block that follows the matching pane_id
	local pane_section = json:match('"pane_id"%s*:%s*' .. pane_id .. '.-"size"%s*:%s*{(.-)}')
	if not pane_section then return nil end
	local px = pane_section:match('"pixel_width"%s*:%s*(%d+)')
	return px and tonumber(px) or nil
end

--- Renders and displays the diagram in the WezTerm pane
local function render_and_display()
	if not M._wezterm_pane_id then
		vim.notify("Preview pane is not open", vim.log.levels.WARN)
		return
	end

	-- Get actual pane pixel width for full-width, crisp rendering
	local px = get_pane_pixel_width(M._wezterm_pane_id) or 1200

	-- Run mmdc synchronously to render the diagram at full pane width
	local tmp_path = "/tmp/mermaid_preview.mmd"
	local output_path = "/tmp/mermaid_preview.png"
	local cmd = string.format(
		"mmdc -i %s -o %s -w %d 2>&1",
		vim.fn.shellescape(tmp_path), vim.fn.shellescape(output_path), px
	)
	
	local result = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		-- Error during rendering - send error to pane
		local error_cmd = string.format(
			"wezterm cli send-text --pane-id %s --no-paste 'clear; echo \"Error rendering diagram:\"\n'",
			M._wezterm_pane_id
		)
		os.execute(error_cmd)
		for line in vim.gsplit(result, "\n") do
			local escaped = line:gsub("'", "'\\''")
			local error_line_cmd = string.format(
				"wezterm cli send-text --pane-id %s --no-paste 'echo %s\n'",
				M._wezterm_pane_id,
				vim.fn.shellescape(escaped)
			)
			os.execute(error_line_cmd)
		end
		return
	end

	-- Check if output file exists
	if vim.fn.filereadable(output_path) == 0 then
		local error_cmd = string.format(
			"wezterm cli send-text --pane-id %s --no-paste 'clear; echo \"Error: mmdc did not produce output file\"\n'",
			M._wezterm_pane_id
		)
		os.execute(error_cmd)
		return
	end

	-- Display the image at full pane width; px suffix tells imgcat to use exact pixels
	local display_cmd = string.format(
		"wezterm cli send-text --pane-id %s --no-paste 'clear; wezterm imgcat --width %dpx %s\n'",
		M._wezterm_pane_id,
		px,
		vim.fn.shellescape(output_path)
	)
	os.execute(display_cmd)
end

--- Opens or reuses the mermaid preview pane in WezTerm
local function open_pane()
	-- If pane already exists, show it and render
	if M._wezterm_pane_id then
		-- Make pane visible and active
		os.execute(string.format("wezterm cli activate-pane --pane-id %s", M._wezterm_pane_id))
		-- Render the diagram in the existing pane
		vim.schedule(render_and_display)
		return
	end

	-- Get current WezTerm window ID and tab ID
	-- WEZTERM_PANE env var is set by WezTerm for processes running inside it
	local pane_id = os.getenv("WEZTERM_PANE")
	if not pane_id or pane_id == "" then
		vim.notify("Not running inside WezTerm or WEZTERM_PANE not set", vim.log.levels.ERROR)
		return
	end

	-- Split the current pane vertically (50% width)
	-- Capture the output to get the new pane ID
	local split_cmd = string.format(
		"wezterm cli split-pane --pane-id %s --horizontal --percent 50",
		pane_id
	)
	local handle = io.popen(split_cmd)
	local output = handle:read("*a")
	handle:close()

	-- Extract pane ID from output (just a bare integer)
	local new_pane_id = output:match("(%d+)")
	if not new_pane_id then
		vim.notify("Failed to create WezTerm split pane", vim.log.levels.ERROR)
		return
	end

	M._wezterm_pane_id = new_pane_id

	M._original_bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(M._original_bufnr, "filetype")

	-- Create unique autocmd group for this session
	M._autocmd_group = "mermaid_preview_" .. M._original_bufnr
	vim.api.nvim_create_augroup(M._autocmd_group, { clear = true })

	-- Set up autocmd to write temp file and render on buffer write
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = M._autocmd_group,
		buffer = M._original_bufnr,
		callback = function()
			local tmp_path = "/tmp/mermaid_preview.mmd"
			
			-- Write the relevant content to temp file
			if ft == "mermaid" then
				-- For .mmd files: write the entire buffer
				local current_lines = vim.api.nvim_buf_get_lines(M._original_bufnr, 0, -1, false)
				local content = table.concat(current_lines, "\n")
				local file = io.open(tmp_path, "w")
				if file then
					file:write(content)
					file:close()
				end
			else
				-- For markdown files: extract cursor block
				local block_lines = extract_cursor_block()
				if block_lines then
					local content = table.concat(block_lines, "\n")
					local file = io.open(tmp_path, "w")
					if file then
						file:write(content)
						file:close()
					end
				end
			end

			-- Render and display
			render_and_display()
		end,
	})

	-- Do an immediate first render
	vim.schedule(function()
		-- Write initial content and render
		local tmp_path = "/tmp/mermaid_preview.mmd"
		if ft == "mermaid" then
			local current_lines = vim.api.nvim_buf_get_lines(M._original_bufnr, 0, -1, false)
			local content = table.concat(current_lines, "\n")
			local file = io.open(tmp_path, "w")
			if file then
				file:write(content)
				file:close()
			end
		else
			local block_lines = extract_cursor_block()
			if block_lines then
				local content = table.concat(block_lines, "\n")
				local file = io.open(tmp_path, "w")
				if file then
					file:write(content)
					file:close()
				end
			end
		end
		render_and_display()
	end)
end

--- Closes the preview pane and cleans up
local function close_pane()
	if M._wezterm_pane_id then
		-- Close the WezTerm pane
		os.execute(string.format("wezterm cli close-pane --pane-id %s", M._wezterm_pane_id))
		M._wezterm_pane_id = nil
	end

	if M._autocmd_group then
		vim.api.nvim_del_augroup_by_name(M._autocmd_group)
		M._autocmd_group = nil
	end

	M._temp_path = nil
	M._original_bufnr = nil
end

--- Main toggle function: entry point for <leader>mp
function M.toggle()
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

	-- Only works for markdown and mermaid filetypes
	if ft ~= "markdown" and ft ~= "mermaid" then
		vim.notify("Mermaid preview only works in markdown or mermaid files", vim.log.levels.WARN)
		return
	end

	-- If pane is already open, close it
	if M._term then
		close_pane()
		return
	end

	-- Open the pane (which will do initial render)
	open_pane()

	vim.notify("Mermaid preview opened. Edit and save to update. Press <leader>mp to close.", vim.log.levels.INFO)
end

--- Health check: verify dependencies are installed
function M.check_health()
	local checks = {
		{ "mmdc", "mermaid CLI" },
		{ "watchexec", "file watcher" },
		{ "wezterm", "terminal" },
	}

	local ok_count = 0
	for _, check in ipairs(checks) do
		local cmd, name = check[1], check[2]
		local result = os.execute("which " .. cmd .. " > /dev/null 2>&1")
		if result == 0 or result == true then
			vim.notify("✓ " .. name .. " (" .. cmd .. ") is installed", vim.log.levels.INFO)
			ok_count = ok_count + 1
		else
			vim.notify("✗ " .. name .. " (" .. cmd .. ") is NOT installed", vim.log.levels.ERROR)
		end
	end

	if ok_count == #checks then
		vim.notify("All dependencies are available!", vim.log.levels.INFO)
	else
		vim.notify(
			"Some dependencies are missing. Mermaid preview may not work correctly.",
			vim.log.levels.WARN
		)
	end
end

return M
