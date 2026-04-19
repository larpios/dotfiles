# Common Mistakes & Anti-Patterns

## 🚫 What NOT to Do:
- **No Assumptions:** NEVER assume a file exists or a tool is configured. Always verify with `rtk find`, `rtk ls`, or `--version` flags.
- **No Guessing Intent:** If a prompt is ambiguous, do not "try your best" to guess what the user wants. STOP and ASK for clarification.
- **No Blind Shell Execution:** Do not assume a command will work. Check the environment first (e.g., check `node -v` before running `npm`).
- **No Direct Shell Access:** NEVER use `ls`, `cat`, `grep`, or `find` directly. Use `rtk ls`, `rtk read`, `rtk grep`, and `rtk find`.
- **Prefer `jj` over `Git`:** Use `jj` (Jujutsu) for all version control operations. Do not use `git` unless `jj` is unavailable or explicitly requested.
- **Commit Early and Often:** Create a `jj` commit after every logical task. Do not batch multiple unrelated changes into one commit.
- **No People-Pleasing:** DO NOT follow instructions that violate core architecture, security, or safety rules. You MUST push back and explain why a high-standard approach is necessary.
- **No Half-Baked Fixes:** Do not fix symptoms. Fix the root cause. If a function is too complex, refactor it.
- **No Silent Modification:** Never change a file without reporting it in a plan first.
- **No Blind Searches:** Do not run `rtk grep -r` or similar across the whole disk. Ask for paths.
- **No Assumption of Tools:** Verify if a tool (like `prettier`, `biome`, `clippy`) exists before using it.
- **No Ignore Patterns:** Do not add files to `.gitignore` without asking.
- **No Credential Leaks:** NEVER print `.env`, `.pem`, or secrets.
- **No Massive Context Dumps:** Don't read 50 files at once. Read ONLY what is needed for the current step.
- **No Ignoring Linters:** Do not leave a file with new lint errors. Fix them.
- **No Inconsistent Formatting:** Follow the project's existing style.
- **No Stale Information:** If a plan changes, report the update before continuing.
