local M = {}

function M.P(v)
	print(vim.inspect(v))
	return v
end

if pcall(require, "plenary") then
	RELOAD = require("plenary.reload").reload_module

	function M.R(name)
		RELOAD(name)
		return require(name)
	end
end


return M
