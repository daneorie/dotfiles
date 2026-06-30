local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	git = { timeout = 240 },

	{
		"folke/neoconf.nvim",
		cmd = "Neoconf",
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
	},

	-- WhichKey
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("config.which-key").setup()
		end,
	},

	-- Colorschemes
	{
		"EdenEast/nightfox.nvim",
		config = function()
			vim.cmd.colorscheme([[nightfox]])
		end,
		enabled = true,
	},

	-- Better icons
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })
		end,
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim", -- show git decorations in buffers
		event = "BufReadPre",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},
	{
		"f-person/git-blame.nvim",
		cmd = "GitBlameToggle",
	},
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup({
				enable_builtin = true,
				suppress_missing_scope = {
					projects_v2 = true,
				},
			})
			vim.cmd([[hi OctoEditable guibg=none]])
		end,
	},
	{
		"sindrets/diffview.nvim",
		config = function()
			require("config.diffview").setup()
		end,
	},

	-- Better surround
	{
		"kylechui/nvim-surround",
		config = function()
			require("config.surround").setup()
		end,
	},

	-- IDE
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		config = function()
			require("config.undotree").setup()
		end,
	},

	-- Jumps
	--{
	--	"christoomey/vim-tmux-navigator",
	--	config = function()
	--		require("config.vim-tmux-navigator").setup()
	--	end,
	--},
	{
		"numToStr/Navigator.nvim",
		config = function()
			require("config.navigator").setup()
		end,
	},
	{
		url = "https://codeberg.org/andyg/leap.nvim",
		dependencies = { "tpope/vim-repeat" },
		config = function()
			-- add_default_mappings() is deprecated; use explicit keymaps instead
			-- Sneak-style layout: s=forward, S=backward, gs=from-window
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", {
				desc = "Leap forward",
			})
			vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", {
				desc = "Leap backward",
			})
			vim.keymap.set("n", "gs", "<Plug>(leap-from-window)", {
				desc = "Leap from window",
			})
		end,
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		event = "BufReadPre",
		config = function()
			require("config.lualine").setup()
		end,
	},

	-- Treesitter (built-in to Neovim 0.12+)
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup {}
			require("config.treesitter").setup()
		end,
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
			{
				"windwp/nvim-ts-autotag",
				event = "InsertEnter",
				config = function()
					require("nvim-ts-autotag").setup()
				end,
			},
		},
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		event = { "VimEnter" },
		config = function()
			require("config.telescope").setup()
		end,
		dependencies = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"LinArcX/telescope-env.nvim",
			"daneorie/telescope-insert-path.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "LukasPietzschmann/telescope-tabs",         config = true },
			{
				"nvim-telescope/telescope-ui-select.nvim",
				config = function()
					require("config.telescope-ui-select").setup()
				end,
			},
			{
				"tom-anders/telescope-vim-bookmarks.nvim",
				config = function()
					require("config.bookmarks").setup()
				end,
			},
			{
				"AckslD/nvim-neoclip.lua",
				dependencies = { "tami5/sqlite.lua" },
				config = function()
					require("config.neoclip").setup()
				end,
			},
			{
				"ThePrimeagen/harpoon",
				config = function()
					require("config.harpoon").setup()
				end,
			},
		},
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
			"nvim-telescope/telescope-dap.nvim",
			"leoluz/nvim-dap-go",
			"jbyuki/one-small-step-for-vimkind",
			"mxsdev/nvim-dap-vscode-js",
			{
				"microsoft/vscode-js-debug",
				build = "npm install --legacy-peer-deps && npm run compile",
			},
		},
		config = function()
			require("config.dap").setup()
		end,
	},

	-- File Explorer
	{
		"stevearc/oil.nvim",
		config = function()
			require("config.oil").setup()
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("config.cmp").setup()
		end,
		dependencies = {
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp",
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
				config = function()
					--require("config.snip").setup()
				end,
			},
		},
	},

	-- LSP (using native vim.lsp.config in Neovim 0.12+)
	{
		"neovim/nvim-lspconfig",
		lazy = true, -- loaded by Mason and typescript-tools
	},

	-- LSP Management
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
			-- Initialize LSP after Mason
			require("config.lsp").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		config = function()
			require("config.lsp.mason-config").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = { "codelldb", "stylua", "shfmt", "shellcheck", "prettierd" },
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
	{
		"jayp0521/mason-null-ls.nvim",
		dependencies = { "mason.nvim" },
	},

	-- LSP Utilities
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("config.lsp.null-ls").setup()
		end,
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		config = function()
			require("config.lsp.lsp-inlayhints").setup()
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		config = true,
	},
	{
		"pierreglaser/folding-nvim",
	},
	{
		"RRethy/vim-illuminate",
		config = function()
			require("config.illuminate").setup()
		end,
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		config = function()
			require("fidget").setup()
		end,
	},
	{
		"SmiteshP/nvim-navic",
		config = function()
			require("nvim-navic").setup()
		end,
	},
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		keys = { [[<C-`>]], [[<C-\>]] },
		cmd = { "ToggleTerm", "TermExec" },
		config = function()
			require("config.toggleterm").setup()
		end,
	},

	-- quickly select the closest text object among a group of candidates
	{
		"sustech-data/wildfire.nvim",
		config = function()
			require("wildfire").setup({
				keymaps = {
					init_selection = "<Space>",
					node_incremental = "<Space>",
					node_decremental = "<BS>",
				},
			})
		end,
	},

	-- Fuzzy Finder/Telescope/Navigation
	{
		"junegunn/fzf.vim",
		dependencies = { "junegunn/fzf", build = ":call fzf#install()" },
	},
	{
		"ThePrimeagen/git-worktree.nvim",
	},

	-- Better comment
	{
		"numToStr/Comment.nvim",
		config = function()
			require("config.comment").setup()
		end,
	},

	-- Utility
	{
		"neoclide/coc.nvim", -- a fast code completion engine
		branch = "release",
	},
	{
		"folke/zen-mode.nvim",
		config = function()
			require("config.zen-mode").setup()
		end,
	},
	{
		"tpope/vim-unimpaired",
		dependencies = { "tpope/vim-repeat" },
	},
	{
		"tpope/vim-abolish",
	},

	-- Note Taking
	{
		"lervag/wiki.vim",
		config = function()
			require("config.wiki").setup()
		end,
		enabled = false,
	},

	-- REST
	{
		"vhyrro/luarocks.nvim",
		priority = 1000,
		opts = {
			rocks = {
				"lua-curl",
				"nvim-nio",
				"mimetypes",
				"xml2lua",
				"magick",
			},
		},
		config = function(_, opts)
			-- luarocks 3.13+ vendors dkjson inside luarocks/vendor/ instead of
			-- exposing it as a top-level module. Add the vendor path so that
			-- require("dkjson") works when luarocks.loader is loaded.
			local rocks_path = vim.fn.stdpath("data") .. "/lazy/luarocks.nvim/.rocks"
			local vendor_path = rocks_path .. "/share/lua/5.1/luarocks/vendor/?.lua"
			if not package.path:find(vendor_path, 1, true) then
				package.path = package.path .. ";" .. vendor_path
			end
			require("luarocks-nvim").setup(opts)
		end,
	},
	{
		"mistweaverco/kulala.nvim",
		ft = { "http", "rest" },
		keys = {
			{
				"<localleader>rr",
				"<cmd>lua require('kulala').run()<cr>",
				desc = "Run request under the cursor",
				ft = { "http", "rest" },
			},
			{
				"<localleader>rl",
				"<cmd>lua require('kulala').run_all()<cr>",
				desc = "Run all requests",
				ft = { "http", "rest" },
			},
			{
				"<localleader>re",
				"<cmd>lua require('kulala').set_selected_env()<cr>",
				desc = "Set environment",
				ft = { "http", "rest" },
			},
		},
		config = function()
			require("kulala").setup({
				-- Request display options
				display = {
					border = "rounded",
					title = "Kulala",
				},
				-- Response window options
				response = {
					max_width = 120,
					max_height = 40,
				},
			})

			-- Set up keybindings for kulala response buffers
			-- Hook into kulala's response buffer creation
			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*",
				callback = function()
					local bufname = vim.api.nvim_buf_get_name(0)
					-- Check if this is a kulala response buffer (buffer name contains 'kulala://' and has kulala_ui filetype)
					if bufname:match("kulala://") or vim.bo.filetype:match("%.kulala_ui$") then
						local opts = { noremap = true, silent = true, buffer = true }
						vim.keymap.set("n", "(", function()
							-- Use the UI module directly to show previous response
							local ui = require("kulala.ui")
							ui.show_previous()
						end, vim.tbl_extend("force", opts, { desc = "Previous HTTP response" }))

						vim.keymap.set("n", ")", function()
							-- Use the UI module directly to show next response
							local ui = require("kulala.ui")
							ui.show_next()
						end, vim.tbl_extend("force", opts, { desc = "Next HTTP response" }))
					end
				end,
			})
		end,
	},

	-- TypeScript / JavaScript
	{
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
	},

	-- Rust
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
		ft = { "rust" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup({
				null_ls = {
					enabled = true,
					name = "crates.nvim",
				},
			})
		end,
	},

	-- Task Runner and Job Management
	{
		"stevearc/overseer.nvim",
		opts = {},
	},

	-- Go
	{
		"ray-x/go.nvim",
		ft = { "go" },
		config = function()
			require("go").setup()
		end,
		enabled = true,
	},

	-- Java
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
	},

	-- Scratch Buffer
	{
		"mtth/scratch.vim",
	},

	-- Dimming inactive panes
	{
		"levouh/tint.nvim",
		config = function()
			require("tint").setup()
		end,
	},

	-- Aerial
	{
		"stevearc/aerial.nvim",
		opts = {},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("aerial").setup({
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
			})
		end,
	},

	-- Improved Searching
	{
		"backdround/improved-search.nvim",
		config = function()
			require("config.improved-search").setup()
		end,
	},

	-- Trouble
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},

	-- Align
	{
		"Vonr/align.nvim",
		branch = "v2",
		lazy = true,
		init = function()
			require("config.align").init()
		end,
	},

	-- Markdown
	{
		"jakewvincent/mkdnflow.nvim",
		config = function()
			require("config.mkdnflow").setup()
		end,
		enabled = true,
	},
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		priority = 500, -- Lower priority than treesitter to ensure proper load order
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("markview").setup({
				experimental = { check_rtp_message = false },
			})
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},

	-- Better navigation with Tab
	{
		"boltlessengineer/smart-tab.nvim",
		config = function()
			require("smart-tab").setup()
		end,
		enabled = false,
	},

	-- Improved quickfix list
	{
		"kevinhwang91/nvim-bqf",
		config = function()
			require("bqf").setup({
				func_map = {
					drop = "k",
					openc = "K",
				},
				--filter = {
				--	fzf = {
				--		action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
				--		extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
				--	},
				--},
			})
		end,
	},

	-- Kitty Images
	{
		"3rd/image.nvim",
		enabled = false,
	},

	-- Markdown Images
	{
		"edluffy/hologram.nvim",
		config = function()
			require("hologram").setup({
				auto_display = true, -- WIP automatic markdown image display, may be prone to breaking
			})
		end,
		enabled = false,
	},

	-- This prevents embedded instances of NVIM, which can happen when doing `git commit`, for example
	{
		"brianhuster/unnest.nvim",
		lazy = false,
	},

	{
		"mrjones2014/smart-splits.nvim",
		lazy = false,
		config = function()
			-- these keymaps will also accept a range,
			--vim.keymap.set('n', '<A-n>', require('smart-splits').resize_left)
			--vim.keymap.set('n', '<A-e>', require('smart-splits').resize_down)
			--vim.keymap.set('n', '<A-i>', require('smart-splits').resize_up)
			--vim.keymap.set('n', '<A-o>', require('smart-splits').resize_right)
			-- moving between splits
			vim.keymap.set("n", "<C-n>", require("smart-splits").move_cursor_left)
			vim.keymap.set("n", "<C-e>", require("smart-splits").move_cursor_down)
			vim.keymap.set("n", "<C-i>", require("smart-splits").move_cursor_up)
			vim.keymap.set("n", "<C-o>", require("smart-splits").move_cursor_right)
			-- swapping buffers between windows
			vim.keymap.set("n", "<leader><leader>n", require("smart-splits").swap_buf_left)
			vim.keymap.set("n", "<leader><leader>e", require("smart-splits").swap_buf_down)
			vim.keymap.set("n", "<leader><leader>i", require("smart-splits").swap_buf_up)
			vim.keymap.set("n", "<leader><leader>o", require("smart-splits").swap_buf_right)
		end,
	},
})

-- Load options after lazy.nvim is set up
require("config.options").setup()
