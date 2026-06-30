local M = {}

function M.setup()
	local mason_lspconfig = require("mason-lspconfig")
	local lsp_config = require("config.lsp")

	-- List of servers to ensure are installed via Mason
	local ensure_installed = {
		"gopls",
		"html",
		"jsonls",
		"pyright",
		"lua_ls",
		"vimls",
		"yamlls",
		"dockerls",
		"bashls",
		"taplo",
		-- Note: kulala_ls is not in Mason registry; install manually
		-- Note: ts_ls/tsserver handled by typescript-tools.nvim
		-- Note: rust_analyzer handled by rustaceanvim
		-- Note: jdtls handled by nvim-jdtls
	}

	mason_lspconfig.setup({
		ensure_installed = ensure_installed,
	})

	-- Setup default configuration for all LSP servers
	-- This replaces the default handler from setup_handlers in v1.x
	vim.lsp.config("*", {
		capabilities = lsp_config.capabilities,
	})

	-- Setup lua_ls with custom settings
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = vim.split(package.path, ";"),
				},
				diagnostics = {
					globals = { "vim", "describe", "it", "before_each", "after_each", "packer_plugins", "MiniTest" },
				},
				workspace = {
					checkThirdParty = false,
				},
				completion = { callSnippet = "Replace" },
				telemetry = { enable = false },
				hint = {
					enable = false,
				},
			},
		},
	})

	-- Setup server configurations via vim.lsp.config for servers with special settings

	-- gopls
	vim.lsp.config["gopls"] = vim.tbl_deep_extend("force", vim.lsp.config["gopls"] or {}, {
		settings = {
			gopls = {
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				semanticTokens = true,
			},
		},
	})

	-- jsonls
	vim.lsp.config["jsonls"] = vim.tbl_deep_extend("force", vim.lsp.config["jsonls"] or {}, {
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
			},
		},
	})

	-- pyright
	vim.lsp.config["pyright"] = vim.tbl_deep_extend("force", vim.lsp.config["pyright"] or {}, {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "off",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	})

	-- yamlls
	vim.lsp.config["yamlls"] = vim.tbl_deep_extend("force", vim.lsp.config["yamlls"] or {}, {
		settings = {
			yaml = {
				hover = true,
				completion = true,
				validate = true,
				schemas = require("schemastore").json.schemas(),
			},
		},
	})
end

return M
