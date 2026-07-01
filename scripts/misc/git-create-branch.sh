#!/bin/bash

# Git Create Branch - Custom script for plan-your-day repository
# Usage: git create-branch [<type> <jira-ticket> <description>]
# Example: git create-branch feat PGAA-456 user-authentication
#
# Branch Types: feat, fix, release, docs
#
# This script:
# 1. Creates a branch with format: {type}/{jira-ticket}-{description}
# 2. Creates a worktree directory with clean name: {type}-{description}
# 3. Sets up remote tracking
# 4. Works from any directory within the git repository

set -e # Exit on any error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
	echo "Usage: git create-branch [<type> <jira-ticket> <description>]"
	echo ""
	echo "If no arguments provided, you'll be prompted for input."
	echo ""
	echo "Branch Types:"
	echo "  feat    - New features (feat/)"
	echo "  fix     - Bug and hotfixes (fix/)"
	echo "  release - Release preparation (release/)"
	echo "  docs    - Documentation updates (docs/)"
	echo ""
	echo "Examples:"
	echo "  git create-branch feat PGAA-456 user-authentication"
	echo "  git create-branch fix PGAA-789 fix-header-styling"
	echo "  git create-branch docs PGAA-654 update-readme"
	echo ""
	echo "Result:"
	echo "  Branch: feat/PGAA-456-user-authentication"
	echo "  Directory: user-authentication (created in bare repo root)"
}

# Function to validate branch type
validate_branch_type() {
	local type="$1"
	case "$type" in
	feat | fix | release | docs)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

# Function to prompt for input
prompt_for_input() {
	echo -e "${BOLD}${CYAN}Interactive Branch Creation${NC}"
	echo ""

	# Prompt for branch type using select menu
	echo "Select branch type:"
	BRANCH_TYPES=("feat" "fix" "release" "docs")
	select TYPE in "${BRANCH_TYPES[@]}"; do
		if [[ -n "$TYPE" ]]; then
			echo -e "${GREEN}✓ Selected: ${BOLD}$TYPE${NC}"
			break
		else
			echo -e "${RED}✗ Invalid selection. Please choose a number from the list.${NC}"
		fi
	done

	# Prompt for JIRA ticket
	while true; do
		read -p "Enter JIRA ticket (e.g., PGAA-456): " JIRA
		JIRA=$(echo "$JIRA" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

		if [ -n "$JIRA" ]; then
			break
		else
			echo -e "${RED}✗ JIRA ticket cannot be empty.${NC}"
			echo ""
		fi
	done

	# Prompt for description
	while true; do
		read -p "Enter description (e.g., user-authentication): " DESCRIPTION
		DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

		if [ -n "$DESCRIPTION" ]; then
			break
		else
			echo -e "${RED}✗ Description cannot be empty.${NC}"
			echo ""
		fi
	done

	echo ""
	echo -e "${BOLD}${BLUE}Summary:${NC}"
	echo -e "  Branch: ${MAGENTA}${TYPE}/${JIRA}-${DESCRIPTION}${NC}"
	echo -e "  Directory: ${CYAN}${TYPE}-${DESCRIPTION}${NC}"
	echo ""

	while true; do
		read -p "Proceed with creation? (y/n): " confirm
		case "$confirm" in
		[Yy] | [Yy][Ee][Ss])
			break
			;;
		[Nn] | [Nn][Oo])
			echo -e "${RED}✗ Branch creation cancelled.${NC}"
			exit 0
			;;
		*)
			echo "Please answer y or n."
			;;
		esac
	done
}

# Find the bare repository root
find_bare_repo_root() {
	# Check if we're in a git repository
	if ! git rev-parse --git-dir >/dev/null 2>&1; then
		echo -e "${RED}Error: Not in a git repository${NC}"
		exit 1
	fi

	# First check if .git is a file (worktree) - this is the most reliable indicator
	if [ -f ".git" ]; then
		# This is a worktree, read the .git file to find the bare repo
		local gitdir_content=$(cat ".git")
		local worktree_git_dir=${gitdir_content#gitdir: }
		# The worktree git dir is like: /path/to/bare/repo/worktrees/branch-name
		# We need to go up from "worktrees/branch-name" to get the bare repo root
		local worktrees_parent="$(dirname "$worktree_git_dir")" # /path/to/bare/repo/worktrees
		local bare_repo_root="$(dirname "$worktrees_parent")"   # /path/to/bare/repo
		echo "$bare_repo_root"
	elif [ "$(git config --get core.bare 2>/dev/null)" = "true" ]; then
		# This is a bare repo
		git rev-parse --git-dir
	else
		# This is a regular repo, find the root
		git rev-parse --show-toplevel
	fi
}

# Handle arguments
if [ $# -eq 0 ]; then
	# Interactive mode
	prompt_for_input
elif [ $# -eq 3 ]; then
	# Command line arguments
	TYPE="$1"
	JIRA="$2"
	DESCRIPTION="$3"

	# Validate branch type
	if ! validate_branch_type "$TYPE"; then
		echo -e "${RED}Error: Invalid branch type '$TYPE'${NC}"
		echo "Valid types: feature, bugfix, hotfix, release, docs"
		exit 1
	fi

	# Sanitize inputs (lowercase, replace spaces with hyphens)
	TYPE=$(echo "$TYPE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
	JIRA=$(echo "$JIRA" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
	DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
else
	echo -e "${RED}Error: Invalid number of arguments.${NC}"
	show_usage
	exit 1
fi

# Find the bare repository root
BARE_REPO_PATH=$(find_bare_repo_root)

# Create branch name and directory name
BRANCH_NAME="${TYPE}/${JIRA}-${DESCRIPTION}"
DIRECTORY_NAME="${TYPE}-${DESCRIPTION}"

echo -e "${BOLD}${BLUE}Creating branch:${NC} ${MAGENTA}$BRANCH_NAME${NC}"
echo -e "${BOLD}${BLUE}Creating worktree directory:${NC} ${CYAN}$DIRECTORY_NAME${NC} (in bare repo)"
echo -e "${BOLD}${BLUE}Bare repo path:${NC} $BARE_REPO_PATH"

# Change to bare repo directory for worktree operations
cd "$BARE_REPO_PATH"

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
	echo -e "${RED}✗ Error: Branch '$BRANCH_NAME' already exists${NC}"
	exit 1
fi

# Check if worktree directory already exists
if [ -d "$DIRECTORY_NAME" ]; then
	echo -e "${RED}✗ Error: Directory '$DIRECTORY_NAME' already exists in bare repo${NC}"
	exit 1
fi

# Create the new branch and worktree
echo -e "${YELLOW}Creating worktree and branch...${NC}"
git worktree add "$DIRECTORY_NAME" -b "$BRANCH_NAME"

# Set up remote tracking
echo -e "${YELLOW}Setting up remote tracking...${NC}"
if (cd "$DIRECTORY_NAME" && git push --no-verify --set-upstream origin "$BRANCH_NAME"); then
	echo -e "${GREEN}✓ Remote tracking set up successfully${NC}"
	REMOTE_SUCCESS=true
else
	echo -e "${YELLOW}⚠ Warning: Remote tracking setup failed. You can set it up manually later:${NC}"
	echo -e "   ${CYAN}cd $BARE_REPO_PATH/$DIRECTORY_NAME && git push --set-upstream origin $BRANCH_NAME${NC}"
	REMOTE_SUCCESS=false
fi

echo ""
echo -e "${BOLD}${GREEN}Success!${NC}"
echo -e "${GREEN}✓ Branch created:${NC} ${MAGENTA}$BRANCH_NAME${NC}"
echo -e "${GREEN}✓ Worktree created:${NC} ${CYAN}$DIRECTORY_NAME${NC}"
if [ "$REMOTE_SUCCESS" = true ]; then
	echo -e "${GREEN}✓ Remote tracking set up${NC}"
else
	echo -e "${YELLOW}⚠ Remote tracking needs manual setup${NC}"
fi
echo ""
echo -e "${BOLD}To switch to the new worktree:${NC}"
echo -e "   ${CYAN}cd $BARE_REPO_PATH/$DIRECTORY_NAME${NC}"
