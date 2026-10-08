# Shell Functions

# Work-specific functions (C1)
function awsCredentials {
	cloudsentry access get --account ${1:-$AWS_PROFILE} --ba ${2:-$BA}
}

# Git functions
function gc {
	git clone git@github.com:ORG/backend.git "$1" && cd "$1" && git checkout "$1"
}

function mergeMain {
	cd ../main && git pull && git merge main && npm run install:all
}

function mergeDev {
	cd ../dev && git pull && git merge dev && npm ci
}

# Text processing functions
function reverseOrder {
	grep -n "" | sort -rn | sed 's/^[0-9]*://'
}

function readresponse {
	gunzip -c | jq
}

function readbody {
	read body
	if [[ -n "$body" ]]; then
		echo "$body" | base64 --decode | gunzip -c | jq
	else
		echo "$1" | base64 --decode | gunzip -c | jq
	fi
}

function urldecode {
	read url
	if [[ -n "$url" ]]; then
		echo "$url" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	else
		echo "$1" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	fi
}

# Utility functions
function define() {
	/usr/local/bin/define $* | grep -n "." | sort -nr | sed '1,4d' | sort -n | sed 's/^[0-9]*://' | $PAGER
}

function c() {
    $HOME/dotfiles/shell/scripts/cht.sh "$@" | $PAGER
}

function rmpwd {
	dir="$(pwd)"
	cd ..
	rm -rf "$dir"
}

# Spin up a new PR testing worktree and server
# Usage: prtest
# Reads branch name from clipboard, creates worktree, opens WezTerm workspace, and runs setup commands
function prtest() {
	local bare_repo="$HOME/repos/global-fuelight-refuel-experience"
	local branch=$(pbpaste)
	local worktree_name=$(echo "$branch" | tr '/' '-')
	local worktree_path="$bare_repo/$worktree_name"
	local workspace_name="global-fuelight-refuel-experience/$worktree_name"

	# Validate branch name from clipboard
	if [[ -z "$branch" ]]; then
		echo "Error: Clipboard is empty. Copy a branch name first."
		return 1
	fi

	# Check if worktree already exists
	if [[ -d "$worktree_path" ]]; then
		echo "Worktree already exists: $worktree_path"
		echo "Reusing existing worktree..."
	else
		echo "Creating worktree for branch: $branch"
		echo "Worktree name: $worktree_name"
		echo "Workspace name: $workspace_name"
		echo ""

		# Fetch the branch from origin first (must be done from a worktree with origin configured)
		if ! git fetch origin "$branch"; then
			echo "Error: Failed to fetch branch from origin"
			return 1
		fi

		# Create the worktree in the bare repo
		cd "$bare_repo" || return 1
		
		# Create worktree with tracking branch
		if ! git worktree add -b "$branch" "$worktree_name"; then
			echo "Error: Failed to create worktree"
			return 1
		fi

		echo "✓ Worktree created"
		echo ""
	fi

	echo "Starting setup in WezTerm workspace..."
	echo ""

	# Create a temporary setup script
	local setup_script=$(mktemp /tmp/prtest-setup-XXXXX.sh)
	cat > "$setup_script" << 'EOF'
#!/bin/bash
set -e

echo "Copying mock_inputs..."
cp -R ~/repos/global-fuelight-refuel-experience/dev/apps/coredata/mock_inputs/* apps/coredata/mock_inputs

echo "Running npm ci..."
npm ci

echo "Resetting environment..."
npm run reset-env

echo "Running prisma migrations..."
nx run-many -t prisma-migrate-dev

echo "Syncing Python dependencies..."
uv sync --group dev

echo "Killing any existing processes on port 4000..."
pkill -f :4000 || true

echo "Starting development servers..."
nx run-many -t serve

echo ""
echo "✓ Setup complete! You can now test the PR."
exec $SHELL
EOF
	chmod +x "$setup_script"

	# Spawn WezTerm workspace with the setup script
	wezterm cli spawn --new-window \
		--workspace "$workspace_name" \
		--cwd "$worktree_path" \
		-- bash --login "$setup_script"

	echo ""
	echo "✓ Workspace setup initiated: $workspace_name"
}

# OpenCode wrapper with session picker support
#function opencode() {
#	local registry="$HOME/.local/state/opencode/instances"
#	mkdir -p "$(dirname $registry)"
#
#	# Find a free port starting at 4096
#	local port=4096
#	while lsof -i tcp:$port >/dev/null 2>&1; do
#		port=$((port + 1))
#	done
#
#	# Register: pid:port:cwd
#	echo "$$:$port:$PWD" >> "$registry"
#
#	# Remove this entry on exit
#	trap "sed -i '' '/^$$:/d' \"$registry\"" EXIT INT TERM HUP
#
#	# Launch opencode with an exposed HTTP server
#	command opencode --port "$port" "$@"
#}
