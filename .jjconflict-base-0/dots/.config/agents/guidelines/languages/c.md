# C Operational Guidelines

## ✅ DO:
### 1. Memory Safety & Buffer Management
- **Explicit Sizes:** Always pass the destination buffer's size to functions.
- **Use Bounded APIs:** Favor `snprintf`, `fgets`, and `memcpy` with size validation over `strcpy`, `sprintf`, or `gets`.
```c
bool copy(char *dst, size_t size, const char *src) {
    size_t len = strlen(src);
    if (len + 1 > size) return false;
    memcpy(dst, src, len + 1);
    return true;
}
```
- **Use `memmove`:** When source and destination regions might overlap.

### 2. Ownership & Resource Management
- **RAII-like Cleanup:** Use `goto cleanup` to avoid resource leaks on error paths.
```c
int load(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) return -1;
    char *buf = malloc(4096);
    if (!buf) { fclose(f); return -1; }
    // process...
cleanup:
    free(buf);
    if (f) fclose(f);
    return 0;
}
```

### 3. API Design
- **Const-Correctness:** Mark input-only pointers as `const`.
- **Consistent Error Codes:** 0 for success, negative for failure.

## ❌ DO NOT:
- **No Dangerous APIs:** NEVER use `gets()`. Avoid `strcpy()` and `sprintf()` on untrusted input.
- **No Use-After-Free:** Set pointers to `NULL` after `free()` if they remain in scope.
- **No Implicit Signedness Surprises:** Explicitly validate bounds before casting `int` to `size_t`.
- **No Uninitialized Reads:** Always initialize local variables.
- **No Integer Overflow in Allocation:** Check `count * sizeof(T)` against `SIZE_MAX`.
- **No `volatile` for Sync:** Use C11 atomics or mutexes.
