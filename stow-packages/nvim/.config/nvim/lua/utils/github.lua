local M = {}

--- Normalize a git remote URL to an HTTPS GitHub/GitLab/Bitbucket base URL
--- @param remote string git remote URL (SSH or HTTPS)
--- @return string|nil normalized HTTPS base URL (without trailing slash) or nil if unsupported
local function normalize_remote(remote)
	if not remote or remote == "" then
		return nil
	end

	-- SSH format: git@github.com:org/repo.git
	local ssh_match = remote:match("^git@([^:]+):(.+)%.git$")
	if ssh_match then
		local host, path = ssh_match, remote:match("^git@[^:]+:(.+)%.git$")
		return "https://" .. host .. "/" .. path
	end

	-- HTTPS format: https://github.com/org/repo.git
	local https_match = remote:match("^https?://([^/]+)/(.+)%.git$")
	if https_match then
		local host, path = https_match, remote:match("^https?://[^/]+/(.+)%.git$")
		return "https://" .. host .. "/" .. path
	end

	-- Unsupported format
	return nil
end

--- Get the GitHub/GitLab/Bitbucket URL for a file or directory
--- @param abs_path string absolute path to file or directory
--- @return string|nil the composed URL or nil if not in a git repo or remote is invalid
function M.get_github_url(abs_path)
	if not abs_path or abs_path == "" then
		vim.notify("No path provided", vim.log.levels.WARN)
		return nil
	end

	-- Determine the directory to run git commands in
	local dir = abs_path
	if vim.fn.isdirectory(abs_path) == 0 then
		dir = vim.fn.fnamemodify(abs_path, ":h")
	end

	-- Get the worktree root
	local worktree_root_cmd = "git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null"
	local worktree_root = vim.fn.system(worktree_root_cmd):gsub("\n$", "")
	if worktree_root == "" or worktree_root:match("fatal:") then
		vim.notify("Not in a git repository", vim.log.levels.WARN)
		return nil
	end

	-- Get the branch name
	local branch_cmd = "git -C " .. vim.fn.shellescape(dir) .. " rev-parse --abbrev-ref HEAD 2>/dev/null"
	local branch = vim.fn.system(branch_cmd):gsub("\n$", "")
	if branch == "" or branch:match("fatal:") then
		vim.notify("Could not determine git branch", vim.log.levels.WARN)
		return nil
	end

	-- Get the remote URL
	local remote_cmd = "git -C " .. vim.fn.shellescape(dir) .. " remote get-url origin 2>/dev/null"
	local remote = vim.fn.system(remote_cmd):gsub("\n$", "")
	if remote == "" or remote:match("fatal:") then
		vim.notify("No git remote 'origin' found", vim.log.levels.WARN)
		return nil
	end

	-- Normalize the remote to HTTPS base URL
	local base_url = normalize_remote(remote)
	if not base_url then
		vim.notify("Unsupported git remote format: " .. remote, vim.log.levels.WARN)
		return nil
	end

	-- Compute relative path from worktree root
	local rel_path = abs_path
	if abs_path:sub(1, #worktree_root) == worktree_root then
		rel_path = abs_path:sub(#worktree_root + 2) -- +2 to skip the trailing slash
	end

	-- Determine blob vs tree
	local url_type = "blob"
	if vim.fn.isdirectory(abs_path) == 1 then
		url_type = "tree"
		-- Ensure directory path has a trailing slash for consistency
		if not rel_path:match("/$") then
			rel_path = rel_path .. "/"
		end
	end

	-- Construct the final URL
	local url = base_url .. "/" .. url_type .. "/" .. branch .. "/" .. rel_path

	return url
end

return M
