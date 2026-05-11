# C++ Operational Guidelines

## ✅ DO:
### 1. Ownership & RAII
- **Rule of 0/3/5:** Prefer Rule of 0 with smart pointers and RAII collections.
- **Smart Pointers:** Default to `std::unique_ptr`. Use `std::shared_ptr` only for shared ownership.
- **Modern C++ Init:** Use `std::make_unique` and `std::make_shared`.

### 2. Lifetime & Views
- **Guard Lifetime:** Ensure owners outlive `std::string_view` or `std::span`.
- **Prefer Capture-by-Value:** In lambdas that escape their scope.

### 3. API Design & Safety
- **Const-Correctness:** Apply consistently; mark member functions `const` where appropriate.
- **Use `override` / `final`:** For all virtual function overrides.
- **Explicit Constructors:** Prevent unintended implicit conversions.
```cpp
struct Millis {
    explicit Millis(int v) : value(v) {}
    int value;
};
```

### 4. Performance & Modern Features
- **Reserve Upfront:** To minimize `std::vector` reallocations.
- **Constrained Templates:** Use C++20 `concepts` to clarify intent and errors.
- **Noexcept Destructors:** Ensure destructors never throw.

## ❌ DO NOT:
- **No `new` / `delete`:** Use RAII types or smart pointers.
- **No Object Slicing:** Avoid passing by value for polymorphic types; use references.
- **No Throw from Destructors:** This will call `std::terminate`.
- **No Dangerous Captured Refs:** Never capture local variables by reference in an escaping lambda.
- **No Unchecked Iterators:** Use range-based for or STL algorithms.
- **No Volatile for Sync:** Use `std::atomic` or `std::mutex`.
- **No C-style Casts:** Use `static_cast`, `const_cast`, or `reinterpret_cast`.
