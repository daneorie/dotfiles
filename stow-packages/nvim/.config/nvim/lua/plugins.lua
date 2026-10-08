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

-- Disable certain plugins when running in VSCode
local not_vscode = not vim.g.vscode

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
		cond = not_vscode,
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
		enabled = false,
	},
	-- Diffview
	{
		"sindrets/diffview.nvim",
		cond = not_vscode,
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
		cond = not_vscode,
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
		cond = not_vscode,
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
			require("nvim-treesitter").setup({})
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
		cond = not_vscode,
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
			{ "LukasPietzschmann/telescope-tabs", config = true },
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
				keys = {
					"<M-n>",
					"<M-e>",
					"<M-i>",
					"<M-o>",
					"<M-l>",
					"<M-u>",
					"<M-y>",
					"<M-;>",
					{ "<leader>ma", "<cmd>lua require('harpoon.mark').add_file<CR>", "n", desc = "Mark File" },
					{
						"<leader>me",
						"<cmd>lua require('harpoon.ui').toggle_quick_menu<CR>",
						"n",
						desc = "Show Marked Files",
					},
				},
				config = function()
					require("config.harpoon").setup()
				end,
			},
		},
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		cond = not_vscode,
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
		cond = not_vscode,
		config = function()
			require("config.oil").setup()
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		cond = not_vscode,
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
		cond = not_vscode,
	},

	-- LSP Management
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cond = not_vscode,
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
		cond = not_vscode,
		config = function()
			require("config.lsp.mason-config").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason.nvim" },
		cond = not_vscode,
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
		cond = not_vscode,
	},

	-- LSP Utilities
	{
		"b0o/schemastore.nvim",
		lazy = true,
		cond = not_vscode,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cond = not_vscode,
		config = function()
			require("config.lsp.null-ls").setup()
		end,
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		cond = not_vscode,
		config = function()
			require("config.lsp.lsp-inlayhints").setup()
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		cond = not_vscode,
		config = true,
	},
	{
		"pierreglaser/folding-nvim",
		cond = not_vscode,
	},
	{
		"RRethy/vim-illuminate",
		cond = not_vscode,
		config = function()
			require("config.illuminate").setup()
		end,
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		cond = not_vscode,
		config = function()
			require("fidget").setup()
		end,
	},
	{
		"SmiteshP/nvim-navic",
		cond = not_vscode,
		config = function()
			require("nvim-navic").setup()
		end,
	},
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		cond = not_vscode,
		config = function()
			require("lsp_lines").setup()
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		keys = { [[<C-`>]], [[<C-\>]] },
		cmd = { "ToggleTerm", "TermExec" },
		cond = not_vscode,
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
		cond = not_vscode,
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
		cond = not_vscode,
	},
	{
		"folke/zen-mode.nvim",
		cond = not_vscode,
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
		cond = not_vscode,
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
		cond = not_vscode,
		ft = { "rust" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		cond = not_vscode,
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
		cond = not_vscode,
		opts = {},
	},

	-- Go
	{
		"ray-x/go.nvim",
		ft = { "go" },
		cond = not_vscode,
		config = function()
			require("go").setup()
		end,
		enabled = true,
	},

	-- Java
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		cond = not_vscode,
	},

	-- Scratch Buffer
	{
		"mtth/scratch.vim",
	},

	-- Dimming inactive panes
	{
		"levouh/tint.nvim",
		cond = not_vscode,
		config = function()
			require("tint").setup()
		end,
	},

	-- Aerial
	{
		"stevearc/aerial.nvim",
		cond = not_vscode,
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
		cond = not_vscode,
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
		ft = { "markdown", "rmd" },
		config = function()
			require("config.mkdnflow").setup()
		end,
		enabled = true,
	},
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		cond = not_vscode,
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
		cond = not_vscode,
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{
		"kevalin/mermaid.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("mermaid").setup()
		end,
	},
	{
		"3rd/diagram.nvim",
		cond = not_vscode,
		dependencies = {
			{ "3rd/image.nvim", opts = {} }, -- you'd probably want to configure image.nvim manually instead of doing this
		},
		keys = {
			{
				"<leader>md", -- Show diagram hover
				function()
					require("diagram").show_diagram_hover()
				end,
				mode = "n",
				ft = { "markdown", "norg", "mermaid" }, -- Only in these filetypes
				desc = "Show diagram hover",
			},
		},
		opts = { -- you can just pass {}, defaults below
			events = {
				-- Enable automatic rendering on text changes for live preview
				render_buffer = { "InsertLeave", "BufWinEnter", "TextChanged" },
				clear_buffer = { "BufLeave" },
			},
			renderer_options = {
				mermaid = {
					background = nil, -- nil | "transparent" | "white" | "#hex"
					theme = nil, -- nil | "default" | "dark" | "forest" | "neutral"
					scale = 2, -- nil | 1 (default) | 2  | 3 | ...
					width = nil, -- nil | 800 | 400 | ...
					height = nil, -- nil | 600 | 300 | ...
					cli_args = nil, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
				},
				plantuml = {
					charset = nil,
					cli_args = nil, -- nil | { "-Djava.awt.headless=true" } | ...
				},
				d2 = {
					theme_id = nil,
					dark_theme_id = nil,
					scale = nil,
					layout = nil,
					sketch = nil,
					cli_args = nil, -- nil | { "--pad", "0" } | ...
				},
				gnuplot = {
					size = nil, -- nil | "800,600" | ...
					font = nil, -- nil | "Arial,12" | ...
					theme = nil, -- nil | "light" | "dark" | custom theme string
					cli_args = nil, -- nil | { "-p" } | { "-c", "config.plt" } | ...
				},
			},
		},
	},

	-- Better navigation with Tab
	{
		"boltlessengineer/smart-tab.nvim",
		cond = not_vscode,
		config = function()
			require("smart-tab").setup()
		end,
		enabled = false,
	},

	-- Improved quickfix list
	{
		"kevinhwang91/nvim-bqf",
		cond = not_vscode,
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
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		cond = not_vscode,
		opts = {
			processor = "magick_cli",
		},
		enabled = true,
	},

	-- Markdown Images
	{
		"edluffy/hologram.nvim",
		cond = not_vscode,
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
		cond = not_vscode,
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

	-- Timers and Reminders
	{
		"nvzone/timerly",
		dependencies = "nvzone/volt",
		cmd = "TimerlyToggle",
		cond = not_vscode,
		opts = {}, -- optional
	},
	{
		"rodolfojsv/reminders.nvim",
		cond = not_vscode,
		config = function()
			require("config.reminders").setup()
		end,
	},

	{
		"NStefan002/screenkey.nvim",
		lazy = false,
		cond = not_vscode,
		version = "*", -- or branch = "main", to use the latest commit
	},
	{
		"d2lang/d2-vim",
		ft = { "d2" },
	},

	-- database
	{
		'kristijanhusak/vim-dadbod-ui',
		dependencies = {
			{ 'tpope/vim-dadbod', lazy = true },
			{ 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
		},
		cmd = {
			'DBUI',
			'DBUIToggle',
			'DBUIAddConnection',
			'DBUIFindBuffer',
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},
})

-- Load options after lazy.nvim is set up
require("config.options").setup()
