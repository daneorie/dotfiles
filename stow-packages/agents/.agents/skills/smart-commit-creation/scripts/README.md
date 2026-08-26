# Smart Commit Backup Scripts

This directory contains three helper scripts for the smart commit creation workflow:

## Scripts Overview

### 1. `create-backup.sh`
**Purpose**: Creates a timestamped backup branch with all current changes before smart commit analysis.

**Usage**:
```bash
./create-backup.sh
```

**What it does**:
- Stages all changes (modified, new, deleted files)
- Creates a backup commit with message "backup: pre-smart-commit state"
- Creates a timestamped backup branch (e.g., `backup-smart-commit-2024-03-15-14-30-25`)
- Resets the current branch to clean working state
- Outputs backup branch name for use by other scripts

**Output Variables**:
- `BACKUP_BRANCH=<branch-name>` - For script chaining

### 2. `verify-backup.sh`
**Purpose**: Verifies that the final committed state matches the original backup state.

**Usage**:
```bash
./verify-backup.sh <backup-branch-name>
```

**What it does**:
- Compares the tree hash of current HEAD with the backup branch
- Ensures all changes from backup have been properly committed
- Provides detailed diff analysis if verification fails
- Safe-guards against accidental data loss

**Exit Codes**:
- `0` - Verification successful, safe to delete backup
- `1` - Verification failed, backup should be retained

**Output Variables**:
- `VERIFICATION_STATUS=SUCCESS` or `VERIFICATION_STATUS=FAILED`

### 3. `cleanup-backup.sh`
**Purpose**: Safely deletes backup branch after verification confirms success.

**Usage**:
```bash
./cleanup-backup.sh <backup-branch-name>
./cleanup-backup.sh <backup-branch-name> --force
```

**What it does**:
- Runs verification automatically (unless `--force` is used)
- Deletes the backup branch only after confirmation
- Provides recovery commands if branch is deleted accidentally
- Requires user confirmation for force deletion

**Options**:
- `--force` - Skip verification and force delete (use with caution)

## Workflow Integration

### Typical Usage in Smart Commit Process:

```bash
# 1. Create backup before any analysis
BACKUP_RESULT=$(./create-backup.sh)
BACKUP_BRANCH=$(echo "$BACKUP_RESULT" | grep "BACKUP_BRANCH=" | cut -d'=' -f2)

# 2. Perform smart commit analysis and creation
# ... (smart commit logic here)

# 3. Verify final state matches backup
./verify-backup.sh "$BACKUP_BRANCH"

# 4. Clean up backup if verification passes
./cleanup-backup.sh "$BACKUP_BRANCH"
```

### Error Recovery:

If anything goes wrong during the smart commit process:

```bash
# Full recovery to backup state
git checkout $BACKUP_BRANCH
git checkout -b recovery-branch

# Or cherry-pick the backup to current branch
git cherry-pick $BACKUP_BRANCH
git reset --soft HEAD~1  # Unstage backup commit changes
```

## Safety Features

### Multiple Safety Checks:
1. **Git repository validation** - Ensures scripts run in valid git repos
2. **Branch existence checks** - Verifies backup branches exist before operations
3. **Working directory protection** - Prevents deletion of currently checked out branches
4. **Tree hash comparison** - Cryptographically verifies content integrity
5. **User confirmation** - Requires explicit confirmation for destructive operations

### Colored Output:
- 🟢 **Green**: Success messages and confirmations
- 🟡 **Yellow**: Warnings and important information
- 🔴 **Red**: Errors and failures
- 🔵 **Cyan**: Informational messages
- **Bold**: Important summaries and headers

### Error Handling:
- All scripts use `set -euo pipefail` for strict error handling
- Detailed error messages with suggested remediation
- Graceful cleanup on failures
- Recovery instructions provided when operations fail

## Examples

### Successful Workflow:
```bash
$ ./create-backup.sh
Creating safety backup...
✓ Staged 15 files
✓ Created backup commit
✓ Created backup branch: backup-smart-commit-2024-03-15-14-30-25
✓ Reset to clean working state
Backup successfully created!
BACKUP_BRANCH=backup-smart-commit-2024-03-15-14-30-25

$ # ... perform smart commits ...

$ ./verify-backup.sh backup-smart-commit-2024-03-15-14-30-25
Verifying smart commit results against backup...
✓ Perfect match! Current state exactly matches backup state
✅ Verification successful - all changes have been committed
VERIFICATION_STATUS=SUCCESS

$ ./cleanup-backup.sh backup-smart-commit-2024-03-15-14-30-25
Running verification before deletion...
✓ Verification passed - safe to delete backup
✓ Backup branch deleted: backup-smart-commit-2024-03-15-14-30-25
🧹 Cleanup complete!
```

### Verification Failure:
```bash
$ ./verify-backup.sh backup-smart-commit-2024-03-15-14-30-25
Verifying smart commit results against backup...
✗ Tree mismatch detected!
Files that differ between current HEAD and backup:
  src/auth/middleware.go
  src/auth/types.go
Total files with differences: 2
❌ Verification failed - changes missing or different
DO NOT delete backup branch yet!
VERIFICATION_STATUS=FAILED
```

## Integration with Smart Commit Skill

The smart commit skill references these scripts to provide a robust backup and recovery system:

1. **Phase 0**: Calls `create-backup.sh` to create safety net
2. **Phase 1-4**: Performs smart commit analysis and execution
3. **Phase 5**: Calls `verify-backup.sh` to confirm integrity
4. **Phase 6**: Calls `cleanup-backup.sh` to clean up successful backups

This ensures that no work is ever lost during the smart commit process, even if unexpected errors occur.
