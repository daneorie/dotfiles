local M = {}

function M.setup()
	require("Comment").setup({
		padding = false,
		ignore = "^$",
	})
end

return M
