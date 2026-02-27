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

-- Completion for HTTP files
vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
