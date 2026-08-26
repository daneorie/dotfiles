#!/bin/bash
set -euo pipefail

# Smart Commit Cleanup Script
# Safely deletes backup branch after verification confirms success

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

# Function to show usage
usage() {
    echo "Usage: $0 <backup-branch-name> [--force]"
    echo ""
    echo "Safely deletes a backup branch after verification."
    echo ""
    echo "Arguments:"
    echo "  backup-branch-name    Name of the backup branch to delete"
    echo ""
    echo "Options:"
    echo "  --force              Skip verification and force delete the branch"
    echo "                       Use with caution - this bypasses safety checks!"
    echo ""
    echo "Example:"
    echo "  $0 backup-smart-commit-2024-03-15-14-30-25"
    echo "  $0 backup-smart-commit-2024-03-15-14-30-25 --force"
    exit 1
}

# Parse arguments
FORCE_DELETE=false
BACKUP_BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_DELETE=true
            shift
            ;;
        -*)
            echo "Unknown option $1"
            usage
            ;;
        *)
            if [ -z "$BACKUP_BRANCH" ]; then
                BACKUP_BRANCH="$1"
            else
                echo "Too many arguments"
                usage
            fi
            shift
            ;;
    esac
done

# Check required arguments
if [ -z "$BACKUP_BRANCH" ]; then
    echo "Error: backup-branch-name is required"
    usage
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Check if backup branch exists
if ! git branch --list "$BACKUP_BRANCH" | grep -q "$BACKUP_BRANCH"; then
    log_error "Backup branch '$BACKUP_BRANCH' does not exist"
    exit 1
fi

# Check if we're currently on the backup branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "$BACKUP_BRANCH" ]; then
    log_error "Cannot delete backup branch '$BACKUP_BRANCH' - currently checked out"
    log_info "Switch to another branch first: git checkout main"
    exit 1
fi

log_info "Preparing to delete backup branch: $BACKUP_BRANCH"

# Run verification unless force is specified
if [ "$FORCE_DELETE" = false ]; then
    log_info "Running verification before deletion..."

    # Get the directory of this script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    VERIFY_SCRIPT="$SCRIPT_DIR/verify-backup.sh"

    # Run verification script
    if [ -f "$VERIFY_SCRIPT" ]; then
        if ! "$VERIFY_SCRIPT" "$BACKUP_BRANCH"; then
            log_error "Verification failed - backup branch deletion aborted"
            echo ""
            log_warning "To force delete anyway (NOT RECOMMENDED):"
            echo "  $0 $BACKUP_BRANCH --force"
            echo ""
            log_info "To investigate the differences:"
            echo "  git diff HEAD $BACKUP_BRANCH"
            echo "  git diff --stat HEAD $BACKUP_BRANCH"
            exit 1
        fi
        log_success "Verification passed - safe to delete backup"
    else
        log_warning "Verification script not found at: $VERIFY_SCRIPT"
        log_warning "Proceeding without verification (this is not recommended)"

        # Ask for confirmation
        echo ""
        read -p "Continue without verification? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deletion cancelled"
            exit 0
        fi
    fi
else
    log_warning "Force delete requested - skipping verification"
    echo ""
    read -p "Are you sure you want to force delete '$BACKUP_BRANCH'? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deletion cancelled"
        exit 0
    fi
fi

# Get backup branch info before deletion
BACKUP_COMMIT=$(git rev-parse "$BACKUP_BRANCH")
BACKUP_MESSAGE=$(git log --format=%s -n 1 "$BACKUP_BRANCH")

# Delete the backup branch
log_info "Deleting backup branch..."
if git branch -D "$BACKUP_BRANCH"; then
    log_success "Backup branch deleted: $BACKUP_BRANCH"
    echo ""
    log_bold "🧹 Cleanup complete!"
    echo ""
    log_info "Deleted branch details:"
    echo "  Branch: $BACKUP_BRANCH"
    echo "  Commit: $BACKUP_COMMIT"
    echo "  Message: $BACKUP_MESSAGE"
    echo ""
    log_info "If you need to recover this backup:"
    echo "  git checkout -b recovered-backup $BACKUP_COMMIT"
    echo ""
    log_success "Smart commit process fully completed and cleaned up!"
else
    log_error "Failed to delete backup branch: $BACKUP_BRANCH"
    exit 1
fi
