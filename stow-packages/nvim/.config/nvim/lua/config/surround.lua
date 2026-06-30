local M = {}

function M.setup()
	-- As of nvim-surround v4, the keymaps field is removed from setup().
	-- Disable default insert mappings and set custom ones instead.
	vim.g.nvim_surround_no_insert_mappings = true

	require("nvim-surround").setup()

	-- Custom insert-mode keymaps bound to <Plug> mappings
	vim.keymap.set("i", "<C-s>s", "<Plug>(nvim-surround-insert)", {
		desc = "Add a surrounding pair around the cursor (insert mode)",
	})
	vim.keymap.set("i", "<C-s>S", "<Plug>(nvim-surround-insert-line)", {
		desc = "Add a surrounding pair around the cursor, on new lines (insert mode)",
	})
end

return M
