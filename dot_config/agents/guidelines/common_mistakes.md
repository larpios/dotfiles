# Common Mistakes & Anti-Patterns

## 🚫 What NOT to Do:
- **No Direct Shell Access:** NEVER use `ls`, `cat`, `grep`, or `find` directly. Use `rtk ls`, `rtk read`, `rtk grep`, and `rtk find`.
- **Prefer `jj` over `Git`:** Use `jj` (Jujutsu) for all version control operations. Do not use `git` unless `jj` is unavailable or explicitly requested.
- **Commit Early and Often:** Create a `jj` commit after every logical task. Do not batch multiple unrelated changes into one commit.
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
