# Python Operational Guidelines

## ✅ DO:
### 1. Type Hinting
- **Annotate Everything:** Use type hints for args, returns, and variables.
```python
from typing import List, Optional
def find_user(user_id: int) -> Optional[User]: ...
```
- **Use Protocols:** For structural subtyping (duck typing).
```python
from typing import Protocol
class Readable(Protocol):
    def read(self, size: int = -1) -> bytes: ...
```

### 2. Async & Concurrency
- **Asyncio Best Practices:** Use `async/await` for I/O and `async with/for`.
- **Task Groups (Python 3.11+):** For managing concurrent tasks safely.
```python
async with asyncio.TaskGroup() as tg:
    t1 = tg.create_task(fetch_a())
    t2 = tg.create_task(fetch_b())
```
- **Use `asyncio.Semaphore`:** To limit concurrent I/O.

### 3. Modern Features
- **f-strings:** For all string formatting.
- **Walrus Operator (`:=`):** For clean assignment in conditions.
```python
if (n := len(items)) > 10:
    print(f"List is too long ({n})")
```
- **Pattern Matching (`match/case`):** For complex branching.

### 4. Data Structures
- **Use `dataclasses`:** For data-only objects.
- **Use `Counter`, `defaultdict`, `deque`:** From `collections`.

## ❌ DO NOT:
- **No Mutable Default Args:** Never use `[]` or `{}` as default values.
```python
# ❌ Bug: list shared across calls
def add(item, items=[]): ...

# ✅ Correct
def add(item, items=None):
    if items is None: items = []
```
- **No Broad `except`:** Never use `except:` or `except Exception:`.
- **No `time.sleep` in Async:** Use `await asyncio.sleep()`.
- **No Manual String Building:** Avoid repeated `+` in loops; use `"".join()`.
- **No Shared Mutable Class Attributes:** Initialize in `__init__`.
- **No `is` for Value Equality:** Use `==` unless checking for `None` or singletons.
- **No Swallowed Exceptions:** Always log or re-raise with `from e`.
```python
# ✅ Preserve context
try:
    risk()
except APIError as e:
    raise AppError("Failed") from e
```
- **No Legacy Python:** Use Python 3.10+ features.
