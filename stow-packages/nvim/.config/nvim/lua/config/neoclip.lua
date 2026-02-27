local M = {}

function M.setup()
	require("neoclip").setup({
		keys = {
			telescope = {
				n = {
				},
				i = {
					edit = '<c-a>',
				},
			}
		}
	})

	local t_status_ok, telescope = pcall(require, "telescope")
	if t_status_ok then
		telescope.load_extension("neoclip")
	end
end

return M
