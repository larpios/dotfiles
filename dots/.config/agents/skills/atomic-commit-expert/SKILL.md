---
name: "Atomic Commit Expert"
description: "Create atomic, well-formatted commits following the local repository's conventions. Use when you have staged or unstaged changes and need to commit them following the project's history style."
---

# Atomic Commit Expert

## What This Skill Does
This skill guides the agent to create surgical, atomic commits. It automatically identifies the project's commit message convention (e.g., Conventional Commits, Scope-based, or Plain) and groups related changes into separate commits to maintain a clean and readable history.

## Quick Start
1. **Analyze:** Check `git status` and `git diff` to understand the changes.
2. **Detect Convention:** Run `git log -n 10 --oneline` to see the existing style.
3. **Plan Commits:** Group independent changes (e.g., a fix and a new feature) into separate units.
4. **Execute:** Commit each group with a message that matches the detected pattern.

---

## Step-by-Step Guide

### 1. Research & Analysis
Before committing, you MUST understand what changed and how the team usually describes it.

```bash
# Get context on changes
git status && git diff

# Detect convention
git log -n 10 --oneline
```

### 2. Grouping (Atomic Logic)
If you have multiple unrelated changes, do NOT commit them all at once.
- **Good:** One commit for a bug fix, one for a new feature.
- **Bad:** "Refactor and add login feature and fix typo".

Use `git add -p` or stage files individually to build atomic commits.

### 3. Crafting the Message
Match the detected convention. Common patterns:
- **Conventional Commits:** `type(scope): description` (e.g., `feat(ui): add dark mode`)
- **Action-based:** `Fix typo in README`
- **JIRA/Issue-based:** `PROJ-123: Implement auth`

### 4. Verification
After each commit, verify the status:
```bash
git status
git log -n 1 --oneline
```

---

## Best Practices
- **Atomicity:** Each commit should be a single "unit of work".
- **Imperative Mood:** Use "Add feature" instead of "Added feature".
- **No Junk:** Ensure no temporary files or debug logs are committed.
- **Scope:** If the project uses scopes (e.g., `feat(core):`), try to identify the correct scope based on the file paths.

## Troubleshooting
- **Conflict with Convention:** If the project has an inconsistent history, default to Conventional Commits as a safe industry standard.
- **Large Diffs:** If a diff is too large, break it down by file or logical module.
