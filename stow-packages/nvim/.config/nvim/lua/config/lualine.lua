local M = {}

local lualine = require("lualine")
local icons = require("config.icons")

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = {
		error = icons.diagnostics.Error .. " ",
		warn = icons.diagnostics.Warning .. " ",
	},
	colored = false,
	update_in_insert = false,
	always_visible = true,
}

local diff = {
	"diff",
	colored = false,
	symbols = { -- changes diff symbols
		added = icons.git.Add .. " ",
		modified = icons.git.Mod .. " ",
		removed = icons.git.Remove .. " ",
	},
	cond = hide_in_width
}

local filetype = {
	"filetype",
	icons_enabled = false,
	icon = nil,
}

local branch = {
	"branch",
	icons_enabled = true,
	icon = "",
}

local tabs = {
	"tabs",
	max_length = vim.o.columns / 3, -- Maximum width of tabs component.
	                                -- Note:
	                                -- It can also be a function that returns
	                                -- the value of `max_length` dynamically.
	mode = 0, -- 0: Shows tab_nr
	          -- 1: Shows tab_name
	          -- 2: Shows tab_nr + tab_name

	-- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
	use_mode_colors = false,

	tabs_color = {
		-- Same values as the general color option can be used here.
		active = 'lualine_{section}_normal',     -- Color for active tab.
		inactive = 'lualine_{section}_inactive', -- Color for inactive tab.
	},

	fmt = function(name, context)
		-- Show + if buffer is modified in tab
		local buflist = vim.fn.tabpagebuflist(context.tabnr)
		local winnr = vim.fn.tabpagewinnr(context.tabnr)
		local bufnr = buflist[winnr]
		local mod = vim.fn.getbufvar(bufnr, '&mod')

		return name .. (mod == 1 and ' +' or '')
	end
}

-- cool function for progress
local spaces = function()
	return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

local navic = require("nvim-navic")
local config = {
	options = {
		icons_enabled = true,
		theme = "solarized_dark",
		section_separators = { left = '', right = '' },
		component_separators = { left = '', right = '' },
		disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline", "Vista" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { diff },
		lualine_c = { {
			"filename",
			file_status = true,
			path = 0
		} },
		lualine_x = { spaces, "encoding", filetype },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { {
			"filename",
			file_status = true,
			path = 1
		} },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {
		lualine_a = { branch, diagnostics },
		lualine_b = { {
			function()
				return navic.get_location()
			end,
			cond = function()
				return navic.is_available()
			end
		} },
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { { "tabs", mode = 2 } },
	},
	extensions = {},
}

function M.setup()
	lualine.setup(config)
end

return M
