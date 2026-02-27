vim.cmd([[
	hi! link netrwMarkFile Search
]])

vim.api.nvim_create_autocmd("filetype", {
	pattern = "netrw",
	desc = "Better mappings for netrw",
	callback = function()
		local bind = function(lhs, rhs)
			vim.keymap.set("n", lhs, rhs, { noremap = true, buffer = true })
		end

		-- navigation: dir hierarchy
		bind("<BS>", "<Plug>NetrwBrowseUpDir")
		bind("n", "<Plug>NetrwBrowseUpDir")
		bind("o", "<Plug>NetrwLocalBrowseCheck")

		-- navigation: dir contents
		bind("i", "<up>")

		-- toggle the dotfiles
		bind(".", "<cmd>call <SNR>77_NetrwHidden(1)<CR>")

		-- close the preview window
		bind("P", "<C-w>z")

		-- cycle between tree listings
		bind("h", "<cmd>call <SNR>77_NetrwListStyle(1)<CR>")

		-- create a new file
		bind("a", "<Plug>NetrwOpenFile:w<CR>:Explore<CR>")

		-- rename file
		bind("r", "<cmd>call <SNR>77_NetrwLocalRename(expand('%:p:h'))<CR>")
	end,
})
