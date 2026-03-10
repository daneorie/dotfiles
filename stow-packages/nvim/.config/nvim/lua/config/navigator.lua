local M = {}

function M.setup()
	require("Navigator").setup({})

	vim.keymap.set({ "n", "t" }, "<C-n>", "<CMD>NavigatorLeft<CR>")
	vim.keymap.set({ "n", "t" }, "<C-e>", "<CMD>NavigatorDown<CR>")
	vim.keymap.set({ "n", "t" }, "\x33[105;5u", "<CMD>NavigatorUp<CR>")
	vim.keymap.set({ "n", "t" }, "<C-o>", "<CMD>NavigatorRight<CR>")
	vim.keymap.set({ "n", "t" }, "<C-p>", "<CMD>NavigatorPrevious<CR>")
end

return M
