local M = {}

-- Neovim 0.12 built-in treesitter highlighting is enabled by default.
-- This config only sets up textobjects via nvim-treesitter-textobjects.
-- Native highlighting, folding, and indentation require no plugin configuration.

function M.setup()
	require("nvim-treesitter-textobjects").setup({
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["aA"] = "@attribute.outer",
				["hA"] = "@attribute.inner",
				["ab"] = "@block.outer",
				["hb"] = "@block.inner",
				["ac"] = "@call.outer",
				["hc"] = "@call.inner",
				["at"] = "@class.outer",
				["ht"] = "@class.inner",
				["a/"] = "@comment.outer",
				["h/"] = "@comment.inner",
				["ah"] = "@conditional.outer",
				["hh"] = "@conditional.inner",
				["aF"] = "@frame.outer",
				["hF"] = "@frame.inner",
				["af"] = "@function.outer",
				["hf"] = "@function.inner",
				["al"] = "@loop.outer",
				["hl"] = "@loop.inner",
				["aa"] = "@parameter.outer",
				["ha"] = "@parameter.inner",
				["hs"] = "@scopename.inner",
				["as"] = "@statement.outer",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	})
end

return M
