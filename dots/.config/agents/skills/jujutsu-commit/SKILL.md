---
name: "Jujutsu Commit Expert"
description: "Create atomic, well-formatted commits using jujutsu (jj) VCS. Use when you have staged or unstaged changes and need to commit them following the project's history style."
---

# Jujutsu Commit Expert

## What This Skill Does
This skill guides the agent to create surgical, atomic commits using jujutsu (jj). It automatically identifies the project's commit message convention (e.g., Conventional Commits, Scope-based, or Plain) and groups related changes into separate commits to maintain a clean and readable history.

## Quick Start
1. **Analyze:** Check `jj status` and `jj diff` to understand the changes.
2. **Detect Convention:** Run `jj log -n 10` to see the existing style.
3. **Plan Commits:** Group independent changes (e.g., a fix and a new feature) into separate units.
4. **Execute:** Commit each group with a message that matches the detected pattern.

---

## Step-by-Step Guide

### 1. Research & Analysis
Before committing, you MUST understand what changed and how the team usually describes it.

```bash
# Get context on changes
jj status && jj diff

# Detect convention
jj log -n 10
```

### 2. Grouping (Atomic Logic)
If you have multiple unrelated changes, do NOT commit them all at once.
- **Good:** One commit for a bug fix, one for a new feature.
- **Bad:** "Refactor and add login feature and fix typo".

Use `jj diff --edit` or stage files individually to build atomic commits.

### 3. Crafting the Message
Match the detected convention. Common patterns:
- **Conventional Commits:** `type(scope): description` (e.g., `feat(ui): add dark mode`)
- **Action-based:** `Fix typo in README`
- **JIRA/Issue-based:** `PROJ-123: Implement auth`

### 4. Verification
After each commit, verify the status:
```bash
jj status
jj log -n 1
```

---

## Best Practices
- **Atomicity:** Each commit should be a single "unit of work".
- **Imperative Mood:** Use "Add feature" instead of "Added feature".
- **No Junk:** Ensure no temporary files or debug logs are committed.
- **Scope:** If the project uses scopes (e.g., `feat(core):`), try to identify the correct scope based on the file paths.

## Jujutsu-Specific Commands

### Basic Operations
```bash
# Check status
jj status

# View changes
jj diff

# Stage changes
jj diff --edit

# Commit changes
jj commit -m "message"

# Amend last commit
jj commit --amend -m "new message"

# Create a new commit on top
jj new -r @ -m "new commit"

# View commit history
jj log -n 10

# Show commit details
jj show @

# Revert a commit
jj revert @
```

### Advanced Operations
```bash
# Split a commit into multiple
jj split @

# Squash multiple commits
jj squash -r @^..@ -m "merged message"

# Rebase commits
jj rebase -r @^..@ -s @

# Create a bookmark
jj bookmark my-bookmark

# List bookmarks
jj bookmarks

# Switch to a bookmark
jj bookmark switch my-bookmark

# Create a new branch
jj branch new my-branch

# Switch branches
jj branch switch my-branch

# List branches
jj branches
```

## Troubleshooting
- **Conflict with Convention:** If the project has an inconsistent history, default to Conventional Commits as a safe industry standard.
- **Large Diffs:** If a diff is too large, break it down by file or logical module.
- **jj-specific issues:** Use `jj help <command>` for detailed help on any jj command.

## Common Workflows

### Fixing a Mistake in Last Commit
```bash
# Amend the commit with new changes
jj diff --edit
jj commit --amend -m "updated message"
```

### Splitting a Large Commit
```bash
# Split the commit into multiple smaller commits
jj split @
# Then commit each piece separately
```

### Squashing Multiple Commits
```bash
# Combine multiple commits into one
jj squash -r @^..@ -m "combined message"
```

### Creating a New Branch
```bash
# Create a new branch from current state
jj branch new feature-branch
# Make changes and commit
jj commit -m "feature implementation"
# Switch back to main
jj branch switch main
```