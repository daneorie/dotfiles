local M = {}

local g = vim.g

function M.setup()
	g.wiki_root = vim.fn.getenv("WIKI_HOME")
	g.wiki_filetypes = { "md", "wiki" }
	g.wiki_journal = {
		name = 'journal',
		root = '',
		frequency = 'daily',
		date_format = {
			daily = "%Y/%m/%Y-%m-%d",
			weekly = "%Y/%Y-week_%V",
			monthly = "%Y/%m/%Y-%m-summary",
		},
	}
	g.wiki_mappings_local = {
		["o_<plug>(wiki-it)"] = "",
		["x_<plug>(wiki-it)"] = "",
		["o_<plug>(wiki-iu)"] = "",
		["x_<plug>(wiki-iu)"] = "",
	}
	g.wiki_mappings_local_journal = {
		["<plug>(wiki-journal-prev)"] = "<s-c-n>",
		["<plug>(wiki-journal-next)"] = "<s-c-o>",
	}
	g.wiki_link_creation.md = {
		link_type = "md",
		url_extension = ".md",
		url_transform = function(x)
			-- the filename will always be lowercase
			local path = x:lower()

			-- This is not truly exhaustive as it should be, but for most of my use cases, I will only have spaces and/or colons.
			path = string.gsub(path, " ", "-") -- replace spaces with dashes
			path = string.gsub(path, "&", "and") -- replace ampersand with the word "and"
			path = string.gsub(path, ":", "") -- remove colons
			path = string.gsub(path, ",", "") -- remove commas

			-- Remove the .md extension if it exists, because it will be automatically added later.
			path = string.gsub(path, ".md$", "")

			-- Remove any remaining periods
			path = string.gsub(path, ".", "") -- remove periods

			-- If the relative path of the file is already specified, then remove it from the link description/name but keep the path for the link.
			if string.find(x, "/") then
				local link_description = string.gsub(x, "^.*/", "") or x

				-- Remove the './' if it's specified, since that's implied if there is no path given. './' would be specified at all to ensure the auto-nesting behavior doesn't occur.
				path = string.gsub(path, "^./", "") or path

				return path
			end

			local current_file = vim.fn.expand("%:t:r"):lower()
			-- If the current file is index, then don't try to put the link in a subfolder like everywhere else.
			if current_file == "index" then
				return path
			end

			-- Create the new link in a subfolder using the name of the current file. This creates an auto-nesting behavior.
			return current_file .. "/" .. path
		end,
	}
end

return M
