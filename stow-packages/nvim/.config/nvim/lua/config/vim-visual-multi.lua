local M = {}

function M.setup()
	vim.cmd [[
		let g:VM_maps = {}
		let g:VM_maps["Find Under"]         = "<C-d>"
		let g:VM_maps["Find Subword Under"] = "<C-d>"
	]]
	--local g = vim.g
	--g.VM_maps = {}
	--g.VM_maps["Find Under"]         = "<C-d>"
	--g.VM_maps["Find Subword Under"] = "<C-d>"
end

return M
