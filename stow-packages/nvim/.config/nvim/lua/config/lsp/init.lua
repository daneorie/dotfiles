local M = {}

-- Neovim 0.12+ native LSP configuration
-- Server configurations are declared via vim.lsp.config and managed by mason-lspconfig
-- See :help vim.lsp.config

-- Setup handlers and diagnostics first
require("config.lsp.handlers").setup()

-- Global capabilities setup
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		"documentation",
		"detail",
		"additionalTextEdits",
	},
}

-- Integrate with nvim-cmp if available
pcall(function()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
end)

M.capabilities = capabilities

-- on_attach handler for LspAttach autocmd
function M.on_attach(client, bufnr)
	local caps = client.server_capabilities

	-- Enable completion triggered by <C-X><C-O>
	if caps.completionProvider then
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	end

	-- Use LSP as the handler for formatexpr
	if caps.documentFormattingProvider then
		vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
	end

	-- Configure key mappings
	require("config.lsp.keymaps").setup(client, bufnr)

	-- Configure highlighting
	require("config.lsp.highlighter").setup(client, bufnr)

	-- Configure formatting
	require("config.lsp.null-ls.formatters").setup(client, bufnr)

	-- tagfunc
	if caps.definitionProvider then
		vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
	end

	-- Configure for jdtls
	if client.name == "jdt.ls" then
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("jdtls.dap").setup_dap_main_class_configs()
		vim.lsp.codelens.refresh()
	end

	-- nvim-navic
	if caps.documentSymbolProvider then
		local navic = require("nvim-navic")
		navic.attach(client, bufnr)
	end

	-- sqls
	if client.name == "sqls" then
		require("sqls").on_attach(client, bufnr)
	end

	if client.name ~= "null-ls" then
		-- inlay-hints (uncomment if using lsp-inlayhints)
		-- local ih = require "inlay-hints"
		-- ih.on_attach(client, bufnr)
	end
end

-- Wire up on_attach for all LSP clients
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client then
			M.on_attach(client, event.buf)
		end
	end,
})

-- Diagnostics toggle function
local diagnostics_active = true

function M.toggle_diagnostics()
	diagnostics_active = not diagnostics_active
	if diagnostics_active then
		vim.diagnostic.show()
	else
		vim.diagnostic.hide()
	end
end

function M.remove_unused_imports()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })
	vim.cmd("packadd cfilter")
	vim.cmd("Cfilter /main/")
	vim.cmd("Cfilter /The import/")
	vim.cmd("cdo normal dd")
	vim.cmd("cclose")
	vim.cmd("wa")
end

function M.setup()
	-- Inlay hints setup
	require("config.lsp.lsp-inlayhints").setup()
end

return M
