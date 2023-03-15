local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end
local function silent_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

--Remap comma as leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Some mappings are written using some \x33 format, because we use Alacritty to send different codes to differentiate the some keys being pressed with and without modifier keys.

-- utility mappings
map({"n", "v"}, "<leader>s", ":w<CR>")
map({"n", "v"}, "<leader>oo", ":e ")
map({"n", "v"}, "<leader>nn", ":set number!<CR>") -- toggle line numbers
map({"n", "v"}, "<leader>nr", ":set relativenumber!<CR>") -- toggle relative numbers

-- Set keymaps for Colemak navigation.
--   Here's the circle of mappings: n -> h -> i -> k -> o -> l -> e -> j -> n
map({"n", "v"}, "n", "h") -- arrow: left
map({"n", "v"}, "e", "j") -- arrow: down
map({"n", "v"}, "i", "k") -- arrow: up
map({"n", "v"}, "o", "l") -- arrow: right
map({"n", "v"}, "h", "i") -- insert
map({"n", "v"}, "k", "o") -- newline insert
map({"n", "v"}, "l", "e") -- end of word
map({"n", "v"}, "j", "n") -- next match
map({"n", "v"}, "N", "H") -- top of page
map({"n", "v"}, "E", "J") -- join line below to current line
map({"n", "v"}, "I", "K") -- <unset>?
map({"n", "v"}, "O", "L") -- bottom of page
map({"n", "v"}, "H", "I") -- insert at beginning of line
map({"n", "v"}, "K", "O") -- insert newline
map({"n", "v"}, "L", "E") -- end of word (space separated)
map({"n", "v"}, "J", "N") -- previous match
--map({"n", "v"}, "<C-n>", "<C-h>")
--map({"n", "v"}, "<C-e>", "<C-j>")
--map({"n", "v"}, "\x33[105;5u", "<C-k>") -- <C-i>
--map({"n", "v"}, "<C-o>", "<C-l>")
--map({"n", "v"}, "<C-h>", "<C-i>")
--map({"n", "v"}, "<C-k>", "<C-o>")
--map({"n", "v"}, "<C-l>", "<C-e>")
--map({"n", "v"}, "<C-j>", "<C-n>")

-- create link from selected text - does not use Colemak bindings
--map("v", "<leader><leader>l", "s[<C-r>\"]<CR>(<C-r>\".md)<Esc>^lvf)h:!tr ' ' '-'<CR>kJx")

-- vertical scrolling. <C-y> is scroll up by default, so using <C-u> for scroll down works
--   very nicely in Colemak, since U and Y are above E and I (up and down in Colemak).
map({"n", "v"}, "<C-u>", "<C-e>")

-- page scrolling. Similar to the vertical scrolling, these keys are right below E and I.
map({"n", "v"}, "\x33[44;5u", "<C-d>") -- <C-,>
map({"n", "v"}, "\x33[46;5u", "<C-u>") -- <C-.>

-- move between buffers
map("n", "\x33[9;5u", ":bn<CR>") -- <C-Tab>
map("n", "\x33[1;5Z", ":bp<CR>") -- <S-C-Tab>
map("n", "\x33[44;6u", ":bp<CR>") -- <S-C-,> OR <C-<>
map("n", "\x33[46;6u", ":bn<CR>") -- <S-C-.> OR <C->>
map("n", "<C-t>", ":tabnew split<CR>")
	
-- delete current buffer and move to previous buffer
map({"n", "v"}, "<leader>\x33[9;5u", ":bp|bd #<CR>") -- <C-Tab>
map({"n", "v"}, "<leader>\x33[1;5Z", ":bp!|bd! #<CR>") -- <S-C-Tab>

-- resize current buffer
map({"n", "v", "i"}, "<A-Left>", ":vertical resize -2<CR>")  -- decrease width
map({"n", "v", "i"}, "<A-Down>", ":resize -2<CR>")           -- decrease height
map({"n", "v", "i"}, "<A-Up>", ":resize +2<CR>")             -- increase height
map({"n", "v", "i"}, "<A-Right>", ":vertical resize +2<CR>") -- increase width

-- move line or visually selected block - ctrl+alt+j/k (Colemak)
map("i", "<C-A-e>", "<Esc>:m .+1<CR>==gi")
map("i", "<C-A-i>", "<Esc>:m .-2<CR>==gi")
map("v", "<C-A-e>", ":m '>+1<CR>gv=gv")
map("v", "<C-A-i>", ":m '<-2<CR>gv=gv")

--split the window vertically or horizontally
map("n", "<Bar>", "<C-w>v<C-w><Right>")
map("n", "_", "<C-w>s<C-w><Down>")

-- move split panes to left/bottom/top/right (Colemak)
--map("n", "<A-n>", "<C-w>H")
--map("n", "<A-e>", "<C-w>J")
--map("n", "<A-i>", "<C-w>K")
--map("n", "<A-o>", "<C-w>L")

-- move between panes to left/bottom/top/right (Colemak)
map("n", "<C-n>", "<C-w>h")
map("n", "<C-e>", "<C-w>j")
map("n", "\x33[105;5u", "<C-w>k") -- <C-i>
map("n", "<C-o>", "<C-w>l")

-- Clear highlights
map("n", "<leader>h", ":nohlsearch<CR>")

-- Stay in visual mode after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Just Build for a project-agnostic buil command that can be configured as needed
map("n", "<leader>jb", ":!just build<CR>")

--------------------------
-- Plugin-specific keymaps

-- which-key
map({"n", "v"}, "<C-h>", ":WhichKey<CR>")

-- nvim-tree
map("n", "<leader>l", "<cmd>lua require('lsp_lines').toggle()<CR>")

-- nvim-tree
map("n", "<leader>nt", ":NvimTreeToggle<CR>")

-- Telescope
silent_map("n", "<leader>qr", "<cmd>lua require('user.telescope').reload()<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>fw", "<cmd>Telescope workspaces<CR>")
map("n", "<leader>fv", "<cmd>Telescope vim_bookmarks current_file<CR>")
map("n", "<leader>fV", "<cmd>Telescope vim_bookmarks all<CR>")
map("n", "<leader>bf", "<cmd>Telescope file_browser<CR>")
map("n", "<leader>bh", "<cmd>Telescope file_browser hidden=true<CR>")

-- vim-buffet
map("n", "<leader>1", "<Plug>BuffetSwitch(1)")
map("n", "<leader>2", "<Plug>BuffetSwitch(2)")
map("n", "<leader>3", "<Plug>BuffetSwitch(3)")
map("n", "<leader>4", "<Plug>BuffetSwitch(4)")
map("n", "<leader>5", "<Plug>BuffetSwitch(5)")
map("n", "<leader>6", "<Plug>BuffetSwitch(6)")
map("n", "<leader>7", "<Plug>BuffetSwitch(7)")
map("n", "<leader>8", "<Plug>BuffetSwitch(8)")
map("n", "<leader>9", "<Plug>BuffetSwitch(9)")
map("n", "<leader>0", "<Plug>BuffetSwitch(10)")

-- vim-easy-align
-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
map("n", "ga", "<Plug>(EasyAlign)");
-- Start interactive EasyAlign in visual mode (e.g. vipga)
map("x", "ga", "<Plug>(EasyAlign)");

-- vim-swoop
map("n", "<leader>l", "<cmd>call Swoop()<CR>")
map("v", "<leader>l", "<cmd>call SwoopSelection()<CR>")
map("n", "<leader>ml", "<cmd>call SwoopMulti()<CR>")
map("v", "<leader>ml", "<cmd>call SwoopMultiSelection()<CR>")

-- DAP
map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>")
map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<CR>")
map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<CR>")
map("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<CR>")
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<CR>")
map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>")
map("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<CR>")
map("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<CR>")
