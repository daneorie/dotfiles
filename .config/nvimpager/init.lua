local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

map({ "n", "v" }, "<M-a>", "<Esc>ggVG") -- select all

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

-- vertical scrolling. <C-y> is scroll up by default, so using <C-u> for scroll down works
--   very nicely in Colemak, since U and Y are above E and I (up and down in Colemak).
map({ "n", "v" }, "<C-u>", "<C-e>")

-- page scrolling while maintaining cursor in the center of the screen. Similar to the vertical scrolling, these keys are right below E and I.
map({ "n", "v" }, "<C-,>", "<C-d>zz")
map({ "n", "v" }, "<C-.>", "<C-u>zz")

-- searching while maintaining cursor in the center of the screen
map({ "n", "x" }, "j", "nzzzv")
map({ "n", "x" }, "J", "Nzzzv")

--split the window vertically or horizontally
map("n", "<Bar>", "<C-w>v<C-w><Right>")
map("n", "_", "<C-w>s<C-w><Down>")
