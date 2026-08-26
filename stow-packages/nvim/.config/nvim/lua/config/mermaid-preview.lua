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

--- Gets dimensions of a WezTerm pane by ID
--- Returns { px_width, px_height, rows, cols } or nil
local function get_pane_dims(pane_id)
	local handle = io.popen("wezterm cli list --format json 2>/dev/null")
	if not handle then return nil end
	local json = handle:read("*a")
	handle:close()
	-- JSON structure: { "pane_id": N, ..., "size": { "rows": N, "cols": N, "pixel_width": N, "pixel_height": N } }
	local size_block = json:match('"pane_id"%s*:%s*' .. pane_id .. '.-"size"%s*:%s*{(.-)}')
	if not size_block then return nil end
	local function extract(key)
		local v = size_block:match('"' .. key .. '"%s*:%s*(%d+)')
		return v and tonumber(v) or nil
	end
	local pw = extract("pixel_width")
	local ph = extract("pixel_height")
	local rows = extract("rows")
	local cols = extract("cols")
	if not (pw and ph and rows and cols) then return nil end
	return { px_width = pw, px_height = ph, rows = rows, cols = cols }
end

--- Gets the pixel height of a PNG by reading its header
local function get_png_height(path)
	-- PNG height is a big-endian uint32 at bytes 20-23
	local result = vim.fn.system(
		"python3 -c \"import struct; d=open('" .. path .. "','rb').read(); print(struct.unpack('>I',d[20:24])[0])\""
	)
	local h = tonumber(result:match("%d+"))
	return h
end

--- Renders and displays the diagram in the WezTerm pane
local function render_and_display()
	if not M._wezterm_pane_id then
		vim.notify("Preview pane is not open", vim.log.levels.WARN)
		return
	end

	-- Get actual pane dimensions for full-width, crisp rendering + vertical centering
	local dims = get_pane_dims(M._wezterm_pane_id) or { px_width = 1200, px_height = 800, rows = 40, cols = 120 }
	local px = dims.px_width
	local ph = dims.px_height
	local rows = dims.rows

	-- Run mmdc synchronously to render the diagram at full pane width
	local tmp_path = "/tmp/mermaid_preview.mmd"
	local output_path = "/tmp/mermaid_preview.png"
	local cmd = string.format(
		"mmdc -i %s -o %s -w %d 2>&1",
		vim.fn.shellescape(tmp_path), vim.fn.shellescape(output_path), px
	)
	
	local result = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		-- Error during rendering - send error to pane via script
		local error_script = "/tmp/mermaid_display.sh"
		local script_file = io.open(error_script, "w")
		if script_file then
			script_file:write("#!/bin/bash\n")
			script_file:write("clear\n")
			script_file:write("echo 'Error rendering diagram:'\n")
			for line in vim.gsplit(result, "\n") do
				script_file:write(string.format("echo %s\n", vim.fn.shellescape(line)))
			end
			script_file:close()
		end
		os.execute("chmod +x " .. error_script)
		os.execute(string.format("wezterm cli send-text --pane-id %s --no-paste 'bash %s\n'", M._wezterm_pane_id, error_script))
		return
	end

	-- Check if output file exists
	if vim.fn.filereadable(output_path) == 0 then
		local error_script = "/tmp/mermaid_display.sh"
		local script_file = io.open(error_script, "w")
		if script_file then
			script_file:write("#!/bin/bash\n")
			script_file:write("clear\n")
			script_file:write("echo 'Error: mmdc did not produce output file'\n")
			script_file:close()
		end
		os.execute("chmod +x " .. error_script)
		os.execute(string.format("wezterm cli send-text --pane-id %s --no-paste 'bash %s\n'", M._wezterm_pane_id, error_script))
		return
	end

	-- Calculate vertical padding for centering
	local png_height = get_png_height(output_path)
	local top_padding = 0
	if png_height then
		-- Cell height in pixels = pane pixel height / pane rows
		local cell_height = ph / rows
		local image_rows = math.ceil(png_height / cell_height)
		top_padding = math.max(0, math.floor((rows - image_rows) / 2))
	end

	-- Write display script to avoid quoting hell
	local display_script = "/tmp/mermaid_display.sh"
	local script_file = io.open(display_script, "w")
	if script_file then
		script_file:write("#!/bin/bash\n")
		script_file:write("clear\n")
		-- Add blank lines for vertical centering (each printf '\n' outputs one newline)
		if top_padding > 0 then
			script_file:write(string.rep("printf '\\n'\n", top_padding))
		end
		-- Show the image
		script_file:write(string.format("wezterm imgcat --width %dpx %s\n", px, vim.fn.shellescape(output_path)))
		-- Hide the trailing prompt line
		script_file:write("printf '\\033[1A\\033[2K'\n")
		script_file:close()
	end
	os.execute("chmod +x " .. display_script)
	os.execute(string.format("wezterm cli send-text --pane-id %s --no-paste 'bash %s\n'", M._wezterm_pane_id, display_script))
end

--- Preprocesses a markdown file: renders mermaid fences to PNGs and replaces them with image links
--- Returns the preprocessed markdown content as a string
local function preprocess_markdown(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local output = {}
	local i = 1
	local block_count = 0

	while i <= #lines do
		-- Check for mermaid fence
		if lines[i]:match("^%s*```%s*mermaid") then
			block_count = block_count + 1
			local start_line = i
			local mermaid_lines = {}

			-- Extract mermaid content (excluding fences)
			i = i + 1
			while i <= #lines and not lines[i]:match("^%s*```%s*$") do
				table.insert(mermaid_lines, lines[i])
				i = i + 1
			end

			-- Render mermaid to PNG
			if #mermaid_lines > 0 then
				local mermaid_content = table.concat(mermaid_lines, "\n")
				local png_path = string.format("/tmp/mermaid_block_%d.png", block_count)
				local mmd_path = string.format("/tmp/mermaid_block_%d.mmd", block_count)

				-- Write mermaid content to temp file
				local mmd_file = io.open(mmd_path, "w")
				if mmd_file then
					mmd_file:write(mermaid_content)
					mmd_file:close()
				end

				-- Render with mmdc (use a reasonable default width if pane dims unavailable)
				local cmd = string.format(
					"mmdc -i %s -o %s -w 1000 2>/dev/null",
					vim.fn.shellescape(mmd_path), vim.fn.shellescape(png_path)
				)
				os.execute(cmd)

				-- Replace the mermaid fence with an image link
				table.insert(output, "")
				table.insert(output, string.format("![Diagram %d](%s)", block_count, png_path))
				table.insert(output, "")
			end

			-- Skip the closing fence
			i = i + 1
		else
			-- Regular line, copy to output
			table.insert(output, lines[i])
			i = i + 1
		end
	end

	return table.concat(output, "\n")
end

--- Opens or reuses the markdown preview pane in WezTerm with mdcat
local function open_pane_markdown()
	-- If pane already exists, reuse it
	if M._wezterm_pane_id then
		os.execute(string.format("wezterm cli activate-pane --pane-id %s", M._wezterm_pane_id))
		return
	end

	-- Get current WezTerm pane ID
	local pane_id = os.getenv("WEZTERM_PANE")
	if not pane_id or pane_id == "" then
		vim.notify("Not running inside WezTerm or WEZTERM_PANE not set", vim.log.levels.ERROR)
		return
	end

	-- Get pane dimensions for column calculation
	local dims = get_pane_dims(pane_id) or { cols = 120 }

	-- Split the pane with a clean zsh shell
	local split_cmd = string.format(
		"wezterm cli split-pane --pane-id %s --horizontal --percent 50 -- zsh --no-rcs",
		pane_id
	)
	local handle = io.popen(split_cmd)
	local output = handle:read("*a")
	handle:close()

	local new_pane_id = output:match("(%d+)")
	if not new_pane_id then
		vim.notify("Failed to create WezTerm split pane", vim.log.levels.ERROR)
		return
	end

	M._wezterm_pane_id = new_pane_id

	-- Clear prompt and prepare pane
	os.execute(string.format(
		"printf \"PS1=''\\nclear\\n\" | wezterm cli send-text --pane-id %s --no-paste",
		M._wezterm_pane_id
	))

	-- Return focus to NeoVim pane
	os.execute(string.format(
		"wezterm cli activate-pane --pane-id %s",
		pane_id
	))

	M._original_bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(M._original_bufnr, "filetype")

	-- Create unique autocmd group
	M._autocmd_group = "mermaid_preview_" .. M._original_bufnr
	vim.api.nvim_create_augroup(M._autocmd_group, { clear = true })

	-- Do initial preprocess and write temp file
	local tmp_path = "/tmp/mermaid_preview_rendered.md"
	local preprocessed = preprocess_markdown(M._original_bufnr)
	local file = io.open(tmp_path, "w")
	if file then
		file:write(preprocessed)
		file:close()
	end

	-- Start mdcat --watch in the pane
	-- Use printf piped to send-text so the \n becomes a real newline
	os.execute(string.format(
		"printf 'mdcat --watch --image-protocol iterm2 --margin /tmp/mermaid_preview_rendered.md\\n' | wezterm cli send-text --pane-id %s --no-paste",
		M._wezterm_pane_id
	))

	-- Set up autocmd to preprocess on buffer write
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = M._autocmd_group,
		buffer = M._original_bufnr,
		callback = function()
			local preprocessed = preprocess_markdown(M._original_bufnr)
			local file = io.open(tmp_path, "w")
			if file then
				file:write(preprocessed)
				file:close()
			end
		end,
	})

	vim.notify("Markdown preview opened with mdcat. Edit and save to update.", vim.log.levels.INFO)
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

	-- Split the current pane vertically (50% width) with a clean zsh shell (no rc files)
	-- Capture the output to get the new pane ID
	local split_cmd = string.format(
		"wezterm cli split-pane --pane-id %s --horizontal --percent 50 -- zsh --no-rcs",
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

	-- Clear the built-in PS1 prompt in the no-rc zsh shell
	-- Since the shell has no rc files, this stays blank permanently
	os.execute(string.format(
		"printf \"PS1=''\\nclear\\n\" | wezterm cli send-text --pane-id %s --no-paste",
		M._wezterm_pane_id
	))

	-- Return focus to the original NeoVim pane
	os.execute(string.format(
		"wezterm cli activate-pane --pane-id %s",
		pane_id
	))

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

--- Ensures the preview pane is open and returns the pane ID and original pane ID
--- If pane already exists, reactivates it and returns nil (pane already open)
--- Otherwise creates pane, sets up autocmd group, and returns (new_pane_id, original_pane_id)
local function ensure_pane_open()
	-- If pane already exists, just activate it
	if M._wezterm_pane_id then
		os.execute(string.format("wezterm cli activate-pane --pane-id %s", M._wezterm_pane_id))
		return nil, nil  -- Pane already open
	end

	-- Get current WezTerm pane ID
	local pane_id = os.getenv("WEZTERM_PANE")
	if not pane_id or pane_id == "" then
		vim.notify("Not running inside WezTerm or WEZTERM_PANE not set", vim.log.levels.ERROR)
		return nil, nil
	end

	-- Split the pane with a clean zsh shell
	local split_cmd = string.format(
		"wezterm cli split-pane --pane-id %s --horizontal --percent 50 -- zsh --no-rcs",
		pane_id
	)
	local handle = io.popen(split_cmd)
	local output = handle:read("*a")
	handle:close()

	local new_pane_id = output:match("(%d+)")
	if not new_pane_id then
		vim.notify("Failed to create WezTerm split pane", vim.log.levels.ERROR)
		return nil, nil
	end

	M._wezterm_pane_id = new_pane_id

	-- Clear prompt and prepare pane
	os.execute(string.format(
		"printf \"PS1=''\\nclear\\n\" | wezterm cli send-text --pane-id %s --no-paste",
		M._wezterm_pane_id
	))

	-- Return focus to the original NeoVim pane
	os.execute(string.format(
		"wezterm cli activate-pane --pane-id %s",
		pane_id
	))

	M._original_bufnr = vim.api.nvim_get_current_buf()

	-- Create unique autocmd group for this session
	M._autocmd_group = "mermaid_preview_" .. M._original_bufnr
	vim.api.nvim_create_augroup(M._autocmd_group, { clear = true })

	return new_pane_id, pane_id
end

--- Render full file preview (with mermaid rendering for markdown)
--- <leader>mf: full document preview
function M.render_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

	if ft ~= "markdown" and ft ~= "mermaid" then
		vim.notify("File preview only works in markdown or mermaid files", vim.log.levels.WARN)
		return
	end

	local new_pane_id, original_pane_id = ensure_pane_open()

	if ft == "mermaid" then
		-- For .mmd files: render entire file via diagram preview
		local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local content = table.concat(current_lines, "\n")
		local file = io.open("/tmp/mermaid_preview.mmd", "w")
		if file then
			file:write(content)
			file:close()
		end

		-- Set up autocmd for full mermaid file if pane was just opened
		if new_pane_id then
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = M._autocmd_group,
				buffer = M._original_bufnr,
				callback = function()
					local tmp_path = "/tmp/mermaid_preview.mmd"
					local current_lines = vim.api.nvim_buf_get_lines(M._original_bufnr, 0, -1, false)
					local content = table.concat(current_lines, "\n")
					local file = io.open(tmp_path, "w")
					if file then
						file:write(content)
						file:close()
					end
					render_and_display()
				end,
			})
		end

		vim.schedule(render_and_display)
	else
		-- For markdown files: full document with mdcat
		-- Do initial preprocess and write temp file
		local tmp_path = "/tmp/mermaid_preview_rendered.md"
		local preprocessed = preprocess_markdown(bufnr)
		local file = io.open(tmp_path, "w")
		if file then
			file:write(preprocessed)
			file:close()
		end

		-- Start mdcat --watch in the pane
		os.execute(string.format(
			"printf 'mdcat --watch --image-protocol iterm2 --margin /tmp/mermaid_preview_rendered.md\\n' | wezterm cli send-text --pane-id %s --no-paste",
			M._wezterm_pane_id
		))

		-- Set up autocmd to preprocess on buffer write if pane was just opened
		if new_pane_id then
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = M._autocmd_group,
				buffer = M._original_bufnr,
				callback = function()
					local preprocessed = preprocess_markdown(M._original_bufnr)
					local file = io.open(tmp_path, "w")
					if file then
						file:write(preprocessed)
						file:close()
					end
				end,
			})
		end

		vim.notify("Full markdown preview opened with mdcat. Edit and save to update.", vim.log.levels.INFO)
	end
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
	if M._wezterm_pane_id then
		close_pane()
		return
	end

	-- Open the pane - for both markdown (cursor block) and mermaid (full file)
	open_pane()
	vim.notify("Diagram preview opened. Edit and save to update. Press <leader>mp to close.", vim.log.levels.INFO)
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
