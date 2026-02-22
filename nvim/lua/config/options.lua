local M = {}

local options = {
	backup = false, -- creates a backup file
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
	cmdheight = 2, -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0, -- so that `` is visible in markdown files
	cursorline = true, -- highlight the current line
	directory = vim.fn.getenv("HOME") .. "/.config/nvim/swap/", -- directory for the swap files
	expandtab = false, -- do not convert tabs to spaces
	fileencoding = "utf-8", -- the encoding written to a file
	foldcolumn = "3", -- space on the left of the buffer that shows the fold status and fold levels
	--foldexpr = "nvim_treesitter#foldexpr()",   -- use treesitter for determining the folding behavior
	foldlevel = 20, -- sets the level where folding automatically happens
	--foldmethod = "expr",                       -- `expr` means use a function to determing the folding behavior
	--guifont = "monospace:h17",                 -- the font used in graphical neovim applications
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	number = true, -- set numbered lines
	numberwidth = 4, -- set number column width to 2 {default 4}
	pumheight = 10, -- pop up menu height
	relativenumber = false, -- set relative numbered lines
	scrolloff = 8, --
	shiftwidth = 4, -- the number of spaces inserted for each indentation
	showmode = false, -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2, -- always show tabs
	sidescrolloff = 8, --
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	smartcase = true, -- smart case
	smartindent = true, -- make indenting smarter again
	softtabstop = 4, --
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- creates a swapfile
	tabstop = 4, -- insert 4 spaces for a tab
	--termguicolors = true,                      -- set term gui colors (most terminals support this)
	timeoutlen = 1000, -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true, -- enable persistent undo
	updatetime = 300, -- faster completion (4000ms default)
	wrap = false, -- display lines as one long line
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
}

function M.setup()
	-- Safely set options with error handling
	for k, v in pairs(options) do
		local ok, err = pcall(function()
			vim.opt[k] = v
		end)
		if not ok then
			-- Skip options that can't be set (e.g., during plugin installation)
			-- You can uncomment the line below for debugging if needed
			-- vim.notify("Failed to set option " .. k .. ": " .. tostring(err), vim.log.levels.DEBUG)
		end
	end

	-- Additional option settings with protection
	pcall(function()
		vim.opt.shortmess:append("c")
	end)

	pcall(function()
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	end)
end

--vim.cmd([[
--	hi Normal guibg=none ctermbg=none
--	hi LineNr guibg=none ctermbg=none
--	hi Folded guibg=none ctermbg=none
--	hi NonText guibg=none ctermbg=none
--	hi SpecialKey guibg=none ctermbg=none
--	hi VertSplit guibg=none ctermbg=none
--	hi SignColumn guibg=none ctermbg=none
--	hi EndOfBuffer guibg=none ctermbg=none
--]])

return M
