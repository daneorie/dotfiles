---
name: review-copilot-comments
description: >-
  Fetches and systematically addresses GitHub PR review comments from AI/Copilot,
  humans, or both. Use when the user says "address copilot comments", "fix AI review
  comments", "fix bot comments", "address all PR comments", "work through PR feedback",
  or "fix review comments". Supports cherry-picking specific comments. Includes SSO
  recovery for org SAML enforcement.
---

# Review & Address Copilot/PR Comments

This skill fetches review comments on the current PR, builds a plan to address them,
and walks through fixes one by one. It handles AI/bot comments, human comments, or both.
It also supports cherry-picking specific comments to address instead of all-or-nothing.

## Trigger Phrases & Scope

**AI/bot comments only:**
- "copilot comments"
- "AI comments"
- "bot comments"
- "fix copilot feedback"

**All comments (human + bot):**
- "all PR comments"
- "all review comments"
- "work through PR feedback"
- "fix review comments"

**Cherry-picked specific comments:**
- "address comment #5"
- "fix the accessibility comment"
- "only the unused import issues"

## Prerequisites & SSO Recovery

The skill requires `gh` CLI to be authenticated to GitHub.

### Test Authentication

Before proceeding, the skill will run:
```bash
gh pr view --json number
```

If you see an error like:
```
GraphQL: Resource protected by organization SAML enforcement. You must grant your OAuth token access to this organization.
```

**Recovery steps:**

1. Open the authorization URL from the error message in your web browser and complete the SSO flow
2. If that doesn't resolve it, run:
   ```bash
   gh auth refresh -h github.com
   ```
   or
   ```bash
   gh auth login
   ```
   to issue a new token, then re-authorize it for the org via SSO in your browser
3. Retry the skill after re-authenticating

## Fetch Comments Workflow

**Only unresolved review threads are fetched.** Threads marked resolved are skipped. Outdated threads (`isOutdated: true`) are still included — check whether a follow-up comment already addressed them before acting.

### Step 1: Get PR Details

```bash
gh pr view --json number,headRepositoryOwner,headRepository \
  --jq '{number: .number, owner: .headRepositoryOwner.login, repo: .headRepository.name}'
```

Or from the current directory (which has a `.git` remote):
```bash
REPO=$(git config --get remote.origin.repository | sed 's|.*:||' | sed 's|\.git||')
OWNER=$(git config --get remote.origin.url | grep -oE '[^:/]*github[^/]*' | sed 's|.*github.com:||' | cut -d/ -f1)
NUMBER=$(gh pr view --json number --jq .number)
```

This returns: `{"number": 1627, "owner": "The-Coca-Cola-Company", "repo": "global-fuelight-refuel-experience"}`

### Step 2a: Fetch Unresolved Bot/AI Threads (GraphQL)

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          comments(first: 10) {
            nodes {
              databaseId
              path
              line
              body
              diffHunk
              author { login }
            }
          }
        }
      }
    }
  }
}' -f owner="{owner}" -f repo="{repo}" -F number={number} \
--jq '[.data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | .comments.nodes[]
  | select(.author.login | test("copilot|github-advanced-security"; "i"))
  | {id: .databaseId, path, line, body, diff_hunk: .diffHunk, author: .author.login, isOutdated}]'
```

### Step 2b: Fetch All Unresolved Threads (GraphQL)

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          comments(first: 10) {
            nodes {
              databaseId
              path
              line
              body
              diffHunk
              author { login }
            }
          }
        }
      }
    }
  }
}' -f owner="{owner}" -f repo="{repo}" -F number={number} \
--jq '[.data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | .comments.nodes[]
  | {id: .databaseId, path, line, body, diff_hunk: .diffHunk, author: .author.login, isOutdated}]'
```

### Step 3a: Fetch Bot/AI Top-Level Comments

```bash
gh pr view {number} --json comments \
  --jq '[.comments[] | select(.authorAssociation == "BOT" or (.author.login | test("copilot|github-advanced-security"; "i"))) | {body, author: .author.login, id: .databaseId}]'
```

### Step 3b: Fetch All Top-Level Comments

```bash
gh pr view {number} --json comments \
  --jq '[.comments[] | {body, author: .author.login, id: .databaseId}]'
```

## Planning Phase

After fetching, the skill will:

1. **Summarize all comments** grouped by file, with author, line number, and body
2. **Identify suggested changes** — note which comments include inline diff suggestions that can guide the fix
3. **Handle cherry-picks** — if the user specified particular comments, present the full list and confirm the subset to address before building the todo list
4. **Create a TodoWrite list** with one item per comment, in priority/dependency order
5. **Present the full plan** to the user and wait for confirmation before starting execution

## Execution Phase

For each todo, the skill will:

1. **Read the file** at the indicated line using the `diff_hunk` as surrounding context
2. **Understand the suggestion** — if a comment includes a suggested change, use it as guidance
3. **Apply the fix** in the source file
4. **Commit contextually** — group related fixes (e.g. all unused imports in one commit, or all accessibility fixes in another) rather than one commit per comment. The commit message should be clear and conventional.
5. **Mark the todo complete** and move to the next comment

**Note:** Comment replies are deferred until after you manually verify the changes. They will be posted in the next phase, after you confirm the fixes are ready.

### Commit Strategy Note

Group related fixes into a single commit when they address the same concern. Multiple comment replies may reference the same commit SHA — this is expected and acceptable.

## Automated Verification Phase

After all fixes are applied and committed:

1. **Detect project tooling**:
   - Check for `tsconfig.json` → run `npx tsc --noEmit`
   - Check for `eslint.config.*` or `.eslintrc*` → run `npx eslint {changed files}`
   - Check `package.json` for `lint`, `typecheck`, or `check` scripts → prefer those
2. **Run verification**:
   ```bash
   # Example: for Nx-based projects
   npx nx affected --target=lint,typecheck
   
   # Example: for npm-based projects
   npm run typecheck && npm run lint
   ```
3. **Present a summary** of all commits made, grouped by the comment(s) they address

## Manual Verification & Confirmation Phase

After automated checks pass:

1. **Show a summary table** with all commits:
   | Comment ID | File | Commit SHA | Commit Message |
   |------------|------|------------|----------------|
   | (comment ID) | (filename) | (short SHA) | (message) |

2. **Prompt for manual testing**:
   > "All fixes are committed locally and automated checks have passed. Please test the changes manually, then reply with **"looks good"** or **"done testing"** to push the branch and post replies to all PR comments."

3. **Wait for user confirmation** — user must respond with one of the trigger phrases (or similar intent)

## Push & Reply Phase

Once the user confirms:

1. **Push the branch** (`git push`)
2. **Report the push result** and confirm commits are now on GitHub
3. **Post all PR comment replies in one batch**:
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
     -f body="Fixed in [{commit_sha}](https://github.com/{owner}/{repo}/commit/{commit_sha}) — {brief description of what was changed}."
   ```
   - Each reply references its commit SHA as a markdown hyperlink
   - Commits are now resolvable on GitHub after the push
4. **Report completion** with the PR URL

## Summary

| Phase | What Happens | User Role |
|-------|--------------|-----------|
| **Prerequisites** | Check auth, recover from SSO if needed | Confirm or re-authenticate |
| **Fetch** | Pull all/bot comments from GitHub API | Review the list |
| **Cherry-pick** | Filter to user-specified comments if provided | Confirm the subset |
| **Plan** | Build and present a todo list | Approve the plan |
| **Execute** | Apply fixes and commit locally (no replies yet) | — |
| **Automated Verify** | Run lint/typecheck, present change summary | Review output |
| **Manual Confirm** | Prompt for local testing and confirmation | Test manually, then reply "looks good" or "done testing" |
| **Push & Reply** | Push branch, post all PR comment replies | Watch for success |
