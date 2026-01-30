# 🔀 Java Translator Skill

## Purpose

Provide expert-level code translation from C# patterns to Java idioms with best practices.

## Capabilities

This skill specializes in:

- Idiomatic Java code generation
- Pattern conversion (C# → Java)
- Best practices application
- Performance optimization
- Code quality assurance

## Usage

```
@csharp-to-java-migrator #skill java-translator [C# code snippet]
```

## What It Does

### 1. Syntax Translation

Converts C# syntax to Java equivalent:

```csharp
// C#
using System;
using System.Collections.Generic;

public class Example {
    private readonly List<string> items;
}
```

```java
// Java
import java.util.*;

public class Example {
    private final List<String> items;
}
```

### 2. Language Feature Mapping

#### Object-Oriented Features

```
C#                     → Java
class                  → class
interface              → interface
abstract               → abstract
sealed                 → final
static                 → static
partial                → N/A (use composition)
override               → @Override
virtual                → extends/implements
```

#### Data Types

```
C#                     → Java
string                 → String
int, long, double      → int, long, double (same)
decimal                → BigDecimal
nullable<T>            → Optional<T>
dynamic                → Object / Reflection
var                    → <type> or var (Java 10+)
```

#### Collections

```
C#                     → Java
List<T>                → List<T> / ArrayList<T>
Dictionary<K,V>        → Map<K,V> / HashMap<K,V>
HashSet<T>             → Set<T> / HashSet<T>
Queue<T>               → Queue<T> / LinkedList<T>
Stack<T>               → Deque<T> / Stack<T>
IEnumerable<T>         → Iterable<T>
```

### 3. Async Pattern Transformation

#### Simple Async/Await

```csharp
// C#
public async Task<User> GetUserAsync(int id) {
    var user = await repository.GetAsync(id);
    return user;
}
```

```java
// Java - CompletableFuture
public CompletableFuture<User> getUser(int id) {
    return repository.getAsync(id);
}

// Java - Project Reactor (Recommended)
public Mono<User> getUser(int id) {
    return repository.getAsync(id);
}
```

#### Complex Async Chaining

```csharp
// C#
public async Task<PaymentResult> ProcessAsync(Order order) {
    var validated = await validator.ValidateAsync(order);
    var saved = await repository.SaveAsync(validated);
    await notifier.NotifyAsync(saved);
    return saved;
}
```

```java
// Java - Reactive Chain
public Mono<PaymentResult> process(Order order) {
    return validator.validate(order)
        .flatMap(validated -> repository.save(validated))
        .flatMap(saved -> notifier.notify(saved)
            .thenReturn(saved));
}
```

### 4. LINQ Transformation

#### Where/Select/OrderBy

```csharp
// C#
var results = users
    .Where(u => u.Active)
    .OrderBy(u => u.Name)
    .Select(u => u.ToDto())
    .ToList();
```

```java
// Java
List<UserDto> results = users.stream()
    .filter(u -> u.isActive())
    .sorted(Comparator.comparing(User::getName))
    .map(User::toDto)
    .collect(Collectors.toList());
```

### 5. Null Coalescing & Conditional Access

```csharp
// C#
var name = user?.Name ?? "Unknown";
var length = items?.Count ?? 0;
```

```java
// Java 8
String name = user != null && user.getName() != null
    ? user.getName() : "Unknown";
int length = items != null ? items.size() : 0;

// Java 9+
String name = Optional.ofNullable(user)
    .map(User::getName)
    .orElse("Unknown");
int length = Optional.ofNullable(items)
    .map(Collection::size)
    .orElse(0);
```

### 6. String Interpolation

```csharp
// C#
var message = $"Hello {name}, you are {age} years old";
```

```java
// Java
String message = String.format("Hello %s, you are %d years old", name, age);
// Or
String message = "Hello " + name + ", you are " + age + " years old";
```

### 7. Dependency Injection

```csharp
// C#
public class Service {
    private readonly IRepository repo;
    public Service(IRepository repo) => this.repo = repo;
}
```

```java
// Java
public class Service {
    private final Repository repo;

    public Service(Repository repo) {
        this.repo = repo;
    }
}
```

### 8. Properties to Getters/Setters

```csharp
// C#
public class User {
    public string Name { get; set; }
    public int Age { get; private set; }
}
```

```java
// Java - Traditional
public class User {
    private String name;
    private int age;

    public String getName() { return name; }
    public void setName(String value) { this.name = value; }
    public int getAge() { return age; }
}

// Java - Records (Java 16+)
public record User(String name, int age) {}
```

### 9. Exception Handling

```csharp
// C#
try {
    var result = await service.ProcessAsync();
} catch (ArgumentException ex) {
    logger.LogError(ex, "Invalid argument");
    throw;
}
```

```java
// Java
try {
    Result result = service.process().get();
} catch (IllegalArgumentException ex) {
    logger.error("Invalid argument", ex);
    throw ex;
} catch (Exception ex) {
    logger.error("Error", ex);
    throw new RuntimeException(ex);
}
```

### 10. Events to Callbacks

```csharp
// C#
public event EventHandler<PaymentEventArgs> PaymentProcessed;

protected void OnPaymentProcessed(PaymentResult result) {
    PaymentProcessed?.Invoke(this, new PaymentEventArgs(result));
}
```

```java
// Java
private Consumer<PaymentResult> paymentProcessedListener;

public void onPaymentProcessed(PaymentResult result) {
    if (paymentProcessedListener != null) {
        paymentProcessedListener.accept(result);
    }
}

public void setPaymentProcessedListener(Consumer<PaymentResult> listener) {
    this.paymentProcessedListener = listener;
}
```

## Output Quality Standards

Every translation ensures:

- ✅ 100% functionality equivalence
- ✅ Idiomatic Java code
- ✅ Performance optimization
- ✅ Proper error handling
- ✅ Type safety with generics
- ✅ Clean code principles
- ✅ SOLID principles applied
- ✅ Thread safety where needed

## When to Use

Use `#skill java-translator` when you:

- ✅ Have C# code snippets to convert
- ✅ Need idiom translation guidance
- ✅ Want to verify translation correctness
- ✅ Need pattern conversion advice
- ✅ Are learning Java from C# background

---

**Skill Version**: 1.0  
**Languages**: C# ↔ Java  
**Output**: Production-ready code
