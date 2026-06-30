local M = {}

local function setup_treesitter()
	local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
	if not status_ok then
		vim.notify("nvim-treesitter not found!", vim.log.levels.ERROR)
		return
	end

	-- Force using plugin parsers over system parsers to avoid conflicts
	local install_ok, install = pcall(require, "nvim-treesitter.install")
	if install_ok then
		install.prefer_git = true
	end

	-- Add custom parser directory to runtime path
	local parser_dir = vim.fn.stdpath("data") .. "/treesitter"
	vim.opt.runtimepath:append(parser_dir)

	local config = {
		parser_install_dir = parser_dir,
		ensure_installed = {
			-- Only install essential parsers to minimize issues
			"lua",
			"vim",
			"vimdoc",
			"markdown",
			"markdown_inline",
			"javascript",
			"typescript",
			"json",
			"yaml",
			"html",
			"css",
		},
		ignore_install = { "phpdoc" },
		sync_install = false,
		auto_install = false, -- Disable auto-install to prevent issues
		highlight = {
			enable = false, -- Keep disabled until everything is stable
			additional_vim_regex_highlighting = false,
		},
		autopairs = {
			enable = false,
		},
		indent = {
			enable = false,
		},
		textobjects = {
			select = {
				enable = false,
			},
			move = {
				enable = false,
			},
			swap = {
				enable = false,
			},
		},
	}

	treesitter_configs.setup(config)
end

function M.setup()
	-- Wrap in pcall to prevent errors from breaking the entire config
	local ok, err = pcall(setup_treesitter)
	if not ok then
		vim.notify("Treesitter setup failed: " .. tostring(err), vim.log.levels.WARN)
	end
end

return M
