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
map({ "n", "x" }, "i", "k") -- arrow: up
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

-- Copy something into the "+" register
map({ "n", "x" }, "<leader>y", [["+y]])
map({ "n", "x" }, "<leader>Y", [["+Y]])

-- Delete something without replacing the register
map("x", "<leader>d", [["_d]])
map("x", "<leader>D", [["_D]])

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

-- which-key
silent_map({ "n", "v" }, "\x33[104;5u", ":WhichKey<CR>")
