#!/bin/bash
set -euo pipefail

# Smart Commit Backup Creation Script
# Creates a timestamped backup branch with all current changes before smart commit analysis

# Color definitions
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
BOLD='\033[1m'
RESET='\033[0m'

# Function to log with colors
log_info() {
    echo -e "${CYAN}$1${RESET}"
}

log_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

log_error() {
    echo -e "${RED}✗${RESET} $1"
}

log_bold() {
    echo -e "${BOLD}$1${RESET}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Check if there are any staged changes to backup
if git diff --cached --quiet; then
    log_warning "No staged changes found to backup"
    exit 0
fi

log_info "Creating safety backup..."

# Generate timestamp for backup branch
BACKUP_TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
BACKUP_BRANCH="backup-smart-commit-$BACKUP_TIMESTAMP"

# Get current branch name for reference
CURRENT_BRANCH=$(git branch --show-current)

# Store the current HEAD commit for later reset
ORIGINAL_HEAD=$(git rev-parse HEAD)

# Count staged files
STAGED_COUNT=$(git diff --cached --numstat | wc -l | tr -d ' ')
log_success "Staged $STAGED_COUNT files"

# Create backup commit
log_info "Creating backup commit..."
if ! git commit -m "chore: backup pre-smart-commit state"; then
    log_error "Failed to create backup commit"
    exit 1
fi

log_success "Created backup commit"

# Create backup branch from the backup commit
log_info "Creating backup branch..."
if ! git branch "$BACKUP_BRANCH"; then
    log_error "Failed to create backup branch: $BACKUP_BRANCH"
    # Cleanup: reset to original state
    git reset --hard "$ORIGINAL_HEAD"
    exit 1
fi

log_success "Created backup branch: $BACKUP_BRANCH"

# Reset index to HEAD without touching the working tree
# This clears staged changes from the index while leaving all working tree files intact
log_info "Resetting index to clean state (preserving working tree)..."
if ! git reset "$ORIGINAL_HEAD"; then
    log_error "Failed to reset index to original state"
    log_warning "Backup branch created but index reset failed. Manual cleanup may be required."
    echo "Backup branch: $BACKUP_BRANCH"
    exit 1
fi

log_success "Index reset to clean state (working tree preserved)"

# Verify backup branch exists
if ! git branch --list "$BACKUP_BRANCH" | grep -q "$BACKUP_BRANCH"; then
    log_error "Backup branch verification failed"
    exit 1
fi

# Output backup information
log_bold "Backup successfully created!"
echo ""
log_info "Backup Details:"
echo "  Branch: $BACKUP_BRANCH"
echo "  Original branch: $CURRENT_BRANCH"
echo "  Files backed up: $STAGED_COUNT"
echo ""
log_warning "Backup branch location: $BACKUP_BRANCH"
echo ""
log_bold "All staged changes safely backed up. Ready for smart commit analysis..."

# Output the backup branch name for the calling script to use
echo "BACKUP_BRANCH=$BACKUP_BRANCH"
