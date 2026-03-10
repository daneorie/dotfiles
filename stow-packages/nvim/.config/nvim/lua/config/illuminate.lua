local M = {}

function M.setup()
	-- vim.g.Illuminate_delay = 0
	-- vim.g.Illuminate_highlightUnderCursor = 0
	vim.g.Illuminate_ftblacklist = { "alpha", "NvimTree", "DressingSelect", "harpoon" }
	vim.api.nvim_set_keymap("n", "<A-l>", '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', { noremap = true })
	vim.api.nvim_set_keymap("n", "<A-p>", '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', { noremap = true })
end

return M
