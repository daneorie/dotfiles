vim.cmd([[
	setlocal tabstop=2
	setlocal shiftwidth=2
	setlocal expandtab
	setlocal commentstring=#\ %s
	setlocal conceallevel=0

	"map <CR> <Plug>RestNvim
	"map <Tab> <Plug>RestNvimPreview
	"map <S-Tab> <Plug>RestNvimLast
]])

-- Set buffer-local keymaps for HTTP files
local opts = { noremap = true, silent = true, buffer = 0 }

-- Format current buffer with kulala-fmt
vim.keymap.set("n", "<localleader>f", function()
	vim.cmd("silent! %!kulala-fmt format --stdin")
end, vim.tbl_extend("force", opts, { desc = "Format HTTP file with kulala-fmt" }))

-- Enhanced LSP keymaps for HTTP files
vim.keymap.set(
	"n",
	"<localleader>gd",
	vim.lsp.buf.definition,
	vim.tbl_extend("force", opts, { desc = "Go to definition" })
)
vim.keymap.set(
	"n",
	"<localleader>gr",
	vim.lsp.buf.references,
	vim.tbl_extend("force", opts, { desc = "Find references" })
)
vim.keymap.set(
	"n",
	"<localleader>K",
	vim.lsp.buf.hover,
	vim.tbl_extend("force", opts, { desc = "Show hover documentation" })
)

-- Completion for HTTP files
vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
