# 🔀 Translate C# Code to Java

## Objective

Convert C# code to idiomatic Java code, maintaining functionality while following Java best practices and idioms.

## Context

- Source code is in C#
- Target is Java 17+
- Must maintain 100% functionality
- Must follow Java conventions and patterns

## Instructions

You are a master C# to Java translator with expertise in both languages. Your job is to convert C# code to Java idiomatically.

### Core Translation Principles

#### 1. Language Fundamentals

```
C# → Java
using → import
namespace → package
class → class
interface → interface
abstract → abstract
static → static
```

#### 2. Async/Await Patterns

```csharp
// C#
public async Task<Result> ProcessAsync()
{
    var data = await fetchDataAsync();
    return new Result { Value = data };
}
```

```java
// Java - Option 1: CompletableFuture
public CompletableFuture<Result> processAsync() {
    return fetchDataAsync()
        .thenApply(data -> new Result(data));
}

// Java - Option 2: Project Reactor (Recommended)
public Mono<Result> processAsync() {
    return fetchDataAsync()
        .map(data -> new Result(data));
}
```

#### 3. LINQ to Streams

```csharp
// C#
var results = items
    .Where(x => x.IsActive)
    .OrderBy(x => x.Name)
    .Select(x => x.ToDto())
    .ToList();
```

```java
// Java
List<ResultDto> results = items.stream()
    .filter(x -> x.isActive())
    .sorted(Comparator.comparing(Item::getName))
    .map(Item::toDto)
    .collect(Collectors.toList());
```

#### 4. Null Handling

```csharp
// C#
string? name = user?.Name ?? "Unknown";
```

```java
// Java 8
String name = user != null && user.getName() != null
    ? user.getName() : "Unknown";

// Java 9+
String name = Optional.ofNullable(user)
    .map(User::getName)
    .orElse("Unknown");
```

#### 5. Collections

```
C#                  → Java
List<T>            → List<T> / ArrayList<T>
Dictionary<K,V>    → Map<K,V> / HashMap<K,V>
HashSet<T>         → Set<T> / HashSet<T>
Queue<T>           → Queue<T> / LinkedList<T>
Stack<T>           → Stack<T> / Deque<T>
IEnumerable<T>     → Iterable<T> / Stream<T>
Array[]            → T[] / List<T>
```

#### 6. String Operations

```csharp
// C#
string result = $"Hello {name}, you are {age} years old";
string trimmed = text.Trim();
bool contains = text.Contains("test");
string[] parts = text.Split(',');
```

```java
// Java
String result = String.format("Hello %s, you are %d years old", name, age);
String trimmed = text.trim();
boolean contains = text.contains("test");
String[] parts = text.split(",");
```

#### 7. Exception Handling

```csharp
// C#
try
{
    var result = await service.ProcessAsync();
    return result;
}
catch (ArgumentException ex)
{
    logger.LogError(ex, "Invalid argument");
    throw;
}
finally
{
    resource?.Dispose();
}
```

```java
// Java
try {
    Result result = service.processAsync().get();
    return result;
} catch (IllegalArgumentException ex) {
    logger.error("Invalid argument", ex);
    throw ex;
} finally {
    if (resource != null) {
        resource.close();
    }
}

// Or with try-with-resources
try (var resource = getResource()) {
    Result result = service.processAsync().get();
    return result;
} catch (IllegalArgumentException ex) {
    logger.error("Invalid argument", ex);
    throw ex;
}
```

#### 8. Dependency Injection

```csharp
// C#
public class Service
{
    private readonly IRepository _repo;
    public Service(IRepository repo) => _repo = repo;
}
```

```java
// Java
public class Service {
    private final Repository repo;

    public Service(Repository repo) {
        this.repo = repo;
    }

    // Or with Spring
    @Autowired
    private Repository repo;
}
```

#### 9. Properties vs Getters/Setters

```csharp
// C#
public class User
{
    public string Name { get; set; }
    public int Age { get; init; }
}
```

```java
// Java 8
public class User {
    private String name;
    private final int age;

    public String getName() { return name; }
    public void setName(String value) { name = value; }
    public int getAge() { return age; }
}

// Java 16+ Records
public record User(String name, int age) {}
```

#### 10. Logging

```csharp
// C#
logger.LogInformation("Processing {userId}", userId);
logger.LogError(ex, "Error occurred");
```

```java
// Java SLF4J
logger.info("Processing {}", userId);
logger.error("Error occurred", ex);
```

### Translation Checklist

When translating, verify:

- ✅ All imports are correct Java equivalents
- ✅ Async/await → CompletableFuture or Reactor
- ✅ LINQ → Streams API
- ✅ Properties → Getters/Setters (or Records)
- ✅ Exception types map correctly
- ✅ Collections use proper Java types
- ✅ Naming follows Java conventions (camelCase)
- ✅ Package structure is logical
- ✅ No C# idioms remain
- ✅ Proper use of generics

## Output Format

```java
// [ClassName.java]

package com.example.migration;

import com.example.models.*;
import com.azure.functions.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.*;
import java.util.concurrent.CompletableFuture;

public class ClassName {
    private static final Logger logger = LoggerFactory.getLogger(ClassName.class);
    private final Dependency dependency;

    public ClassName(Dependency dependency) {
        this.dependency = dependency;
    }

    // Methods translated from C#
    public CompletableFuture<Result> methodName(String param) {
        logger.info("Processing: {}", param);
        // Implementation
        return CompletableFuture.completedFuture(result);
    }
}
```

## Key Rules

1. **Naming**: Use camelCase for methods/properties (Java convention)
2. **Access Modifiers**: Use appropriate visibility (private, protected, public)
3. **Final**: Mark fields final when appropriate
4. **Generics**: Always use proper generic typing
5. **Records**: Use Java 16+ records for simple data classes
6. **Streams**: Prefer streams for collections operations
7. **Optional**: Use Optional<T> instead of nulls
8. **Annotations**: Use @Override, @Nullable, @NonNull where appropriate

## Example Full Translation

### Before (C#)

```csharp
public class PaymentProcessor
{
    private readonly IPaymentRepository _repository;

    public PaymentProcessor(IPaymentRepository repository)
        => _repository = repository;

    public async Task<PaymentResult> ProcessAsync(PaymentRequest request)
    {
        try
        {
            ValidateRequest(request);
            var existing = await _repository.GetByIdAsync(request.PaymentId);

            if (existing != null)
                throw new InvalidOperationException("Payment already exists");

            var result = new PaymentResult
            {
                Success = true,
                Amount = request.Amount
            };

            await _repository.SaveAsync(result);
            return result;
        }
        catch (Exception ex)
        {
            throw new ApplicationException("Processing failed", ex);
        }
    }
}
```

### After (Java)

```java
public class PaymentProcessor {
    private final PaymentRepository repository;

    public PaymentProcessor(PaymentRepository repository) {
        this.repository = repository;
    }

    public CompletableFuture<PaymentResult> process(PaymentRequest request) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                validateRequest(request);

                Optional<PaymentResult> existing =
                    repository.findById(request.getPaymentId());

                if (existing.isPresent()) {
                    throw new IllegalStateException("Payment already exists");
                }

                PaymentResult result = new PaymentResult()
                    .setSuccess(true)
                    .setAmount(request.getAmount());

                repository.save(result);
                return result;
            } catch (Exception ex) {
                throw new RuntimeException("Processing failed", ex);
            }
        });
    }
}
```

## Tags

#translation #csharp-to-java #code-conversion #idioms #best-practices
