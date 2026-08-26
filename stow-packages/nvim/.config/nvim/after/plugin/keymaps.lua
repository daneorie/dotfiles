local whichkey = require("which-key")

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end
local function remap(mode, lhs, rhs, opts)
	local options = { noremap = false }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end
local function silent_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

--Remap comma as leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Some mappings are written using some \x33 format, because I use Alacritty to send different codes to differentiate the some keys being pressed with and without modifier keys.

-- utility mappings
map({ "n", "v" }, "<M-a>", "<Esc>ggVG") -- select all
map({ "n", "v" }, "<M-s>", "<Esc>:w<CR>") -- save file
map({ "n", "x" }, "<leader>oo", ":e ")
map({ "n", "x" }, "<leader>nn", ":set number!<CR>") -- toggle line numbers
map({ "n", "x" }, "<leader>nr", ":set relativenumber!<CR>") -- toggle relative numbers
map("n", "<leader>h", ":nohlsearch<CR>") -- clear highlights
map("n", "<leader>al", "o- [ ] ") -- add a new markdown list item
map("v", "y", "ygv<Esc>") -- prevent yanking from putting the cursor back to the start of the yank
map({ "n", "x" }, "<C-q><C-q>", "require('telescope.builtin').quickfix()")

-- Set keymaps for Colemak navigation.
--   Here's the circle of mappings: n -> h -> i -> k -> o -> l -> e -> j -> n
--   nioe 1342
--   jhkl 2134
map({ "n", "x" }, "n", "h") -- arrow: left
map({ "n", "x" }, "e", "j") -- arrow: down
map("n", "i", "k") -- arrow: up (normal mode)
map("x", "i", "k", { nowait = true }) -- arrow: up (visual mode, no disambiguation wait)
map({ "n", "x" }, "o", "l") -- arrow: right
map({ "n", "x" }, "h", "i") -- insert
map({ "n", "x" }, "k", "o") -- newline insert
map({ "n", "x" }, "l", "e") -- end of word
map({ "n", "x" }, "j", "n") -- next match
map({ "n", "x" }, "N", "H") -- top of page
map({ "n", "x" }, "E", "J") -- join line below to current line
map({ "n", "x" }, "I", "K") -- keywordprg
map({ "n", "x" }, "O", "L") -- bottom of page
map({ "n", "x" }, "H", "I") -- insert at beginning of line
map({ "n", "x" }, "K", "O") -- insert newline
map({ "n", "x" }, "L", "E") -- end of word (space separated)
map({ "n", "x" }, "J", "N") -- previous match

-- This weird mapping fixes `vi_` (viw, vi", vi{, etc.) functionality not working due to the Colemak neio->arrow mappings
-- This works due to setting these mappings using `noremap = true`
map("n", "vi", "vi")

-- Paste over text without replacing the register
map("x", "<leader>p", [["_dP]])

-- Append to system clipboard instead of replacing
local function yank_append()
	local clipboard = vim.fn.getreg("+"):gsub("\n$", "")
	local line = vim.api.nvim_get_current_line()
	vim.fn.setreg("+", clipboard ~= "" and (clipboard .. "\n" .. line) or line, "l")
	vim.notify("Appended to clipboard: " .. line)
end

local function yank_append_visual()
	local _, start_lnum, _, _ = unpack(vim.fn.getpos("v"))
	local _, end_lnum, _, _, _ = unpack(vim.fn.getcurpos())
	if start_lnum > end_lnum then
		start_lnum, end_lnum = end_lnum, start_lnum
	end
	local lines = vim.api.nvim_buf_get_lines(0, start_lnum - 1, end_lnum, false)
	local selection = table.concat(lines, "\n")
	local clipboard = vim.fn.getreg("+"):gsub("\n$", "")
	vim.fn.setreg("+", clipboard ~= "" and (clipboard .. "\n" .. selection) or selection, "l")
	vim.notify("Appended to clipboard")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
end

map("n", "<leader>yy", yank_append)
map("v", "<leader>y", yank_append_visual)

-- Delete something without replacing the register
map("x", "<leader>d", [["_d]])
map("x", "<leader>D", [["_D]])

-- Yank file paths to system clipboard
local function get_abs_path()
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	return path
end

local function get_rel_path()
	local abs = vim.fn.expand("%:p")
	if abs == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	local utils = require("utils")
	local root = utils.get_git_root(vim.fn.fnamemodify(abs, ":h"))
	return root and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ":.") 
end

local function get_abs_dir()
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	return dir
end

local function get_rel_dir()
	local abs = vim.fn.expand("%:p:h")
	if abs == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	local utils = require("utils")
	local root = utils.get_git_root(abs)
	return root and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ":.")
end

-- Replace clipboard with path/directory
map("n", "yp", function()
	local path = get_abs_path()
	if not path then return end
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path)
end)

map("n", "yP", function()
	local rel = get_rel_path()
	if not rel then return end
	vim.fn.setreg("+", rel)
	vim.notify("Copied: " .. rel)
end)

map("n", "yd", function()
	local dir = get_abs_dir()
	if not dir then return end
	vim.fn.setreg("+", dir)
	vim.notify("Copied: " .. dir)
end)

map("n", "yD", function()
	local rel = get_rel_dir()
	if not rel then return end
	vim.fn.setreg("+", rel)
	vim.notify("Copied: " .. rel)
end)

-- Append path/directory to clipboard with configurable separator
local function append_path(get_fn, sep, trailing)
	local path = get_fn()
	if not path then return end
	local clipboard = vim.fn.getreg("+"):gsub("\n$", "")
	local new = clipboard ~= "" and (clipboard .. sep .. path) or path
	if trailing then new = new .. trailing end
	vim.fn.setreg("+", new)
	vim.notify("Appended: " .. path)
end

-- Append paths with space separator
map("n", "<leader>ysp", function() append_path(get_abs_path, " ") end)
map("n", "<leader>ysP", function() append_path(get_rel_path, " ") end)
map("n", "<leader>ysd", function() append_path(get_abs_dir, " ") end)
map("n", "<leader>ysD", function() append_path(get_rel_dir, " ") end)

-- Append paths with comma separator
map("n", "<leader>ycp", function() append_path(get_abs_path, ",") end)
map("n", "<leader>ycP", function() append_path(get_rel_path, ",") end)
map("n", "<leader>ycd", function() append_path(get_abs_dir, ",") end)
map("n", "<leader>ycD", function() append_path(get_rel_dir, ",") end)

-- Append paths with tab separator
map("n", "<leader>ytp", function() append_path(get_abs_path, "\t") end)
map("n", "<leader>ytP", function() append_path(get_rel_path, "\t") end)
map("n", "<leader>ytd", function() append_path(get_abs_dir, "\t") end)
map("n", "<leader>ytD", function() append_path(get_rel_dir, "\t") end)

-- Append paths with newline separator
map("n", "<leader>ynp", function() append_path(get_abs_path, "\n", "\n") end)
map("n", "<leader>ynP", function() append_path(get_rel_path, "\n", "\n") end)
map("n", "<leader>ynd", function() append_path(get_abs_dir, "\n", "\n") end)
map("n", "<leader>ynD", function() append_path(get_rel_dir, "\n", "\n") end)

-- Yank GitHub URLs to system clipboard
local function get_github_file_url()
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	return require("utils.github").get_github_url(path)
end

local function get_github_dir_url()
	local dir = vim.fn.expand("%:p:h")
	if dir == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return nil
	end
	return require("utils.github").get_github_url(dir)
end

-- Replace clipboard with GitHub URL
map("n", "yg", function()
	local url = get_github_file_url()
	if not url then return end
	vim.fn.setreg("+", url)
	vim.notify("Copied: " .. url)
end)

map("n", "yG", function()
	local url = get_github_dir_url()
	if not url then return end
	vim.fn.setreg("+", url)
	vim.notify("Copied: " .. url)
end)

-- Append GitHub URLs with space separator
map("n", "<leader>ysg", function() append_path(get_github_file_url, " ") end)
map("n", "<leader>ysG", function() append_path(get_github_dir_url, " ") end)

-- Append GitHub URLs with comma separator
map("n", "<leader>ycg", function() append_path(get_github_file_url, ",") end)
map("n", "<leader>ycG", function() append_path(get_github_dir_url, ",") end)

-- Append GitHub URLs with tab separator
map("n", "<leader>ytg", function() append_path(get_github_file_url, "\t") end)
map("n", "<leader>ytG", function() append_path(get_github_dir_url, "\t") end)

-- Append GitHub URLs with newline separator
map("n", "<leader>yng", function() append_path(get_github_file_url, "\n", "\n") end)
map("n", "<leader>ynG", function() append_path(get_github_dir_url, "\n", "\n") end)

-- Register keymaps with which-key for discoverability
whichkey.register({
	y = {
		name = "Yank/Append",
		y = "Append line to clipboard",
	},
}, { mode = "n", prefix = "<leader>" })
whichkey.register({
	y = {
		name = "Yank/Append",
	},
}, { mode = "v", prefix = "<leader>" })
whichkey.register({
	yp = "Yank absolute path",
	yP = "Yank relative path (git root)",
	yd = "Yank absolute directory",
	yD = "Yank relative directory (git root)",
	yg = "Yank GitHub file URL",
	yG = "Yank GitHub directory URL",
}, { mode = "n" })
whichkey.register({
	ys = { name = "Append (space-separated)" },
	yc = { name = "Append (comma-separated)" },
	yt = { name = "Append (tab-separated)" },
	yn = { name = "Append (newline-separated)" },
}, { mode = "n", prefix = "<leader>" })
whichkey.register({
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
}, { mode = "n" })

-- Navigate through the jumplist
map({ "n", "v" }, "<S-C-i>", "<C-o>") -- previous jump
map({ "n", "v" }, "<S-C-e>", "<C-i>") -- next jump

-- vertical scrolling. <C-y> is scroll up by default, so using <C-u> for scroll down works
--   very nicely in Colemak, since U and Y are above E and I (up and down in Colemak).
map({ "n", "v" }, "<C-u>", "<C-e>")

-- page scrolling while maintaining cursor in the center of the screen. Similar to the vertical scrolling, these keys are right below E and I.
map({ "n", "v" }, "<C-,>", "<C-d>zz")
map({ "n", "v" }, "<C-.>", "<C-u>zz")

-- searching while maintaining cursor in the center of the screen
map({ "n", "x" }, "j", "nzzzv")
map({ "n", "x" }, "J", "Nzzzv")

-- create and close tabs
local tab_keymaps = {
	name = "Tab",
	["<C-n>"] = { ":0tabnew<CR>", "Create new tab [first]" },
	["<C-e>"] = { ":-tabnew<CR>", "Create new tab [before]" },
	["<C-i>"] = { ":tabnew<CR>", "Create new tab [after]" },
	["<C-o>"] = { ":$tabnew<CR>", "Create new tab [last]" },
	["<C-s>"] = {
		name = "Split",
		["<C-n>"] = { ":0tab split<CR>", "Copy buffer to new tab [first]" },
		["<C-e>"] = { ":-tab split<CR>", "Copy buffer to new tab [before]" },
		["<C-i>"] = { ":tab split<CR>", "Copy buffer to new tab [after]" },
		["<C-o>"] = { ":$tab split<CR>", "Copy buffer to new tab [last]" },
	},
	["<C-w>"] = { ":tabclose<CR>", "Close Tab" },
}
local tab_opts = {
	mode = "n",
	prefix = "<C-t>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
}
whichkey.register(tab_keymaps, tab_opts)

-- Mermaid keymaps
whichkey.register({
	m = {
		name = "Mermaid",
		f = "Render full file preview",
		p = "Render diagram / toggle pane",
	},
}, { mode = "n", prefix = "<leader>" })

-- resize current buffer
map({ "n", "v", "i" }, "<A-Left>", ":vertical resize -2<CR>") -- decrease width
map({ "n", "v", "i" }, "<A-Down>", ":resize -2<CR>") -- decrease height
map({ "n", "v", "i" }, "<A-Up>", ":resize +2<CR>") -- increase height
map({ "n", "v", "i" }, "<A-Right>", ":vertical resize +2<CR>") -- increase width

-- move line or visually selected block - ctrl+alt+j/k (Colemak)
map("i", "<C-A-e>", "<Esc>:m .+1<CR>==gi")
map("i", "<C-A-i>", "<Esc>:m .-2<CR>==gi")
map("v", "<C-A-e>", ":m '>+1<CR>gv=gv")
map("v", "<C-A-i>", ":m '<-2<CR>gv=gv")

--split the window vertically or horizontally
map("n", "<Bar>", "<C-w>v<C-w><Right>")
map("n", "_", "<C-w>s<C-w><Down>")

-- Stay in visual mode after indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Mermaid diagram preview
map("n", "<leader>mf", function()
	require("config.mermaid-preview").render_file()
end)

map("n", "<leader>mp", function()
	require("config.mermaid-preview").toggle()
end)

-- Mermaid health check command
vim.api.nvim_create_user_command("MermaidHealth", function()
	require("config.mermaid-preview").check_health()
end, {})

-- which-key
silent_map({ "n", "v" }, "\x33[104;5u", ":WhichKey<CR>")
