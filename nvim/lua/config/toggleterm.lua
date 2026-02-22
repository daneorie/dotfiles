local M = {}

function _G.set_terminal_keymaps()
	local opts = { noremap = true, silent = true, buffer = 0 }
	-- vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<C-n>", [[<C-\><C-n><C-W>h]], opts)
	vim.keymap.set("t", "<C-e>", [[<C-\><C-n><C-W>j]], opts)
	vim.keymap.set("t", "\x33[105;5u", [[<C-\><C-n><C-W>k]], opts)
	vim.keymap.set("t", "<C-o>", [[<C-\><C-n><C-W>l]], opts)
end

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

local toggleterm = require("toggleterm")

function M.setup()
	vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

	toggleterm.setup({
		size = 20,
		open_mapping = [[<c-\>]],
		hide_numbers = true,
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = false,
		persist_size = true,
		direction = "float",
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
		},
	})
end

return M
