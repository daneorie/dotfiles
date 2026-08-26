---
name: smart-commit-creation
description: Analyze code changes and create logical, atomic commits that maintain code quality and readability with intelligent grouping, proper sequencing, and meaningful conventional commit messages.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: git-management
---

# Smart Commit Creation Skill

## Overview
This skill analyzes code changes and creates logical, atomic commits that maintain code quality and readability. It groups related changes intelligently, ensures proper sequencing, and executes commits with meaningful messages following conventional commit standards.

**SAFETY FIRST**: Before any analysis begins, this skill automatically creates a complete backup of all staged changes on a separate branch. This ensures that no matter what happens during the smart commit process, all work is preserved and recoverable.

**UNSTAGED CHANGES ARE PRESERVED**: This skill never touches the working tree. Only the git index (staged area) is read and manipulated. Any unstaged modifications in the working tree are left completely untouched throughout the entire process — including during backup creation, commit execution, and verification.

**INVOCATION MODES**: The skill operates in one of two modes depending on how it is invoked:
- **With instructions** (e.g., "commit the authentication changes"): The agent stages the appropriate files and hunks before proceeding. Unstaged changes to other files are ignored.
- **Without instructions** (bare invocation): The agent commits only what is already staged. If nothing is staged, the skill warns the user and exits without making any changes.

**EXECUTION BEHAVIOR**: When this skill is invoked, it immediately begins by creating a backup, then analyzing the staged changes and executing commits. No user confirmation is required - invoking the skill indicates intent to proceed with smart commit creation.

**SCRIPT LOCATIONS**: This skill uses three backup scripts located in the skill's own `scripts/` directory (not the project's scripts directory). The agent must use the full path to the skill's scripts directory when executing these scripts.

## Core Capabilities

### 1. Change Analysis and Grouping
- **Dependency Analysis**: Maps relationships between files, functions, and types
- **Logical Grouping**: Groups related changes across multiple files
- **Atomic Commits**: Ensures each commit represents a single logical unit of work
- **File Splitting**: Splits large files across multiple commits when appropriate

### 2. Commit Sequencing
- **Dependency Ordering**: Orders commits to maintain valid code states
- **Import/Export Flow**: Commits dependencies before their usage
- **Type Safety**: Commits type definitions before their consumers
- **Temporary Breakage Handling**: Allows controlled temporary breakage with clear messaging

### 3. Commit Message Generation
- **Conventional Commits**: Follows conventional commit format (feat:, fix:, refactor:, etc.)
- **Context-Aware Messages**: Generates descriptive messages based on actual changes
- **Scope Detection**: Automatically identifies affected components/modules
- **Breaking Change Flags**: Clearly marks breaking changes with appropriate formatting

### 4. Pre-commit Hook Integration
- **Hook Execution**: Runs existing pre-commit hooks for each commit
- **Hook Failure Handling**: Manages hook failures and provides recovery options
- **Auto-fixes**: Applies automatic fixes when hooks provide them

## Automatic Execution Process

When this skill is invoked, it immediately executes the following workflow without user prompting:

### Phase 0: Backup Creation (Safety Net)

**Determine invocation mode first:**
- If the user provided instructions about what to commit: stage the appropriate files/hunks using `git add` or `git add -p` before running the backup script
- If invoked without instructions: check that `git diff --cached --quiet` returns non-zero (i.e., something is staged). If nothing is staged, warn the user and exit without creating a backup or any commits

**Then execute the backup:**
1. **Execute Backup Script**: Run the skill's `scripts/create-backup.sh` from the skill directory
2. **Capture Backup Branch**: Store the backup branch name for later verification
3. **Verify Backup Success**: Ensure backup was created successfully before proceeding

The backup script handles:
- Committing only what is in the index (staged area) — never runs `git add -A`
- Creating a timestamped backup branch from that commit
- Performing a **mixed reset** (`git reset HEAD`) to clear the index back to HEAD without touching the working tree — unstaged changes remain intact on disk
- Providing backup branch name for subsequent operations

The backup branch is the **single source of truth** for all commit content. After the backup is created, the agent reads all file content from the backup branch tree — the working tree is never read again during Phases 1-4.

### Phase 1: Discovery and Analysis
1. **Read Backup Branch Tree**: List all files in the backup branch using `git ls-tree -r <backup-branch>` — do not scan the working directory
2. **Parse Changes**: Analyze line-by-line changes by diffing the backup branch against HEAD (`git diff HEAD <backup-branch>`)
3. **Build Dependency Graph**: Map relationships between changes
4. **Classify Change Types**: Categorize changes (feature, fix, refactor, docs, etc.)

### Phase 2: Intelligent Grouping
1. **Related Change Detection**: Group changes that belong together logically
2. **Cross-File Dependencies**: Handle changes spanning multiple files
3. **Impact Analysis**: Assess the scope and impact of each change group
4. **Conflict Resolution**: Handle competing grouping strategies

### Phase 3: Commit Sequencing
1. **Dependency Ordering**: Order commits to maintain code validity
2. **Breakage Analysis**: Identify unavoidable temporary breakages
3. **Staging Strategy**: Determine optimal file staging for each commit
4. **Message Generation**: Create descriptive, conventional commit messages

### Phase 4: Execution and Validation
1. **Index-Only Staging**: For each commit group, populate the index using `git update-index --cacheinfo` with blob hashes sourced from the backup branch tree — **never use `git checkout <branch> -- <file>`** as this would overwrite working tree files
2. **Progressive Commits**: Execute commits in calculated sequence
3. **Hook Integration**: Run pre-commit hooks for each commit
4. **Validation**: Verify each commit maintains desired code state
5. **Recovery**: Handle failures and provide rollback options

**Critical invariant**: The working tree is never written to during Phase 4. Every file that goes into a commit is sourced from the backup branch via its blob hash:
```bash
# Get blob hash and mode for a file from the backup branch
TREE_ENTRY=$(git ls-tree <backup-branch> -- path/to/file)
FILE_MODE=$(echo "$TREE_ENTRY" | awk '{print $1}')
FILE_HASH=$(echo "$TREE_ENTRY" | awk '{print $3}')

# Stage it into the index without touching the working tree
git update-index --cacheinfo "$FILE_MODE,$FILE_HASH,path/to/file"
```

### Phase 5: Verification and Cleanup
1. **Verify Final State**: Run the skill's `scripts/verify-backup.sh` from the skill directory to ensure all changes were committed
2. **Tree Comparison**: Compare current `HEAD^{tree}` with backup branch tree — unstaged working tree changes are invisible to this comparison by design, so their presence does not affect the result and is not a failure condition
3. **Handle Verification Results**:
   - **Success**: Proceed to cleanup
   - **Failure**: Retain backup and provide recovery instructions
4. **Backup Cleanup**: Run the skill's `scripts/cleanup-backup.sh` from the skill directory to remove backup branch if verification passes
5. **Summary Report**: Show created commits, verification status, and any retained backups

**Note**: The skill will only pause execution if critical errors occur that require user intervention (such as pre-commit hook failures that cannot be auto-resolved).

## Implementation Guidelines

### Backup Strategy

The skill uses dedicated scripts in the skill's `scripts/` directory for reliable backup operations:

#### Backup Creation (`scripts/create-backup.sh` in skill directory)
- Commits only what is in the index (staged area) — does not run `git add -A`
- Creates a timestamped backup branch from that commit
- Performs a mixed reset to clear the index back to HEAD without touching the working tree
- Provides backup branch name for subsequent verification

#### Verification (`scripts/verify-backup.sh` in skill directory)
- Compares `HEAD^{tree}` with backup branch tree using cryptographic tree hashes
- Unstaged working tree changes do not affect tree hashes and are intentionally excluded from verification
- Ensures no staged changes were lost during the smart commit process
- Provides detailed analysis if discrepancies are found

#### Cleanup (`scripts/cleanup-backup.sh` in skill directory)
- Safely deletes backup branch only after successful verification
- Includes safety checks and user confirmation
- Provides recovery commands if needed

Example workflow:
```bash
# Automatic execution by skill:
SKILL_DIR="$(dirname "${BASH_SOURCE[0]}")"  # Get skill directory
BACKUP_RESULT=$("$SKILL_DIR/scripts/create-backup.sh")
BACKUP_BRANCH=$(echo "$BACKUP_RESULT" | grep "BACKUP_BRANCH=" | cut -d'=' -f2)
# ... perform smart commits ...
"$SKILL_DIR/scripts/verify-backup.sh" "$BACKUP_BRANCH"
"$SKILL_DIR/scripts/cleanup-backup.sh" "$BACKUP_BRANCH"
```

### Change Classification
```
feat: New features or functionality
fix: Bug fixes
refactor: Code restructuring without functional changes
docs: Documentation updates
test: Test additions or modifications
style: Code style/formatting changes
perf: Performance improvements
build: Build system or dependency updates
ci: CI/CD configuration changes
chore: Maintenance tasks
```

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer(s)]
```

### Special Handling Scenarios

#### Temporary Breakage
- **When**: Changes require intermediate states that break functionality
- **Strategy**: Include clear warning in commit message
- **Format**: `feat(api): add new endpoint (TEMPORARY: breaks existing tests)`

#### Large Refactoring
- **Strategy**: Break into logical, reviewable chunks
- **Sequencing**: Maintain functionality at each commit when possible
- **Documentation**: Include refactoring context in commit messages

#### Cross-Module Changes
- **Strategy**: Group by logical feature rather than file location
- **Dependencies**: Ensure supporting changes come before dependent changes
- **Scope**: Use broader scope names for cross-cutting changes

### File Splitting Strategies

#### When to Split Files
1. **Logical Separation**: Different features/fixes in same file
2. **Review Optimization**: Large changes that benefit from separation
3. **Rollback Safety**: Changes that might need independent rollback
4. **Testing Isolation**: Changes that can be tested independently

#### Splitting Methods
1. **Line Range Commits**: Commit specific line ranges within files
2. **Function-Level Splits**: Commit individual function changes
3. **Feature Boundary Splits**: Split along feature boundaries
4. **Preparation Commits**: Separate preparatory changes from main changes

### Pre-commit Hook Handling

#### Hook Success
- Continue with commit sequence
- Apply any auto-fixes to working directory
- Update commit with fixed content if needed

#### Hook Failure
- Abort current commit
- Present hook output to user
- Offer options:
  - Fix issues manually and retry
  - Skip problematic files for now
  - Adjust commit grouping
  - Abort entire sequence

#### Auto-fix Integration
- Apply fixes automatically when available
- Re-stage fixed files
- Continue with commit process
- Note fixes in commit message if significant

## Usage Patterns

### Automatic Execution
When this skill is invoked, it immediately starts with backup creation, then analysis and commits:
```bash
# Skill invocation automatically begins with backup creation, then analysis and commit creation
/smart-commit-creation
```

The skill will:
1. **Always** run the skill's `scripts/create-backup.sh` to create a timestamped backup branch
2. Analyze and intelligently group changes
3. Create atomic commits in logical order
4. **Always** run the skill's `scripts/verify-backup.sh` to ensure integrity
5. **Always** run the skill's `scripts/cleanup-backup.sh` to clean up successful backups (or retain failed ones)

### Manual Override Options (if needed)
These patterns can be requested during skill invocation if different behavior is needed:
```bash
# Analyze only (no commits) - must be explicitly requested
--analyze-only

# Focus on specific files/directories - must be explicitly requested
--include "src/**" --exclude "dist/**"

# Custom commit message prefix - must be explicitly requested
--prefix "PROJ-123"
```

### Output Examples

#### Backup Creation Phase
```
\033[36mCreating safety backup...\033[0m
\033[32m✓\033[0m Staged 15 files
\033[32m✓\033[0m Created backup commit: backup: pre-smart-commit state
\033[32m✓\033[0m Created backup branch: backup-smart-commit-2024-03-15-14-30-25
\033[32m✓\033[0m Reset to clean working state
\033[33mBackup available at:\033[0m backup-smart-commit-2024-03-15-14-30-25

\033[1mAll changes safely backed up. Proceeding with smart commit analysis...\033[0m
```

#### Verification and Cleanup Phase
```
\033[36mVerifying smart commit results against backup...\033[0m
\033[32m✓\033[0m Perfect match! Current state exactly matches backup state
\033[1m✅ Verification successful - all changes have been committed\033[0m

\033[36mCleaning up backup branch...\033[0m
\033[32m✓\033[0m Backup branch deleted: backup-smart-commit-2024-03-15-14-30-25
\033[32m\033[1m🧹 Cleanup complete!\033[0m

\033[32m\033[1mSmart commit process fully completed!\033[0m
\033[36mCreated 5 commits with full verification and cleanup\033[0m
```

#### Analysis Phase
```
\033[36mAnalyzing changes...\033[0m
Found 15 modified files across 4 logical groups:

Group 1: Authentication System Enhancement
  - src/auth/middleware.go (3 functions modified)
  - src/auth/types.go (new AuthConfig type)
  - docs/auth.md (updated documentation)

Group 2: Database Migration
  - migrations/003_add_user_roles.sql (new migration)
  - internal/models/user.go (Role field added)

Group 3: Test Updates
  - auth/middleware_test.go (new test cases)
  - models/user_test.go (role validation tests)

Group 4: Configuration Changes
  - config/app.yaml (auth timeout setting)
  - README.md (setup instructions updated)
```

#### Commit Execution and Summary
```
\033[1mCreating commits...\033[0m

\033[32m✓\033[0m feat(auth): add new AuthConfig type
   Files: src/auth/types.go
   Pre-commit hooks: \033[32mPassed\033[0m

\033[32m✓\033[0m feat(auth): implement role-based middleware
   Files: src/auth/middleware.go
   Pre-commit hooks: \033[32mPassed (auto-formatted)\033[0m

\033[32m✓\033[0m feat(db): add user roles migration
   Files: migrations/003_add_user_roles.sql, internal/models/user.go
   Pre-commit hooks: \033[32mPassed\033[0m

\033[32m✓\033[0m test(auth): add comprehensive role validation tests
   Files: auth/middleware_test.go, models/user_test.go
   Pre-commit hooks: \033[32mPassed\033[0m

\033[32m✓\033[0m docs(auth): update documentation and configuration
   Files: docs/auth.md, config/app.yaml, README.md
   Pre-commit hooks: \033[32mPassed\033[0m

\033[32m\033[1mSuccessfully created 5 commits\033[0m
```

## Error Handling and Recovery

### Backup-Based Recovery System

With the automated script-based backup strategy, recovery from any failure is straightforward:

#### Script-Based Recovery
The verification script from the skill directory automatically detects issues:
```bash
# If verification fails, the script provides detailed guidance:
.claude/skills/smart-commit-creation/scripts/verify-backup.sh backup-smart-commit-2024-03-15-14-30-25
# Output shows exactly what differs and provides recovery options
```

#### Manual Recovery Options
```bash
# Complete recovery to backup state
git checkout backup-smart-commit-2024-03-15-14-30-25
git checkout -b recovery-branch

# Partial recovery (cherry-pick specific changes)
git cherry-pick backup-smart-commit-2024-03-15-14-30-25
git reset --soft HEAD~1

# Selective file recovery
git show backup-smart-commit-2024-03-15-14-30-25:path/to/file > path/to/file
```

#### Cleanup Automation
The cleanup script from the skill directory provides safe deletion with multiple safeguards:
- Automatic verification before deletion
- User confirmation for destructive operations
- Recovery commands provided even after deletion
- Force option available for emergency cleanup

### Hook Failures
- Present clear error messages
- Offer specific resolution suggestions
- Maintain partial progress when possible
- Provide rollback options

### Dependency Conflicts
- Detect circular dependencies
- Suggest alternative grouping strategies
- Allow manual override with warnings
- Document reasoning for complex decisions

### Large Change Management
- Break oversized commits automatically
- Warn about review complexity
- Suggest staging strategies
- Maintain logical coherence

## Integration Features

### Git Integration
- Respects `.gitignore` patterns
- Handles git hooks properly
- Maintains git history cleanliness
- Supports branch-specific strategies

### Tool Integration
- Works with existing pre-commit configurations
- Integrates with linters and formatters
- Supports custom validation scripts
- Maintains compatibility with CI/CD

### Project Awareness
- Learns from existing commit patterns
- Adapts to project-specific conventions
- Respects monorepo structures
- Handles framework-specific patterns

## Best Practices Enforcement

### Commit Quality
- Ensures atomic, focused commits
- Maintains consistent message format
- Includes appropriate context
- Facilitates easy review and rollback

### Code Quality
- Leverages existing pre-commit hooks
- Maintains test coverage
- Preserves code style consistency
- Enforces project standards

### Development Workflow
- Supports collaborative development
- Facilitates code review process
- Enables effective git operations
- Maintains project history clarity

## Script Integration

This skill includes three dedicated backup scripts in the skill's `scripts/` directory:

### Script Components

#### 1. `scripts/create-backup.sh` (in skill directory)
- **Purpose**: Creates timestamped backup branch with all changes
- **Input**: None (operates on current working directory)
- **Output**: `BACKUP_BRANCH=<branch-name>` for script chaining
- **Safety**: Validates git repository, handles edge cases

#### 2. `scripts/verify-backup.sh` (in skill directory)
- **Purpose**: Verifies final state matches backup using cryptographic tree comparison
- **Input**: `<backup-branch-name>`
- **Output**: `VERIFICATION_STATUS=SUCCESS|FAILED`
- **Safety**: Detailed diff analysis, clear error reporting

#### 3. `scripts/cleanup-backup.sh` (in skill directory)
- **Purpose**: Safely deletes backup after verification
- **Input**: `<backup-branch-name>` [--force]
- **Safety**: Automatic verification, user confirmation, recovery commands

### Script Workflow Integration

The skill automatically orchestrates these scripts using their full path from the skill directory:
```bash
# Phase 0: Create backup
SKILL_DIR="/Users/dorie/repos/plan-your-day/update-regret-scoring-for-times/.claude/skills/smart-commit-creation"
BACKUP_RESULT=$("$SKILL_DIR/scripts/create-backup.sh")
BACKUP_BRANCH=$(echo "$BACKUP_RESULT" | grep "BACKUP_BRANCH=" | cut -d'=' -f2)

# Phases 1-4: Smart commit analysis and execution
# ... (intelligent grouping and commit creation)

# Phase 5: Verification and cleanup
"$SKILL_DIR/scripts/verify-backup.sh" "$BACKUP_BRANCH"
if [ $? -eq 0 ]; then
    "$SKILL_DIR/scripts/cleanup-backup.sh" "$BACKUP_BRANCH"
else
    echo "Backup retained due to verification failure: $BACKUP_BRANCH"
fi
```

For detailed script documentation, see `scripts/README.md`.

## Customization Options

### Configuration File Support
- Project-specific rules via `.commit-config.yaml`
- Custom grouping strategies
- Message format templates
- Hook configuration overrides

### Rule Definitions
- File relationship rules
- Change classification patterns
- Commit size thresholds
- Message format requirements

### Integration Settings
- Hook execution preferences
- Auto-fix behaviors
- Validation requirements
- Output verbosity levels
