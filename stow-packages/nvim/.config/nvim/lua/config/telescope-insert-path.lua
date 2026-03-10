local M = {}

local insert_path_n_mappings = {}
local insert_path_i_mappings = {}

local i_status_ok, path_actions = pcall(require, "telescope_insert_path")
if i_status_ok then
	insert_path_n_mappings = {
		["["] = path_actions.insert_reltobufpath_visual,
		["]"] = path_actions.insert_abspath_visual,
		["{"] = path_actions.insert_reltobufpath_insert,
		["}"] = path_actions.insert_abspath_insert,
		["-"] = path_actions.insert_reltobufpath_normal,
		["="] = path_actions.insert_abspath_normal,
	}
	insert_path_i_mappings = {
		["\x33[91;5u"] = path_actions.insert_reltobufpath_visual, -- <C-[>
		["<C-]>"] = path_actions.insert_abspath_visual, -- <C-]>
		["<C-{>"] = path_actions.insert_reltobufpath_insert, -- <C-{>
		["<C-}>"] = path_actions.insert_abspath_insert, -- <C-}>
		["<C-->"] = path_actions.insert_reltobufpath_normal, -- <C-->
		["<C-=>"] = path_actions.insert_abspath_normal, -- <C-=>
	}
end

function M.n_mappings() return insert_path_n_mappings end
function M.i_mappings() return insert_path_i_mappings end

return M
