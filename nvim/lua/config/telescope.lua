local M = {}

local n_mappings = {}
local i_mappings = {}
local extensions = {}
local extensions_to_load = {
	"dap",
	"env",
	"file_browser",
	"fzf",
	"harpoon",
	"telescope-tabs",
}

local a_status_ok, actions = pcall(require, "telescope.actions")
if a_status_ok then
	local action_n_mappings = {
		["<C-e>"] = actions.move_selection_next,
		["e"] = actions.move_selection_next,
		["\x33[105;5u"] = actions.move_selection_previous, -- <C-i>
		["i"] = actions.move_selection_previous,
		["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
		["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
		["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
		["<C-u>"] = actions.results_scrolling_down,
		["<C-y>"] = actions.results_scrolling_up,
		["<C-,>"] = actions.preview_scrolling_down,
		["<C-.>"] = actions.preview_scrolling_up,
	}
	local action_i_mappings = {
		["<C-e>"] = actions.move_selection_next,
		["\x33[105;5u"] = actions.move_selection_previous, -- <C-i>
		["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
		["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
		["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
		["<C-u>"] = actions.results_scrolling_down,
		["<C-y>"] = actions.results_scrolling_up,
		["<C-,>"] = actions.preview_scrolling_down,
		["<C-.>"] = actions.preview_scrolling_up,
	}
	n_mappings = vim.tbl_extend("force", n_mappings, action_n_mappings)
	i_mappings = vim.tbl_extend("force", i_mappings, action_i_mappings)
end

local as_status_ok, action_state = pcall(require, "telescope.actions.state")
local n_status_ok, nvim_tree = pcall(require, "nvim-tree.api")
if as_status_ok and n_status_ok then
	local open_in_nvim_tree = function(prompt_bufnr)
		local opts = {
			buf = action_state.get_selected_entry()[1],
			open = true,
			focus = true,
		}

		nvim_tree.tree.find_file(opts)
	end

	n_mappings = vim.tbl_extend("force", n_mappings, { ["<C-b>"] = open_in_nvim_tree })
	i_mappings = vim.tbl_extend("force", i_mappings, { ["<C-b>"] = open_in_nvim_tree })
end

local i_status_ok, insert_path = pcall(require, "user.telescope-insert-path")
if i_status_ok then
	n_mappings = vim.tbl_extend("force", n_mappings, insert_path.n_mappings())
	i_mappings = vim.tbl_extend("force", i_mappings, insert_path.i_mappings())
end

local w_status_ok, whichkey = pcall(require, "which-key")
if w_status_ok then
	n_mappings = vim.tbl_extend("force", n_mappings, { ["\x33[104;5u"] = "which_key" })
	i_mappings = vim.tbl_extend("force", i_mappings, { ["\x33[104;5u"] = "which_key" })
end

local g_status_ok, git_worktree = pcall(require, "git-worktree")
if g_status_ok then
	extensions_to_load[#extensions_to_load + 1] = "git_worktree"
end

function M.setup()
	local telescope = require("telescope")
	
	telescope.setup({
		defaults = {
			file_ignore_patterns = {
				"^.git/",
				"node%_modules/.*",
				"vendor/.*",
			},
			mappings = {
				n = n_mappings,
				i = i_mappings,
			},
			-- Custom buffer previewer that disables TreeSitter to prevent errors
			buffer_previewer_maker = function(filepath, bufnr, opts)
				opts = opts or {}
				
				-- Use the default previewer but disable TreeSitter
				local previewers_utils = require("telescope.previewers.utils")
				previewers_utils.job_maker({ "cat", filepath }, bufnr, opts)
				
				-- Disable TreeSitter highlighting for this buffer to prevent errors
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(bufnr) then
						-- Disable TreeSitter highlighting
						vim.treesitter.stop(bufnr)
						
						-- Enable basic syntax highlighting instead
						local ft = vim.filetype.match({ buf = bufnr, filename = filepath })
						if ft and ft ~= "" then
							vim.bo[bufnr].filetype = ft
							vim.cmd(string.format("silent! syntax enable | silent! set filetype=%s", ft))
						end
					end
				end)
			end,
		},
		pickers = {
			buffers = {
				mappings = {
					i = {
						["<C-d>"] = "delete_buffer",
					},
				},
			},
		},
		extensions = extensions,
	})

	for _, extension in ipairs(extensions_to_load) do
		telescope.load_extension(extension)
	end

	vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fq", "<cmd>Telescope quickfix<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fw", "<cmd>Telescope workspaces<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fv", "<cmd>Telescope vim_bookmarks current_file<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>fV", "<cmd>Telescope vim_bookmarks all<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>ft", "<cmd>Telescope telescope-tabs list_tabs<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>bf", "<cmd>Telescope file_browser<CR>", { noremap = true })
	vim.keymap.set("n", "<leader>bh", "<cmd>Telescope file_browser hidden=true<CR>", { noremap = true })
end

return M
