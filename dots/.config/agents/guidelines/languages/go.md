# Go Operational Guidelines

## ✅ DO:
### 1. Error Handling
- **Propagate with Context:** Use `%w` to wrap errors and provide context.
```go
if err != nil {
    return fmt.Errorf("failed to process user %d: %w", userID, err)
}
```
- **Check once, handle once:** Don't log and return. Return the error and let the caller handle it.
- **Use `errors.Is` and `errors.As`:** For checking error types/values.

### 2. Concurrency
- **Avoid Goroutine Leaks:** Always ensure goroutines have an exit signal (e.g., via `context.Context` or a `done` channel).
- **Add before Spawn:** Call `wg.Add(1)` *before* starting the goroutine.
- **Pass Loop Variables:** Capture loop variables explicitly in goroutines (for Go < 1.22).
```go
for _, item := range items {
    go func(it Item) {
        process(it)
    }(item)
}
```

### 3. Context & Lifecycle
- **Context as First Param:** Always pass `ctx context.Context` as the first argument.
- **Always Cancel:** Ensure `cancel()` is called, typically via `defer`.
```go
ctx, cancel := context.WithTimeout(parent, 5*time.Second)
defer cancel()
```

### 4. Code Organization
- **Functional Package Names:** Use clear, function-based names like `user`, `order`, `postgres` instead of `utils` or `common`.

## ❌ DO NOT:
- **No Swallowed Errors:** Never use `_` for an error return unless it's a known non-critical case.
- **No Shared Mutable State without Locks:** Use `sync.Mutex` or Channels.
- **No Nil Map Assignments:** Always initialize maps with `make()` or literals.
- **No Defer in Loops:** Move logic to a helper function to ensure `defer` runs every iteration.
- **No Panic in Production:** Use `error` returns. Reserve `panic` for truly unrecoverable setup issues.
- **No Interface Nil Trap:** Be careful when returning a concrete nil pointer as an `error` interface.
```go
// ❌ Dangerous
func returnsErr() error {
    var p *MyErr = nil
    return p // returns non-nil interface{type: *MyErr, value: nil}
}
```
