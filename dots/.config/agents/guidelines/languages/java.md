# Java Operational Guidelines

## ✅ DO:
### 1. Modern Features (17/21+)
- **Use Records:** For immutable data transfer objects (DTOs).
```java
public record UserDto(String name, int age) {}
```
- **Switch Expressions:** To ensure exhaustiveness and forced return values.
- **Text Blocks:** For readable multiline SQL/JSON strings.

### 2. Spring Boot & DI
- **Constructor Injection:** Use final fields and constructor injection over `@Autowired` fields.
```java
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepo;
}
```
- **Type-Safe Config:** Use `@ConfigurationProperties` over scattered `@Value` annotations.

### 3. Stream API & Optional
- **Meaningful Stream Chains:** Break complex streams into steps.
- **Optional for Returns Only:** Never use `Optional` for fields or parameters.
- **Functional Optional APIs:** Use `.map()`, `.flatMap()`, and `.orElse()`.

### 4. Concurrency & DB
- **Virtual Threads (21+):** Prefer for I/O-intensive workloads.
- **Entity Graph / Join Fetch:** To prevent N+1 query problems in JPA.
- **Explicit Transactions:** Use `@Transactional(readOnly = true)` for read operations.

## ❌ DO NOT:
- **No Obsolete Classes:** Avoid `Date`, `Calendar`, and `SimpleDateFormat`; use `java.time`.
- **No Field Injection:** Avoid `@Autowired` on private fields.
- **No `Optional.get()`:** Without checking `isPresent()`. Better yet, use functional alternatives.
- **No Swallowed Exceptions:** Never catch and ignore. Use `@ControllerAdvice` for global handling.
- **No `@Data` on JPA Entities:** It triggers lazy loading in `hashCode/equals`. Use `@Getter` and `@Setter` instead.
- **No Manual Thread Management:** Use `ExecutorService` or Virtual Threads.
- **No Broad `catch(Exception e)`:** Catch specific checked exceptions.
