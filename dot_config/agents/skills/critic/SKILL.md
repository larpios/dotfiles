---
name: ContinuousCritic
version: 1.2.0
description: Active workspace auditor that asynchronously evaluates uncommitted code, applies refactoring patches, and self-reverts upon build failures.
author: larpios
system_dependencies:
  - jj
  - patch
  - cargo # Or make/cmake depending on workspace
triggers:
  - event: file_modified
    patterns: ["*.rs", "*.cpp", "*.h", "*.c"]
    debounce_ms: 30000
permissions:
  - read_workspace
  - write_workspace
  - execute_shell: ["jj status", "jj diff", "jj undo", "patch", "cargo check"]
---

# Skill: Active Workspace Auditor

## Overview

An active, execution-oriented routine that monitors the workspace in the background. It evaluates newly introduced code for architectural debt, inefficiencies, or unhandled edge cases, and directly applies unified diffs to fix them. It enforces strict workspace stability via an automated rollback mechanism if regressions are introduced.

## Core Directives

- **Zero-Intervention:** Execute silently in the background. Do not prompt for permission to attempt a fix.
- **Strict Formatting:** Inference output must be exclusively a unified diff (`.patch`) or a pass signal. No conversational text.
- **Non-Destructive Failures:** All failed mutations must trigger an immediate state reversion.

## Execution Loop

### 1. State Capture

- **Trigger:** Workspace file modification settling after the defined debounce period.
- **Action:** Capture uncommitted state safely.
  - Execute: `jj status` -> Abort if currently resolving a merge conflict.
  - Execute: `jj diff --git > .agent_tmp/current.diff`

### 2. Inference & Evaluation

- **Action:** Pass the captured diff to the local model API.
- **System Prompt Constraint:**

  ```text
  You are an autonomous low-level systems architect. Review the provided Git diff for code quality, memory safety, and architectural integrity.

  Instructions:
  1. Analyze the diff. Identify bloated logic, memory anti-patterns, or edge-case omissions.
  2. Do NOT output conversational text, explanations, or markdown blocks.
  3. Output ONLY a valid unified diff that refactors the code.
  4. If the code requires no changes, output exactly: `STATUS: PASS`.
  ```
