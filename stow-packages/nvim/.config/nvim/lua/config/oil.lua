local M = {}

function M.setup()
	-- Define helper functions for oil path operations
	local function normalize_oil_dir(dir)
		return dir and dir:gsub("^oil://", "") or nil
	end

	local function get_oil_abs_path()
		local oil = require("oil")
		local lnum = vim.fn.line(".")
		local entry = oil.get_entry_on_line(0, lnum)
		local dir = normalize_oil_dir(oil.get_current_dir())
		if not entry then
			vim.notify("No entry under cursor", vim.log.levels.WARN)
			return nil
		end
		return dir .. entry.name
	end

	local function get_oil_rel_path()
		local oil = require("oil")
		local lnum = vim.fn.line(".")
		local entry = oil.get_entry_on_line(0, lnum)
		local dir = normalize_oil_dir(oil.get_current_dir())
		if not entry then
			vim.notify("No entry under cursor", vim.log.levels.WARN)
			return nil
		end
		local abs = dir .. entry.name
		local root = require("utils").get_git_root(dir)
		return root and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ":.")
	end

	local function get_oil_abs_dir()
		return normalize_oil_dir(require("oil").get_current_dir()):gsub("/$", "")
	end

	local function get_oil_rel_dir()
		local dir = normalize_oil_dir(require("oil").get_current_dir()):gsub("/$", "")
		local root = require("utils").get_git_root(dir)
		return root and dir:sub(#root + 2) or vim.fn.fnamemodify(dir, ":.")
	end

	local function append_path(get_fn, sep, trailing)
		local path = get_fn()
		if not path then return end
		local clipboard = vim.fn.getreg("+"):gsub("\n$", "")
		local new = clipboard ~= "" and (clipboard .. sep .. path) or path
		if trailing then new = new .. trailing end
		vim.fn.setreg("+", new)
		vim.notify("Appended: " .. path)
	end

	local function yank_path(get_fn)
		local path = get_fn()
		if not path then return end
		vim.fn.setreg("+", path)
		vim.notify("Copied: " .. path)
	end

	local function get_oil_github_file_url()
		local oil = require("oil")
		local lnum = vim.fn.line(".")
		local entry = oil.get_entry_on_line(0, lnum)
		if not entry then
			vim.notify("No entry under cursor", vim.log.levels.WARN)
			return nil
		end
		local dir = normalize_oil_dir(oil.get_current_dir())
		local path = dir .. entry.name
		return require("utils.github").get_github_url(path)
	end

	local function get_oil_github_dir_url()
		local dir = normalize_oil_dir(require("oil").get_current_dir()):gsub("/$", "")
		return require("utils.github").get_github_url(dir)
	end

	-- Multi-selection support: get multiple entries in visual selection
	local function get_oil_multi_abs_paths()
		local oil = require("oil")
		local mode = vim.fn.mode()
		local is_visual = mode:match("^[vV]")
		
		if not is_visual then
			return nil
		end
		
		local _, start_lnum, _, _ = unpack(vim.fn.getpos("v"))
		local _, end_lnum, _, _, _ = unpack(vim.fn.getcurpos())
		if start_lnum > end_lnum then
			start_lnum, end_lnum = end_lnum, start_lnum
		end
		
		local dir = normalize_oil_dir(oil.get_current_dir())
		local paths = {}
		for i = start_lnum, end_lnum do
			local entry = oil.get_entry_on_line(0, i)
			if entry then
				table.insert(paths, dir .. entry.name)
			end
		end
		
		return #paths > 0 and paths or nil
	end

	local function get_oil_multi_rel_paths()
		local oil = require("oil")
		local mode = vim.fn.mode()
		local is_visual = mode:match("^[vV]")
		
		if not is_visual then
			return nil
		end
		
		local _, start_lnum, _, _ = unpack(vim.fn.getpos("v"))
		local _, end_lnum, _, _, _ = unpack(vim.fn.getcurpos())
		if start_lnum > end_lnum then
			start_lnum, end_lnum = end_lnum, start_lnum
		end
		
		local dir = normalize_oil_dir(oil.get_current_dir())
		local root = require("utils").get_git_root(dir)
		local paths = {}
		for i = start_lnum, end_lnum do
			local entry = oil.get_entry_on_line(0, i)
			if entry then
				local abs = dir .. entry.name
				local rel = root and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ":.")
				table.insert(paths, rel)
			end
		end
		
		return #paths > 0 and paths or nil
	end

	local function get_oil_multi_github_urls()
		local oil = require("oil")
		local mode = vim.fn.mode()
		local is_visual = mode:match("^[vV]")
		
		if not is_visual then
			return nil
		end
		
		local _, start_lnum, _, _ = unpack(vim.fn.getpos("v"))
		local _, end_lnum, _, _, _ = unpack(vim.fn.getcurpos())
		if start_lnum > end_lnum then
			start_lnum, end_lnum = end_lnum, start_lnum
		end
		
		local dir = normalize_oil_dir(oil.get_current_dir())
		local urls = {}
		for i = start_lnum, end_lnum do
			local entry = oil.get_entry_on_line(0, i)
			if entry then
				local path = dir .. entry.name
				local url = require("utils.github").get_github_url(path)
				if url then
					table.insert(urls, url)
				end
			end
		end
		
		return #urls > 0 and urls or nil
	end

	-- Replace clipboard with multiple paths/URLs (newline-separated)
	local function yank_multi_paths(get_fn)
		local paths = get_fn()
		if not paths then return end
		local content = table.concat(paths, "\n")
		vim.fn.setreg("+", content)
		vim.notify("Copied " .. #paths .. " item(s)")
	end

	-- Append multiple paths/URLs with separator
	local function append_multi_paths(get_fn, sep, trailing)
		local paths = get_fn()
		if not paths then return end
		local clipboard = vim.fn.getreg("+"):gsub("\n$", "")
		local items_str = table.concat(paths, sep)
		local new = clipboard ~= "" and (clipboard .. sep .. items_str) or items_str
		if trailing then new = new .. trailing end
		vim.fn.setreg("+", new)
		vim.notify("Appended " .. #paths .. " item(s)")
	end

	require("oil").setup({
		default_file_explorer = true,
		columns = {
			"icon",
			--"permissions",
			--"size",
			--"mtime",
		},
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-v>"] = "actions.select_vsplit", -- to match Telescope; was <C-s>
			["<C-x>"] = "actions.select_split", -- to match Telescope; was <C-h>
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["<BS>"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["g."] = "actions.toggle_hidden",
		},
		use_default_keymaps = false,
		view_options = {
			show_hidden = true,
		},
	})

	-- Register oil buffer-local keymaps with which-key
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "oil",
		callback = function()
		require("which-key").register({
			-- Original keymaps
			yp = "Yank absolute path",
			yP = "Yank relative path (git root)",
			yd = "Yank absolute directory",
			yD = "Yank relative directory (git root)",
			yg = "Yank GitHub file URL",
			yG = "Yank GitHub directory URL",
			-- New append groups
			ys = { name = "Append (space-separated)" },
			yc = { name = "Append (comma-separated)" },
			yt = { name = "Append (tab-separated)" },
			yn = { name = "Append (newline-separated)" },
		}, { mode = "n", buffer = 0 })
		require("which-key").register({
			["<leader>ysp"] = "Append absolute path",
			["<leader>ysP"] = "Append relative path (git root)",
			["<leader>ysd"] = "Append absolute directory",
			["<leader>ysD"] = "Append relative directory (git root)",
			["<leader>ysg"] = "Append GitHub file URL",
			["<leader>ysG"] = "Append GitHub directory URL",
			["<leader>ycp"] = "Append absolute path",
			["<leader>ycP"] = "Append relative path (git root)",
			["<leader>ycd"] = "Append absolute directory",
			["<leader>ycD"] = "Append relative directory (git root)",
			["<leader>ycg"] = "Append GitHub file URL",
			["<leader>ycG"] = "Append GitHub directory URL",
			["<leader>ytp"] = "Append absolute path",
			["<leader>ytP"] = "Append relative path (git root)",
			["<leader>ytd"] = "Append absolute directory",
			["<leader>ytD"] = "Append relative directory (git root)",
			["<leader>ytg"] = "Append GitHub file URL",
			["<leader>ytG"] = "Append GitHub directory URL",
			["<leader>ynp"] = "Append absolute path",
			["<leader>ynP"] = "Append relative path (git root)",
			["<leader>ynd"] = "Append absolute directory",
			["<leader>ynD"] = "Append relative directory (git root)",
			["<leader>yng"] = "Append GitHub file URL",
			["<leader>ynG"] = "Append GitHub directory URL",
		}, { mode = "n", buffer = 0 })
		require("which-key").register({
			yp = "Yank absolute path (multi)",
			yP = "Yank relative path (multi)",
			yg = "Yank GitHub URL (multi)",
			ys = { name = "Append (space-separated, multi)" },
			yc = { name = "Append (comma-separated, multi)" },
			yt = { name = "Append (tab-separated, multi)" },
			yn = { name = "Append (newline-separated, multi)" },
		}, { mode = "v", buffer = 0 })
		require("which-key").register({
			["<leader>ysp"] = "Append absolute path (multi)",
			["<leader>ysP"] = "Append relative path (multi)",
			["<leader>ysg"] = "Append GitHub URL (multi)",
			["<leader>ycp"] = "Append absolute path (multi)",
			["<leader>ycP"] = "Append relative path (multi)",
			["<leader>ycg"] = "Append GitHub URL (multi)",
			["<leader>ytp"] = "Append absolute path (multi)",
			["<leader>ytP"] = "Append relative path (multi)",
			["<leader>ytg"] = "Append GitHub URL (multi)",
			["<leader>ynp"] = "Append absolute path (multi)",
			["<leader>ynP"] = "Append relative path (multi)",
			["<leader>yng"] = "Append GitHub URL (multi)",
		}, { mode = "v", buffer = 0 })
		
		-- Register buffer-local keymaps for custom path operations
		-- Normal mode: yank (replace clipboard) with path/directory
		vim.keymap.set("n", "yp", function() yank_path(get_oil_abs_path) end, { buffer = true, noremap = true })
		vim.keymap.set("n", "yP", function() yank_path(get_oil_rel_path) end, { buffer = true, noremap = true })
		vim.keymap.set("n", "yd", function() yank_path(get_oil_abs_dir) end, { buffer = true, noremap = true })
		vim.keymap.set("n", "yD", function() yank_path(get_oil_rel_dir) end, { buffer = true, noremap = true })
		vim.keymap.set("n", "yg", function() yank_path(get_oil_github_file_url) end, { buffer = true, noremap = true })
		vim.keymap.set("n", "yG", function() yank_path(get_oil_github_dir_url) end, { buffer = true, noremap = true })
		
		-- Visual mode: yank multiple (replace clipboard, newline-separated)
		vim.keymap.set("v", "yp", function() yank_multi_paths(get_oil_multi_abs_paths) end, { buffer = true, noremap = true })
		vim.keymap.set("v", "yP", function() yank_multi_paths(get_oil_multi_rel_paths) end, { buffer = true, noremap = true })
		vim.keymap.set("v", "yg", function() yank_multi_paths(get_oil_multi_github_urls) end, { buffer = true, noremap = true })
		
		-- Normal mode: append with space separator
		vim.keymap.set("n", "<leader>ysp", function() append_path(get_oil_abs_path, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ysP", function() append_path(get_oil_rel_path, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ysd", function() append_path(get_oil_abs_dir, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ysD", function() append_path(get_oil_rel_dir, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ysg", function() append_path(get_oil_github_file_url, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ysG", function() append_path(get_oil_github_dir_url, " ") end, { buffer = true, noremap = true })
		
		-- Visual mode: append with space separator
		vim.keymap.set("v", "<leader>ysp", function() append_multi_paths(get_oil_multi_abs_paths, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ysP", function() append_multi_paths(get_oil_multi_rel_paths, " ") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ysg", function() append_multi_paths(get_oil_multi_github_urls, " ") end, { buffer = true, noremap = true })
		
		-- Normal mode: append with comma separator
		vim.keymap.set("n", "<leader>ycp", function() append_path(get_oil_abs_path, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ycP", function() append_path(get_oil_rel_path, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ycd", function() append_path(get_oil_abs_dir, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ycD", function() append_path(get_oil_rel_dir, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ycg", function() append_path(get_oil_github_file_url, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ycG", function() append_path(get_oil_github_dir_url, ",") end, { buffer = true, noremap = true })
		
		-- Visual mode: append with comma separator
		vim.keymap.set("v", "<leader>ycp", function() append_multi_paths(get_oil_multi_abs_paths, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ycP", function() append_multi_paths(get_oil_multi_rel_paths, ",") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ycg", function() append_multi_paths(get_oil_multi_github_urls, ",") end, { buffer = true, noremap = true })
		
		-- Normal mode: append with tab separator
		vim.keymap.set("n", "<leader>ytp", function() append_path(get_oil_abs_path, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ytP", function() append_path(get_oil_rel_path, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ytd", function() append_path(get_oil_abs_dir, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ytD", function() append_path(get_oil_rel_dir, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ytg", function() append_path(get_oil_github_file_url, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ytG", function() append_path(get_oil_github_dir_url, "\t") end, { buffer = true, noremap = true })
		
		-- Visual mode: append with tab separator
		vim.keymap.set("v", "<leader>ytp", function() append_multi_paths(get_oil_multi_abs_paths, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ytP", function() append_multi_paths(get_oil_multi_rel_paths, "\t") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ytg", function() append_multi_paths(get_oil_multi_github_urls, "\t") end, { buffer = true, noremap = true })
		
		-- Normal mode: append with newline separator
		vim.keymap.set("n", "<leader>ynp", function() append_path(get_oil_abs_path, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ynP", function() append_path(get_oil_rel_path, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ynd", function() append_path(get_oil_abs_dir, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ynD", function() append_path(get_oil_rel_dir, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>yng", function() append_path(get_oil_github_file_url, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("n", "<leader>ynG", function() append_path(get_oil_github_dir_url, "\n", "\n") end, { buffer = true, noremap = true })
		
		-- Visual mode: append with newline separator
		vim.keymap.set("v", "<leader>ynp", function() append_multi_paths(get_oil_multi_abs_paths, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>ynP", function() append_multi_paths(get_oil_multi_rel_paths, "\n", "\n") end, { buffer = true, noremap = true })
		vim.keymap.set("v", "<leader>yng", function() append_multi_paths(get_oil_multi_github_urls, "\n", "\n") end, { buffer = true, noremap = true })
		end,
	})
end

return M
