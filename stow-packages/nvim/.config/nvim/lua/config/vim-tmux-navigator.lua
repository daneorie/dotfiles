local M = {}

function M.setup()
	local g = vim.g
	g.tmux_navigator_no_mappings = 1
	g.tmux_navigator_no_wrap = 1

	vim.keymap.set("n", "<C-n>", "<cmd> TmuxNavigateLeft<CR>", { noremap = true })
	vim.keymap.set("n", "<C-e>", "<cmd> TmuxNavigateDown<CR>", { noremap = true })
	vim.keymap.set("n", "\x33[105;5u", "<cmd> TmuxNavigateUp<CR>", { noremap = true }) -- <C-i>
	vim.keymap.set("n", "<C-o>", "<cmd> TmuxNavigateRight<CR>", { noremap = true })

	vim.keymap.set("n", "<C-\\>", "<cmd> ToggleTerm<CR>")
end

return M
