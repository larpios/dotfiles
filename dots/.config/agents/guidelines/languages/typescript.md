# TypeScript Operational Guidelines

## ✅ DO:
### 1. Type Safety & Narrowing
- **Use Type Guards:** Always narrow union types before accessing properties.
```typescript
function getLength(value: string | string[]): number {
  if (Array.isArray(value)) {
    return value.length; // Narrowed to string[]
  }
  return value.length; // Narrowed to string
}
```
- **Use Discriminated Unions:** For state or API responses.
```typescript
type Result<T> = { success: true; data: T } | { success: false; error: string };

function handle(result: Result<User>) {
  if (result.success) {
    console.log(result.data.name); // Type safe
  } else {
    console.error(result.error); // Type safe
  }
}
```

### 2. Generics & Utility Types
- **Constrain Generics:** Use `extends` and `keyof` to maintain safety.
```typescript
function getProp<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```
- **Leverage Built-in Utilities:** Use `Partial`, `Pick`, `Omit`, and `Readonly`.

### 3. Async & Error Handling
- **AbortController for Race Conditions:** Prevent stale data in UI.
```typescript
useEffect(() => {
  const controller = new AbortController();
  fetch(url, { signal: controller.signal }).catch(e => {
    if (e.name !== 'AbortError') throw e;
  });
  return () => controller.abort();
}, [url]);
```
- **Proper Promise Handling:** Avoid "floating" promises. Use `await` or `.catch()`.

### 4. Immutability
- **Use `as const`:** For literal types and configuration.
```typescript
const CONFIG = { endpoint: '/api', method: 'GET' } as const;
```

## ❌ DO NOT:
- **No `any`:** Use `unknown` + Type Guard instead.
- **No Non-null Assertions (`!`):** Unless absolutely certain (e.g., initialized in `beforeEach`). Use optional chaining `?.` or nullish coalescing `??`.
- **No Mutable Params:** Do not modify function arguments; return new objects/arrays.
- **No Magic Strings:** Use Enums or Literal Unions.
- **No `@ts-ignore`:** Use `@ts-expect-error` with an explanatory comment if unavoidable.
- **No Implicit Returns:** Ensure all code paths return a value.
- **No Direct Indexed Access:** Enable `noUncheckedIndexedAccess` in tsconfig.
```typescript
// ❌ Dangerous
const item = arr[0];
console.log(item.name); // Might crash if arr is empty

// ✅ Safe
const item = arr[0];
if (item) console.log(item.name);
```
