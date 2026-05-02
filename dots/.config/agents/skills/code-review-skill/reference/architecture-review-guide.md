# Architecture Review Guide

A guide for architectural design reviews to help evaluate whether code architecture is sound and design is appropriate.

## SOLID Principles Checklist

### S - Single Responsibility Principle (SRP)

**Key Checkpoints:**
- Does this class/module have only one reason to change?
- Do all methods within the class serve the same purpose?
- If you had to describe this class to a non-technical person, could you do it in one sentence?

**Red Flags in Code Review:**
```
⚠️ Class names containing generic terms like "And", "Manager", "Handler", "Processor"
⚠️ A single class exceeding 200-300 lines of code
⚠️ A class with more than 5-7 public methods
⚠️ Different methods operating on entirely different sets of data
```

**Review Questions:**
- "What are the responsibilities of this class? Can it be split?"
- "If requirement X changes, which methods need to be modified? What if requirement Y changes?"

### O - Open/Closed Principle (OCP)

**Key Checkpoints:**
- When adding new features, is it necessary to modify existing code?
- Can new behaviors be added through extension (inheritance, composition)?
- Are there excessive if/else or switch statements handling different types?

**Red Flags in Code Review:**
```
⚠️ switch/if-else chains handling different types
⚠️ Adding new features requires modifying core classes
⚠️ Type checks (instanceof, typeof) scattered throughout the code
```

**Review Questions:**
- "If we need to add a new type X, which files need to be modified?"
- "Will this switch statement grow as new types are added?"

### L - Liskov Substitution Principle (LSP)

**Key Checkpoints:**
- Can subclasses be used as a complete substitute for the parent class?
- Does the subclass change the expected behavior of the parent class methods?
- Do subclasses throw exceptions that were not declared by the parent class?

**Red Flags in Code Review:**
```
⚠️ Explicit type casting
⚠️ Subclass methods throwing NotImplementedException
⚠️ Subclass methods with empty implementations or just a return statement
⚠️ Places using the base class needing to check for specific concrete types
```

**Review Questions:**
- "If the parent class is replaced by a subclass, does the calling code need modification?"
- "Does the behavior of this method in the subclass adhere to the parent class's contract?"

### I - Interface Segregation Principle (ISP)

**Key Checkpoints:**
- Is the interface small and focused enough?
- Are implementation classes forced to implement methods they don't need?
- Do clients depend on methods they do not use?

**Red Flags in Code Review:**
```
⚠️ Interfaces with more than 5-7 methods
⚠️ Implementation classes with empty methods or throwing NotImplementedException
⚠️ Interface names that are too broad (IManager, IService)
⚠️ Different clients using only a subset of the interface's methods
```

**Review Questions:**
- "Are all methods of this interface used by every implementation class?"
- "Can this large interface be broken down into smaller, specialized interfaces?"

### D - Dependency Inversion Principle (DIP)

**Key Checkpoints:**
- Do high-level modules depend on abstractions rather than concrete implementations?
- Is dependency injection used instead of direct object instantiation (new)?
- Are abstractions defined by high-level modules rather than low-level ones?

**Red Flags in Code Review:**
```
⚠️ High-level modules directly instantiating concrete classes of low-level modules
⚠️ Importing concrete implementation classes instead of interfaces/abstract classes
⚠️ Configurations and connection strings hardcoded in business logic
⚠️ Difficulty in writing unit tests for a specific class
```

**Review Questions:**
- "Can the dependencies of this class be replaced by mocks during testing?"
- "If we change the database/API implementation, how many places need to be modified?"

---

## Identifying Architecture Anti-Patterns

### Fatal Anti-Patterns

| Anti-Pattern | Red Flags | Impact |
|--------------|-----------|--------|
| **Big Ball of Mud** | No clear module boundaries; any code can call any other code | Difficult to understand, modify, and test |
| **God Object** | A single class taking on too many responsibilities, knowing and doing too much | High coupling; difficult to reuse and test |
| **Spaghetti Code** | Tangled control flow, gotos, or deep nesting; difficult to trace execution paths | Difficult to understand and maintain |
| **Lava Flow** | Ancient code that no one dares to touch; lacks documentation and testing | Accumulation of technical debt |

### Design Anti-Patterns

| Anti-Pattern | Red Flags | Recommendation |
|--------------|-----------|----------------|
| **Golden Hammer** | Using the same technology/pattern for every problem | Choose the right solution based on the specific problem |
| **Over-engineering (Gas Factory)** | Solving simple problems with complex solutions; abusing design patterns | YAGNI principle: start simple, add complexity only when needed |
| **Boat Anchor** | Unused code written for "future needs" | Delete unused code; write it only when actually needed |
| **Copy-Paste Programming** | Identical logic appearing in multiple places | Extract into common methods or modules |

### Review Comments

```markdown
🔴 [blocking] "This class has 2000 lines of code; suggest splitting it into multiple focused classes"
🟡 [important] "This logic is repeated in 3 places; consider extracting it into a common method?"
💡 [suggestion] "This switch statement could be replaced with the Strategy pattern for better extensibility"
```

---

## Assessing Coupling and Cohesion

### Types of Coupling (Best to Worst)

| Type | Description | Example |
|------|-------------|---------|
| **Message Coupling** ✅ | Passing data via parameters | `calculate(price, quantity)` |
| **Data Coupling** ✅ | Sharing simple data structures | `processOrder(orderDTO)` |
| **Stamp Coupling** ⚠️ | Sharing complex structures but only using a part | Passing a whole User object but only using the name |
| **Control Coupling** ⚠️ | Passing control flags to influence behavior | `process(data, isAdmin=true)` |
| **Common Coupling** ❌ | Sharing global variables | Multiple modules reading/writing the same global state |
| **Content Coupling** ❌ | Directly accessing another module's internals | Directly manipulating private properties of another class |

### Types of Cohesion (Best to Worst)

| Type | Description | Quality |
|------|-------------|---------|
| **Functional Cohesion** | All elements perform a single task | ✅ Best |
| **Sequential Cohesion** | Output serves as input for the next step | ✅ Good |
| **Communicational Cohesion** | Operations on the same data | ⚠️ Acceptable |
| **Temporal Cohesion** | Tasks performed at the same time | ⚠️ Poor |
| **Logical Cohesion** | Logically related but functionally different | ❌ Poor |
| **Coincidental Cohesion** | No apparent relationship | ❌ Worst |

### Metric References

```yaml
Coupling Metrics:
  CBO (Coupling Between Objects):
    Good: < 5
    Warning: 5-10
    Danger: > 10

  Ce (Efferent Coupling):
    Description: How many external classes it depends on
    Good: < 7

  Ca (Afferent Coupling):
    Description: How many classes depend on it
    High value means: High impact of changes, needs stability

Cohesion Metrics:
  LCOM4 (Lack of Cohesion of Methods):
    1: Single Responsibility ✅
    2-3: May need splitting ⚠️
    >3: Should be split ❌
```

### Review Questions

- "How many other modules does this module depend on? Can this be reduced?"
- "How many other places will be affected by modifying this class?"
- "Do all methods in this class operate on the same data?"

---

## Layered Architecture Review

### Clean Architecture Layer Check

```
┌─────────────────────────────────────┐
│         Frameworks & Drivers        │ ← Outermost: Web, DB, UI
├─────────────────────────────────────┤
│         Interface Adapters          │ ← Controllers, Gateways, Presenters
├─────────────────────────────────────┤
│          Application Layer          │ ← Use Cases, Application Services
├─────────────────────────────────────┤
│            Domain Layer             │ ← Entities, Domain Services
└─────────────────────────────────────┘
          ↑ Dependency direction must be inward ↑
```

### Dependency Rule Check

**Core Rule: Source code dependencies can only point inwards**

```typescript
// ❌ Violation of dependency rule: Domain layer depending on Infrastructure
// domain/User.ts
import { MySQLConnection } from '../infrastructure/database';

// ✅ Correct: Domain layer defines interface, Infrastructure implements it
// domain/UserRepository.ts (Interface)
interface UserRepository {
  findById(id: string): Promise<User>;
}

// infrastructure/MySQLUserRepository.ts (Implementation)
class MySQLUserRepository implements UserRepository {
  findById(id: string): Promise<User> { /* ... */ }
}
```

### Review Checklist

**Layer Boundary Check:**
- [ ] Does the Domain layer have external dependencies (DB, HTTP, File System)?
- [ ] Does the Application layer directly manipulate the database or call external APIs?
- [ ] Does the Controller contain business logic?
- [ ] Are there cross-layer calls (e.g., UI directly calling Repository)?

**Separation of Concerns Check:**
- [ ] Is business logic separated from presentation logic?
- [ ] Is data access encapsulated in a dedicated layer?
- [ ] Is configuration and environment-related code managed centrally?

### Review Comments

```markdown
🔴 [blocking] "Domain entities directly import database connections, violating the dependency rule"
🟡 [important] "Controller contains business calculation logic; suggest moving it to the Service layer"
💡 [suggestion] "Consider using Dependency Injection to decouple these components"
```

---

## Design Pattern Usage Evaluation

### When to Use Design Patterns

| Pattern | Applicable Scenario | When Not to Use |
|---------|---------------------|-----------------|
| **Factory** | Need to create different types of objects determined at runtime | Only one type exists, or types are fixed |
| **Strategy** | Algorithms need to be switched at runtime; multiple interchangeable behaviors | Only one algorithm exists, or it won't change |
| **Observer** | One-to-many dependency; state changes need to notify multiple objects | Simple direct calls are sufficient |
| **Singleton** | Truly need a globally unique instance, e.g., config management | Objects that can be passed via Dependency Injection |
| **Decorator** | Need to add responsibilities dynamically without inheritance explosion | Responsibilities are fixed; no need for dynamic composition |

### Over-engineering Warning Signs

```
⚠️ Patternitis Identification Signals:

1. Simple if/else replaced by Strategy pattern + Factory + Registry
2. Interfaces with only one implementation
3. Abstraction layers added for "future needs"
4. Code line count significantly increases due to pattern application
5. Newcomers take a long time to understand the code structure
```

### Review Principles

```markdown
✅ Correct Pattern Usage:
- Solves an actual scalability problem
- Code is easier to understand and test
- Adding new features becomes simpler

❌ Pattern Overuse:
- Using a pattern for the sake of using it
- Adds unnecessary complexity
- Violates the YAGNI principle
```

### Review Questions

- "What specific problem does using this pattern solve?"
- "What would be the issue with the code if this pattern weren't used?"
- "Does the value brought by this abstraction layer outweigh its complexity?"

---

## Scalability Assessment

### Scalability Checklist

**Functional Scalability:**
- [ ] Does adding new features require modifying core code?
- [ ] Are extension points provided (hooks, plugins, events)?
- [ ] Is configuration externalized (config files, environment variables)?

**Data Scalability:**
- [ ] Does the data model support adding new fields?
- [ ] Have scenarios for data volume growth been considered?
- [ ] Do queries have appropriate indexes?

**Load Scalability:**
- [ ] Can it be scaled horizontally (adding more instances)?
- [ ] Are there state dependencies (session, local cache)?
- [ ] Are database connections using a connection pool?

### Extension Point Design Check

```typescript
// ✅ Good extension design: Using events/hooks
class OrderService {
  private hooks: OrderHooks;

  async createOrder(order: Order) {
    await this.hooks.beforeCreate?.(order);
    const result = await this.save(order);
    await this.hooks.afterCreate?.(result);
    return result;
  }
}

// ❌ Poor extension design: Hardcoding all behaviors
class OrderService {
  async createOrder(order: Order) {
    await this.sendEmail(order);        // Hardcoded
    await this.updateInventory(order);  // Hardcoded
    await this.notifyWarehouse(order);  // Hardcoded
    return await this.save(order);
  }
}
```

### Review Comments

```markdown
💡 [suggestion] "If we need to support new payment methods in the future, is this design easy to extend?"
🟡 [important] "The logic here is hardcoded; consider using configuration or the Strategy pattern?"
📚 [learning] "Event-driven architecture could make this feature easier to scale"
```

---

## Code Structure Best Practices

### Directory Organization

**Organize by Feature/Domain (Recommended):**
```
src/
├── user/
│   ├── User.ts           (Entity)
│   ├── UserService.ts    (Service)
│   ├── UserRepository.ts (Data Access)
│   └── UserController.ts (API)
├── order/
│   ├── Order.ts
│   ├── OrderService.ts
│   └── ...
└── shared/
    ├── utils/
    └── types/
```

**Organize by Technical Layer (Not Recommended):**
```
src/
├── controllers/     ← Different domains mixed together
│   ├── UserController.ts
│   └── OrderController.ts
├── services/
├── repositories/
└── models/
```

### Naming Convention Check

| Type | Convention | Example |
|------|------------|---------|
| Class Name | PascalCase, Noun | `UserService`, `OrderRepository` |
| Method Name | camelCase, Verb | `createUser`, `findOrderById` |
| Interface Name | I prefix or no prefix | `IUserService` or `UserService` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Private Property | Underscore prefix or none | `_cache` or `#cache` |

### File Size Guidelines

```yaml
Suggested Limits:
  Single File: < 300 lines
  Single Function: < 50 lines
  Single Class: < 200 lines
  Function Parameters: < 4
  Nesting Depth: < 4 levels

When limits are exceeded:
  - Consider splitting into smaller units
  - Use composition instead of inheritance
  - Extract helper functions or classes
```

### Review Comments

```markdown
🟢 [nit] "This 500-line file could be split based on responsibilities"
🟡 [important] "Suggest organizing directory structure by functional domain rather than technical layer"
💡 [suggestion] "The function name `process` is not clear enough; consider changing it to `calculateOrderTotal`?"
```

---

## Quick Reference Checklist

### 5-Minute Architecture Quick Check

```markdown
□ Is the dependency direction correct? (Outer depends on inner)
□ Are there any circular dependencies?
□ Is core business logic decoupled from frameworks/UI/database?
□ Are SOLID principles followed?
□ Are there any obvious anti-patterns?
```

### Red Flags (Must Address)

```markdown
🔴 God Object - A single class exceeding 1000 lines
🔴 Circular Dependency - A → B → C → A
🔴 Domain layer containing framework dependencies
🔴 Hardcoded configurations and secrets
🔴 External service calls without interfaces
```

### Yellow Flags (Suggested Address)

```markdown
🟡 Coupling Between Objects (CBO) > 10
🟡 More than 5 function parameters
🟡 Nesting depth exceeding 4 levels
🟡 Duplicate code blocks > 10 lines
🟡 Interfaces with only one implementation
```

---

## Recommended Tools

| Tool | Purpose | Language Support |
|------|---------|------------------|
| **SonarQube** | Code quality, coupling analysis | Multi-language |
| **NDepend** | Dependency analysis, architecture rules | .NET |
| **JDepend** | Package dependency analysis | Java |
| **Madge** | Module dependency graphs | JavaScript/TypeScript |
| **ESLint** | Code linting, complexity checks | JavaScript/TypeScript |
| **CodeScene** | Technical debt, hotspot analysis | Multi-language |

---

## Reference Resources

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles in Code Review - JetBrains](https://blog.jetbrains.com/upsource/2015/08/31/what-to-look-for-in-a-code-review-solid-principles-2/)
- [Software Architecture Anti-Patterns](https://medium.com/@christophnissle/anti-patterns-in-software-architecture-3c8970c9c4f5)
- [Coupling and Cohesion in System Design](https://www.geeksforgeeks.org/system-design/coupling-and-cohesion-in-system-design/)
- [Design Patterns - Refactoring Guru](https://refactoring.guru/design-patterns)
