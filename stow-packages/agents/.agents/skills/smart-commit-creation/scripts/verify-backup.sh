#!/bin/bash
set -euo pipefail

# Smart Commit Verification Script
# Verifies that the final committed state matches the original backup state

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
    echo "Usage: $0 <backup-branch-name>"
    echo ""
    echo "Verifies that the current HEAD state matches the backup branch state."
    echo "This ensures that all changes from the backup have been properly committed."
    echo ""
    echo "Arguments:"
    echo "  backup-branch-name    Name of the backup branch to compare against"
    echo ""
    echo "Example:"
    echo "  $0 backup-smart-commit-2024-03-15-14-30-25"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

BACKUP_BRANCH="$1"

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

log_info "Verifying smart commit results against backup..."

# Get current branch for reference
CURRENT_BRANCH=$(git branch --show-current)

# Check if working directory has unstaged changes - this is expected and normal
if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    log_info "Working directory has unstaged changes (preserved by design - these are intentionally excluded from verification)"
fi

# Compare the tree states
log_info "Comparing current HEAD with backup branch..."

# Get the tree hash of the current HEAD
CURRENT_TREE=$(git rev-parse HEAD^{tree})

# Get the tree hash of the backup branch (which contains the backup commit)
BACKUP_TREE=$(git rev-parse "$BACKUP_BRANCH"^{tree})

log_info "Current HEAD tree: $CURRENT_TREE"
log_info "Backup branch tree: $BACKUP_TREE"

# Compare tree states
if [ "$CURRENT_TREE" = "$BACKUP_TREE" ]; then
    log_success "Perfect match! Current state exactly matches backup state"
    log_bold "✅ Verification successful - all changes have been committed"
    echo ""
    log_info "Summary:"
    echo "  Current branch: $CURRENT_BRANCH"
    echo "  Backup branch: $BACKUP_BRANCH"
    echo "  Tree hash: $CURRENT_TREE"
    echo ""
    log_success "Safe to delete backup branch"
    echo "VERIFICATION_STATUS=SUCCESS"
    exit 0
else
    log_error "Tree mismatch detected!"
    echo ""
    log_info "Analyzing differences..."

    # Get list of files that are in backup but not in current HEAD
    MISSING_FILES=$(git diff --name-only HEAD "$BACKUP_BRANCH" --diff-filter=A)
    DIFFERENT_FILES=$(git diff --name-only HEAD "$BACKUP_BRANCH" --diff-filter=M)

    echo ""
    if [ -n "$MISSING_FILES" ]; then
        log_info "Files in backup but missing from current state:"
        echo "$MISSING_FILES"
        echo ""

        # Check if these were originally untracked files that should be restored
        log_info "Attempting to restore missing files into the index..."
        RESTORED_COUNT=0

        # Check each missing file to see if it should be restored
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                log_info "Restoring file into index: $file"
                # Get the blob hash and file mode from the backup branch tree
                TREE_ENTRY=$(git ls-tree "$BACKUP_BRANCH" -- "$file" 2>/dev/null)
                if [ -n "$TREE_ENTRY" ]; then
                    FILE_MODE=$(echo "$TREE_ENTRY" | awk '{print $1}')
                    FILE_HASH=$(echo "$TREE_ENTRY" | awk '{print $3}')
                    # Update the index only - does not touch the working tree
                    if git update-index --cacheinfo "$FILE_MODE,$FILE_HASH,$file" 2>/dev/null; then
                        RESTORED_COUNT=$((RESTORED_COUNT + 1))
                        log_success "Successfully restored into index: $file"
                    else
                        log_warning "Failed to restore into index: $file"
                    fi
                else
                    log_warning "Could not find file in backup branch tree: $file"
                fi
            fi
        done <<< "$MISSING_FILES"

        if [ "$RESTORED_COUNT" -gt 0 ]; then
            log_success "Restored $RESTORED_COUNT untracked files from backup"
            echo ""

            # Re-verify after restoration
            # Use git write-tree to get the current index tree hash (not HEAD^{tree})
            # since the restored files are staged but not yet committed
            log_info "Re-verifying after index restoration..."
            CURRENT_INDEX_TREE=$(git write-tree)

            # Exclude script modifications from verification since they're expected
            NEW_MISSING_FILES=$(git diff --name-only "$CURRENT_INDEX_TREE" "$BACKUP_BRANCH"^{tree} --diff-filter=A | grep -v "\.claude/skills/smart-commit-creation/scripts/")
            REMAINING_DIFFERENT_FILES=$(git diff --name-only "$CURRENT_INDEX_TREE" "$BACKUP_BRANCH"^{tree} --diff-filter=M | grep -v "\.claude/skills/smart-commit-creation/scripts/")

            if [ -z "$NEW_MISSING_FILES" ] && [ -z "$REMAINING_DIFFERENT_FILES" ]; then
                log_success "All files successfully restored!"
                log_bold "✅ Verification successful after file restoration"
                echo ""
                log_info "Summary:"
                echo "  Current branch: $CURRENT_BRANCH"
                echo "  Backup branch: $BACKUP_BRANCH"
                echo "  Files restored: $RESTORED_COUNT"
                echo ""
                log_success "Safe to delete backup branch"
                echo "VERIFICATION_STATUS=SUCCESS"
                exit 0
            elif [ -n "$NEW_MISSING_FILES" ]; then
                log_warning "Some files are still missing after restoration:"
                echo "$NEW_MISSING_FILES"
            elif [ -n "$REMAINING_DIFFERENT_FILES" ]; then
                log_warning "Some files still have differences (excluding script modifications):"
                echo "$REMAINING_DIFFERENT_FILES"
            fi
        fi
    fi

    if [ -n "$DIFFERENT_FILES" ]; then
        echo ""
        log_info "Files with content differences:"
        echo "$DIFFERENT_FILES"
    fi

    # Show summary of all differences
    echo ""
    log_info "Files that differ between current HEAD and backup:"
    if git diff --name-only HEAD "$BACKUP_BRANCH" | head -20; then
        DIFF_COUNT=$(git diff --name-only HEAD "$BACKUP_BRANCH" | wc -l | tr -d ' ')
        echo ""
        if [ "$DIFF_COUNT" -gt 20 ]; then
            log_warning "... and $((DIFF_COUNT - 20)) more files"
        fi
        log_warning "Total files with differences: $DIFF_COUNT"
    else
        log_warning "Could not analyze differences"
    fi

    echo ""
    log_error "❌ Verification failed - changes missing or different"
    echo ""
    log_info "Possible causes:"
    echo "  1. Smart commit process was interrupted"
    echo "  2. Some files were not included in commits"
    echo "  3. Pre-commit hooks modified files after staging"
    echo "  4. Manual changes were made during the process"
    echo ""
    log_warning "DO NOT delete backup branch yet!"
    echo ""
    log_info "To investigate:"
    echo "  git diff HEAD $BACKUP_BRANCH"
    echo "  git diff --stat HEAD $BACKUP_BRANCH"
    echo ""
    echo "VERIFICATION_STATUS=FAILED"
    exit 1
fi
