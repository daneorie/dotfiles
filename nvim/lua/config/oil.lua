local M = {}

function M.setup()
	require("oil").setup({
		default_file_explorer = true,
		columns = {
			"icon",
			--"permissions",
			--"size",
			--"mtime",
		},
		watch_for_changes = true,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-v>"] = "actions.select_vsplit", -- to match Telescope; was <C-s>
			["<C-x>"] = "actions.select_split", -- to match Telescope; was <C-h>
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["<BS>"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["g."] = "actions.toggle_hidden",
		},
		use_default_keymaps = false,
		view_options = {
			show_hidden = true,
		},
	})
end

return M
