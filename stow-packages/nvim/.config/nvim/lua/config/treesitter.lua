local M = {}

local treesitter_configs = require("nvim-treesitter.configs")

local config = {
	ensure_installed = "all", -- a list of parsers or "all"
	ignore_install = { "phpdoc" }, -- list of parsers to ignore installing (for "all")
	sync_install = false, -- install parsers synchronously
	auto_install = true, -- automatically install missing parsers when entering buffer
	highlight = {
		enable = true, -- `false` will disable the whole extension
		disable = { "css" }, -- list of parsers (not languages) to ignore
		additional_vim_regex_highlighting = false, -- `true` or list of languages
	},
	autopairs = {
		enable = true
	},
	indent = {
		enable = true,
		disable = { },
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aA"] = "@attribute.outer",   --  1
				["hA"] = "@attribute.inner",   --  2
				["ab"] = "@block.outer",       --  3
				["hb"] = "@block.inner",       --  4
				["ac"] = "@call.outer",        --  5
				["hc"] = "@call.inner",        --  6
				["at"] = "@class.outer",       --  7
				["ht"] = "@class.inner",       --  8
				["a/"] = "@comment.outer",     --  9
				["h/"] = "@comment.inner",     -- 
				["ah"] = "@conditional.outer", -- 10
				["hh"] = "@conditional.inner", -- 11
				["aF"] = "@frame.outer",       -- 12
				["hF"] = "@frame.inner",       -- 13
				["af"] = "@function.outer",    -- 14
				["hf"] = "@function.inner",    -- 15
				["al"] = "@loop.outer",        -- 16
				["hl"] = "@loop.inner",        -- 17
				["aa"] = "@parameter.outer",   -- 18
				["ha"] = "@parameter.inner",   -- 19
				["hs"] = "@scopename.inner",   -- 20
				["as"] = "@statement.outer",   -- 21
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
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
	},
}

function M.setup()
	treesitter_configs.setup(config)
end

return M
