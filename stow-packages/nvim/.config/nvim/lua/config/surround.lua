local M = {}

function M.setup()
	require("nvim-surround").setup({
		keymaps = { -- vim-surround style keymaps
			insert = "<C-s>s",
			insert_line = "<C-s>S",
		},
	})
end

return M
