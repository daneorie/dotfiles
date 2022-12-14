local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
	augroup packer_user_config
		autocmd!
		autocmd BufWritePost plugins.lua source <afile> | PackerSync
	augroup end
]])

-- Use a protected call so we don"t error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return require("packer").startup(function(use)
	use "wbthomason/packer.nvim" -- Have packer manage itself

	-- Lua Development
	use "nvim-lua/plenary.nvim" -- Useful lua functions used by lots of plugins
	use "nvim-lua/popup.nvim"
	use "folke/lua-dev.nvim"

	-- LSP
	use "neovim/nvim-lspconfig" -- enable LSP
	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"
	use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
	use "ray-x/lsp_signature.nvim"
	use "SmiteshP/nvim-navic"
	use "simrat39/symbols-outline.nvim"
	use "b0o/SchemaStore.nvim"
	use "RRethy/vim-illuminate"
	use "j-hui/fidget.nvim"
	use "lvimuser/lsp-inlayhints.nvim"
	use "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
	use "pierreglaser/folding-nvim"

	-- Completion
	use "hrsh7th/nvim-cmp" -- The completion plugin
	use "hrsh7th/cmp-buffer" -- buffer completions
	use "hrsh7th/cmp-path" -- path completions
	use "saadparwaiz1/cmp_luasnip" -- snippet completions
	use "hrsh7th/cmp-nvim-lsp"
	use "hrsh7th/cmp-nvim-lua"

	-- Snippets
	use "L3MON4D3/LuaSnip" -- snippet engine
	use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

	-- Syntax/Treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() require("nvim-treesitter.install").update({ with_sync = true }) end,
	}
	use "nvim-treesitter/nvim-treesitter-textobjects"
	--use "kylechui/nvim-surround"

	-- Marks
	use "christianchiarulli/harpoon"
	use "MattesGroeger/vim-bookmarks"
	use "natecraddock/sessions.nvim"
	use "natecraddock/workspaces.nvim"

	-- Fuzzy Finder/Telescope
	use "nvim-telescope/telescope.nvim"
	use "nvim-telescope/telescope-ui-select.nvim"
	use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
	use "nvim-telescope/telescope-file-browser.nvim"
	use "tom-anders/telescope-vim-bookmarks.nvim"

	-- Note Taking
	use "nvim-orgmode/orgmode"

	-- Colorschemes
	use "EdenEast/nightfox.nvim" -- theme

	-- Ulility
	use "lewis6991/impatient.nvim"
	--use { "neoclide/coc.nvim", branch = "release" } -- a fast code completion engine
	use { "mg979/vim-visual-multi", branch = "master" }

	-- Icon
	use "kyazdani42/nvim-web-devicons"

	-- Debugging
	use "mfussenegger/nvim-dap"
	use "rcarriga/nvim-dap-ui"
	--use "ravenxrz/DAPInstall.nvim"

	-- Tabline
	--use "bagrat/vim-buffet" -- buffer labeling
	use "kdheepak/tabline.nvim"

	-- Statusline
	use "nvim-lualine/lualine.nvim"

	-- Startup
	use "mhinz/vim-startify" -- a really handy start page with lots of customizations

	-- Indent
	use "lukas-reineke/indent-blankline.nvim"

	-- File Explorer
	use "kyazdani42/nvim-tree.lua"

	-- Comment
	use "preservim/nerdcommenter" -- an easy way for commenting out lines

	-- Terminal
	use "akinsho/toggleterm.nvim"

	-- Git
	use "lewis6991/gitsigns.nvim" -- show git decorations in buffers

	-- Editing Support
	use "windwp/nvim-autopairs" -- Autopairs, integrates with both cmp and treesitter

	-- Keybinding
	use "folke/which-key.nvim"

	-- Java
	use "mfussenegger/nvim-jdtls" -- Java LSP

	-- Markdown
	use {
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
		ft = { "markdown" },
	}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
