# Architecture & Design Patterns

## ✅ DO:
### 1. Domain-Driven Design (DDD)
- **Bounded Contexts:** Explicitly define boundaries between modules.
- **Entities & Value Objects:** Use Value Objects for data that has no identity (e.g., `Email`, `Money`).
- **Aggregates:** Group related entities into an aggregate with a single root for consistency.
- **Services:** Use Domain Services for logic that doesn't naturally fit in an Entity.

### 2. Clean Architecture
- **Dependency Rule:** Source code dependencies must only point inwards (towards the Domain).
- **Separation of Concerns:** Keep business logic independent of UI, Database, and Frameworks.
- **Interfaces/Traits:** Use them to decouple high-level policy from low-level detail.

### 3. Layered Architecture
- **Domain Layer:** Pure business logic.
- **Application Layer:** Orchestration and Use Cases.
- **Infrastructure Layer:** DB, API, File System.

## ❌ DO NOT:
- **No God Objects:** Avoid classes/structs that know too much or do too much.
- **No Anemic Domain Model:** Avoid objects that are just data containers (getters/setters). Put logic where the data is.
- **No Direct DB Access from UI:** Always go through a Service/Repository.
- **No Hardcoded Dependencies:** Use Dependency Injection or Trait Objects.
- **No "Just in Case" Abstractions:** Don't build for hypothetical future needs. Build for the current requirement but with a clean structure that *allows* for change.
