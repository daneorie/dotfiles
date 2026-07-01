local M = {}

function M.setup()
	require("mkdnflow").setup({
		mappings = {
			MkdnNewListItem = { "i", "<CR>" },
			MkdnNewListItemBelowInsert = { "n", "k" },
			MkdnNewListItemAboveInsert = { "n", "K" },
			MkdnFoldSection = { "n", "<leader>fs" },
			MkdnUnfoldSection = { "n", "<leader>Fs" },
		},
		perspective = {
			priority = "current",
		},
		wrap = true,
		links = {
			conceal = true,
			transform_explicit = function(text)
				-- the filename will always be lowercase
				local path = text:lower()

				-- This is not truly exhaustive as it should be, but for most of my use cases, I will only have spaces and/or colons.
				path = path:gsub(" ", "-") -- replace spaces with dashes
				path = path:gsub("&", "and") -- replace ampersand with the word "and"
				path = path:gsub(":", "") -- remove colons
				path = path:gsub(",", "") -- remove commas

				-- Remove the .md extension if it exists, because it will be automatically added later.
				path = path:gsub(".md$", "")

				-- Remove any remaining periods
				path = path:gsub("%.", "") -- remove periods

				-- If the relative path of the file is already specified, then remove it from the link description/name but keep the path for the link.
				if text:find("/") then
					--local link_description = text:gsub("^.*/", "") or text

					-- Remove the './' if it's specified, since that's implied if there is no path given. './' would be specified at all to ensure the auto-nesting behavior doesn't occur.
					path = path:gsub("^./", "") or path

					return path
				end

				local current_file = vim.fn.expand("%:t:r"):lower()
				-- If the current file is index, then don't try to put the link in a subfolder like everywhere else.
				if current_file == "index" then
					return path
				end

				-- Create the new link in a subfolder using the name of the current file. This creates an auto-nesting behavior.
				path = current_file .. "/" .. path

				return path
			end,
		},
	})
end

return M
