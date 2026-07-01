local M = {}

local icons = require("config.icons")

function M.setup()
	local signs = {
		{ name = "DiagnosticSignError", text = icons.diagnostics.Error },
		{ name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
		{ name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
		{ name = "DiagnosticSignInfo", text = icons.diagnostics.Info },
	}
	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
	end

	-- Diagnostic configuration (Neovim 0.12+ compatible)
	local config = {
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
		},

		diagnostic = {
			virtual_lines = false,
			virtual_text = false,
			--virtual_text = { spacing = 4, prefix = "●" },
			--virtual_text = {
			--	severity = {
			--		min = vim.diagnostic.severity.ERROR,
			--	},
			--},
			signs = {
				active = signs,
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				focusable = true,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		},
	}

	-- Diagnostic configuration
	vim.diagnostic.config(config.diagnostic)

	-- Hover configuration (Neovim 0.12+ compatible)
	vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, cfg)
		vim.lsp.handlers.hover(err, result, ctx, vim.tbl_extend("force", cfg or {}, config.float))
	end

	-- Signature help configuration (Neovim 0.12+ compatible)
	vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, cfg)
		vim.lsp.handlers.signature_help(err, result, ctx, vim.tbl_extend("force", cfg or {}, config.float))
	end
end

return M
