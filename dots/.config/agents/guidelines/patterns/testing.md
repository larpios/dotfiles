# Testing & Validation Guidelines

## ✅ DO:
### 1. Test-Driven Development (TDD)
- **Red-Green-Refactor:** Write a failing test first for bug fixes or new features.
- **Unit Tests:** Test individual components in isolation. Mock complex dependencies.
- **Integration Tests:** Test the interaction between components (e.g., API + DB).
- **End-to-End (E2E):** Use sparingly for critical user flows.

### 2. Mocking & Fakes
- **Use Mock Objects:** When testing logic that depends on external services (API, DB, Env).
- **Prefer Fakes over Mocks:** If a simple in-memory implementation exists (e.g., `InMemoryDatabase`).

### 3. Verification & CI/CD
- **Linting:** Always run the project's linter (ESLint, Clippy, Ruff) before declaring success.
- **Type Checking:** Ensure zero TypeScript/Rust errors.
- **Coverage:** Aim for meaningful coverage, not just high percentages. Test edge cases and error paths.

## ❌ DO NOT:
- **No Mocking Internal Implementation:** Test the *behavior*, not the *method calls*.
- **No Fragile Tests:** Avoid tests that break on every minor refactor.
- **No Flaky Tests:** If a test fails randomly, it must be fixed or removed.
- **No Tests without Assertions:** Every test must assert a specific outcome.
- **No Ignoring Failing Tests:** Never bypass or `@skip` a failing test without a documented reason.
- **No Manual Testing Only:** If you can automate the verification, do so.
