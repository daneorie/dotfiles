---
name: git-worktree
description: >
  Create a git worktree for the current repo and begin feature work inside it.
  Use when the user wants to work on a feature in an isolated worktree, or asks
  to "create a worktree", "work in a worktree", or "isolate this branch".
metadata:
  author: local
  version: "0.0.1"
---

# git-worktree

This skill creates a git worktree for the current bare repo, checks out a new
feature branch inside it, and primes OpenCode's `external_directory` permission
so that the entire worktree is approved in one step — rather than requiring
per-file or per-subdirectory approvals.

## Repo layout

Repos are bare repos. Worktrees live as siblings of each other:

```
/path/to/bare/repo/
├── main/
├── feat/
└── other-work/
```

Worktrees can be created from any existing worktree, not just `main`. The new
worktree is always a sibling of the current directory, so the path is simply
`../<branch-name>` relative to wherever you are.

## Workflow

### Step 1 — Determine the worktree path

The worktree path is always relative to the current directory:

```
../<branch-name>
```

### Step 2 — Create the worktree

```bash
# Create the worktree on a new branch
git worktree add -b "<branch-name>" "../<branch-name>"
```

If the branch already exists, omit `-b`:

```bash
git worktree add "../<branch-name>" "<existing-branch>"
```

Verify the worktree was created:

```bash
git worktree list
```

### Step 3 — Trigger `external_directory` permission for the entire worktree

This is the critical step. OpenCode's `external_directory` permission is
triggered the first time any tool touches a path outside the original working
directory. By immediately reading the root of the new worktree, OpenCode prompts
with a suggested pattern that covers the whole subtree
(e.g., `~/repos/myapp/feat/dark-mode/**`).

When the prompt appears, choose **always** — this grants access to every file
and subdirectory in the worktree for the rest of the session without further
prompts.

```bash
ls "../<branch-name>"
```

Wait for OpenCode to prompt for `external_directory` permission and approve
with **always** before proceeding.

### Step 4 — Continue working in the worktree

All subsequent file reads, edits, globs, and greps within the worktree path
will be permitted automatically. Use `workdir` when running commands so they
execute in the correct context:

```bash
# Example: run the build from inside the worktree
cd "../<branch-name>" && just build

# Example: check git status
git -C "../<branch-name>" status
```

## Cleanup

When work is complete and the branch has been merged, remove the worktree:

```bash
git worktree remove "../<branch-name>"
git branch -d "<branch-name>"
```

Or, to force-remove without waiting for a clean state:

```bash
git worktree remove --force "../<branch-name>"
```

## Quick reference

| Task | Command |
|------|---------|
| List all worktrees | `git worktree list` |
| Create worktree + new branch | `git worktree add -b <branch> <path>` |
| Create worktree on existing branch | `git worktree add <path> <branch>` |
| Remove worktree | `git worktree remove <path>` |
| Force-remove worktree | `git worktree remove --force <path>` |
| Prune stale worktree metadata | `git worktree prune` |

## Important notes

- **Always trigger the `external_directory` permission immediately** (Step 3)
  before doing any real file work. Skipping this means every individual file
  access will prompt separately.
- Worktrees share the same `.git` object store as the bare repo — commits,
  branches, and refs are immediately visible across all worktrees.
- You cannot check out the same branch in more than one worktree at a time.
