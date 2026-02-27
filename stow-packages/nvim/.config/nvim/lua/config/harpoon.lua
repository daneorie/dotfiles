local M = {}

local harpoon = require("harpoon")
local whichkey = require("which-key")

function M.setup()
	harpoon.setup({
		global_settings = {
			-- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
			save_on_toggle = false,

			-- saves the harpoon file upon every change. disabling is unrecommended.
			save_on_change = true,

			-- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
			enter_on_sendcmd = true,

			-- closes any tmux windows harpoon that harpoon creates when you close Neovim.
			tmux_autoclose_windows = false,

			-- filetypes that you want to prevent from adding to the harpoon list menu.
			excluded_filetypes = { "harpoon" },

			-- set marks specific to each git branch inside git repository
			mark_branch = false,
		},
	})

	local keymap = {
		m = {
			name = "Harpoon",
			a = { "<cmd>lua require('harpoon.mark').add_file<CR>", "Mark File" },
			e = { "<cmd>lua require('harpoon.ui').toggle_quick_menu<CR>", "Show Marked Files" },
		},
		t = {
			name = "Justfile with Harpoon",
			d = { "<cmd>lua require('harpoon.tmux').sendCommand('3', 'just test')<CR>", "Test" },
			b = { "<cmd>lua require('harpoon.tmux').sendCommand('3', 'just build')<CR>", "Build" },
		},
	}
	local opts = {
		mode = "n",
		prefix = "<leader>",
		buffer = nil,
		silent = true,
		noremap = true,
		nowait = false,
	}
	whichkey.register(keymap, opts)

	local M_keymap = {
		["<M-l>"] = { "<cmd>lua require('harpoon.tmux').sendCommand(3, 1)<CR>", "Run 1st Marked Command" },
		["<M-u>"] = { "<cmd>lua require('harpoon.tmux').sendCommand(3, 2)<CR>", "Run 2nd Marked Command" },
		["<M-y>"] = { "<cmd>lua require('harpoon.tmux').sendCommand(3, 3)<CR>", "Run 3rd Marked Command" },
		["<M-;>"] = { "<cmd>lua require('harpoon.tmux').sendCommand(3, 4)<CR>", "Run 4th Marked Command" },
		["<M-n>"] = { "<cmd>lua require('harpoon.ui').nav_file(1)<CR>", "Open 1st Marked File" },
		["<M-e>"] = { "<cmd>lua require('harpoon.ui').nav_file(2)<CR>", "Open 2nd Marked File" },
		["<M-i>"] = { "<cmd>lua require('harpoon.ui').nav_file(3)<CR>", "Open 3rd Marked File" },
		["<M-o>"] = { "<cmd>lua require('harpoon.ui').nav_file(4)<CR>", "Open 4th Marked File" },
	}
	local M_opts = {
		mode = "n",
		prefix = nil,
		buffer = nil,
		silent = true,
		noremap = true,
		nowait = false,
	}
	whichkey.register(M_keymap, M_opts)
end

return M
