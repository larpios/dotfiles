# Rust Operational Guidelines

## ✅ DO:
### 1. Ownership & Borrowing
- **Borrow Before Cloning:** Only clone if absolutely necessary (e.g., passing to a spawned task).
```rust
fn process(data: &Data) {
    expensive_op(data); // Pass reference
}
```
- **Use `Cow` (Copy-on-Write):** To avoid unnecessary allocations.
```rust
use std::borrow::Cow;
fn normalize(name: &str) -> Cow<'_, str> {
    if name.chars().any(|c| c.is_uppercase()) {
        Cow::Owned(name.to_lowercase()) // Allocates only when needed
    } else {
        Cow::Borrowed(name) // Borrows otherwise
    }
}
```

### 2. Error Handling
- **Propagate with `?`:** Use structured error types (e.g., `thiserror` for libs, `anyhow` for apps).
- **Add Context:** Use `.context()` or `.with_context()` to explain failures.

### 3. Async & Concurrency
- **Non-blocking Operations:** Use async versions (e.g., `tokio::fs`, `tokio::time`).
- **Scoped Mutexes:** Minimize lock time; never hold `std::sync::Mutex` across `.await`.
```rust
// ✅ Safe: scoped release
{
    let guard = mutex.lock().unwrap();
    process(&guard);
}
async_op().await;
```
- **Structured Concurrency:** Prefer `join!`/`try_join!` over manual `spawn`.

### 4. Unsafe
- **SAFETY Documentation:** Every `unsafe` block MUST have a `// SAFETY: ...` comment.
```rust
// SAFETY: Index is guaranteed within bounds by check above.
unsafe { slice.get_unchecked(i) }
```

## ❌ DO NOT:
- **No `unwrap()` / `expect()`:** Use `match`, `if let`, or `?`.
- **No Shared Mutables:** Avoid `Arc<Mutex<T>>` if possible; use message passing or local ownership.
- **No Unnecessary Collect:** Stay in the iterator chain.
```rust
// ❌ Bad
let items: Vec<_> = data.iter().filter(|x| x > 0).collect();
let sum: i32 = items.iter().sum();

// ✅ Good
let sum: i32 = data.iter().filter(|x| x > 0).sum();
```
- **No Macro Overuse:** Favor standard functions and traits.
- **No Global Statics:** Avoid `static mut`; use `OnceLock` or similar safely.
- **No Ignoring Clippy:** Fix all clippy warnings; do not suppress them without documentation.
