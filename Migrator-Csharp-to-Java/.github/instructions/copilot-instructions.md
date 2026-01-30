# GitHub Copilot Instructions

> **Modular Instructions**: This file contains general coding standards.
> For specialized topics, see the referenced files below.

## Quick Reference

### Core Java & Patterns

- **Pure Java**: `.github/instructions/copilot-instructions-java.md` - Java 17+ features, SOLID, patterns
- **Testing**: `.github/instructions/copilot-instructions-testing.md` - AAA, @DisplayName, parameterized tests
- **Security**: `.github/instructions/copilot-instructions-security.md` - OWASP, SpotBugs, Fortify, obfuscation
- **Logging**: `.github/instructions/copilot-instructions-logging.md` - Structured logging, obfuscation, MDC

### Framework-Specific

- **Spring Boot**: `.github/instructions/copilot-instructions-spring.md` - Spring Boot 3.x, WebFlux, JPA
- **Quarkus**: `.github/instructions/copilot-instructions-quarkus.md` - Quarkus 3.x, Mutiny, Panache
- **Serverless**: `.github/instructions/copilot-instructions-serverless.md` - AWS Lambda, Azure Functions

## General Principles

- Follow **SOLID principles** and **Clean Code** practices
- Apply **Domain-Driven Design (DDD)** patterns where appropriate
- Implement **defensive programming** for banking/financial contexts
- Prioritize **performance**, **memory optimization**, and **thread safety**
- Use **immutability** by default
- Write **self-documenting code** with meaningful names
- **Framework-agnostic core**: Business logic independent of frameworks
- **Security-first**: All code must pass SpotBugs, SonarQube, Fortify, Checkmarx, and OWASP checks
- **Test-first mindset**: Write testable code with proper separation of concerns

## Java Standards

### Language Version & Features

- Use **Java 17+** features (records, sealed classes, pattern matching, text blocks)
- Prefer **modern Java APIs** over legacy alternatives
- Use `var` only when type is obvious from the right side
- Use **Optional** properly (avoid `.get()`, prefer `.orElseThrow()`)
- Leverage **Stream API** for collections processing
- Use **CompletableFuture** for async operations (framework-agnostic)

### Code Style

```java
// ✅ Good: Immutable, framework-agnostic
public record CustomerDto(String customerId, String name, BigDecimal balance) {}

public record Money(BigDecimal amount, Currency currency) {
    public Money {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Amount cannot be negative");
        }
    }
}

// ❌ Avoid: Mutable, anemic
public class CustomerDto {
    private String customerId;
    // ... getters/setters
}
```

### Naming Conventions

- **Classes**: PascalCase (`CustomerService`, `AccountRepository`)
- **Interfaces**: Descriptive names without "I" prefix (`TransactionRepository`, `PaymentGateway`)
- **Methods/Variables**: camelCase (`processTransaction`, `accountBalance`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`)
- **Packages**: lowercase, domain-driven (`com.bank.accounts.domain`, `com.bank.transactions.application`)
- **Test classes**: `*Test` suffix (`CustomerServiceTest`)
- **DTOs**: `*Dto` suffix (`TransactionDto`)
- **Entities**: No suffix (`Account`, `Customer`)
- **Value Objects**: Descriptive names (`Money`, `AccountNumber`, `Email`)

## Architecture Patterns (Framework-Agnostic)

### Dependency Injection (Framework-Agnostic)

```java
// ✅ Good: Constructor injection, framework-agnostic
public class TransactionService {
    private final TransactionRepository repository;
    private final EventPublisher eventPublisher;

    public TransactionService(TransactionRepository repository,
                            EventPublisher eventPublisher) {
        this.repository = Objects.requireNonNull(repository);
        this.eventPublisher = Objects.requireNonNull(eventPublisher);
    }
}

// ❌ Avoid: Framework-specific annotations in domain
@Inject // Avoid in domain layer
private TransactionRepository repository;
```

### Event-Driven Architecture

- Use **domain events** for business-significant occurrences
- Keep events **immutable** (use records)
- Implement **eventual consistency** where appropriate
- Apply **CQRS** for complex read/write scenarios
- Use **event sourcing** only when audit trail is critical

```java
// ✅ Good: Immutable domain event
public record TransactionCompletedEvent(
    String transactionId,
    String accountId,
    BigDecimal amount,
    Instant occurredAt
) {
    public TransactionCompletedEvent {
        Objects.requireNonNull(transactionId);
        Objects.requireNonNull(accountId);
        Objects.requireNonNull(amount);
        Objects.requireNonNull(occurredAt);
    }
}
```

## Async & Concurrency (Framework-Agnostic)

### CompletableFuture (Pure Java)

```java
// ✅ Good: Non-blocking, composable
public CompletableFuture<TransactionResult> processTransaction(TransactionRequest request) {
    return validateRequest(request)
        .thenCompose(this::executeTransaction)
        .thenCompose(this::publishEvent)
        .orTimeout(30, TimeUnit.SECONDS)
        .exceptionally(throwable -> handleTransactionError(throwable))
        .whenComplete((result, error) -> {
            if (error != null) {
                log.error("Transaction failed", error);
            }
        });
}

// ❌ Avoid: Blocking calls
public TransactionResult processTransaction(TransactionRequest request) {
    return CompletableFuture.supplyAsync(() -> execute(request))
        .join(); // ❌ Blocks the thread
}
```

### Reactive Streams (When using reactive libraries)

```java
// For Reactor (Spring WebFlux)
public Mono<TransactionResult> processTransaction(TransactionRequest request) {
    return validateRequest(request)
        .flatMap(this::executeTransaction)
        .flatMap(this::publishEvent)
        .timeout(Duration.ofSeconds(30))
        .retry(3)
        .onErrorMap(TimeoutException.class, e -> new TransactionTimeoutException(e));
}

// For Mutiny (Quarkus)
public Uni<TransactionResult> processTransaction(TransactionRequest request) {
    return validateRequest(request)
        .flatMap(this::executeTransaction)
        .flatMap(this::publishEvent)
        .ifNoItem().after(Duration.ofSeconds(30)).fail()
        .onFailure(TimeoutException.class).transform(e -> new TransactionTimeoutException(e));
}
```

### Concurrency Best Practices

- **Never block** reactive pipelines (no `.block()`, `.join()`, `.get()`)
- Use **virtual threads** (Java 21+) for high-concurrency scenarios
- Implement **thread safety** using immutability over synchronization
- Use **concurrent collections** (`ConcurrentHashMap`, `CopyOnWriteArrayList`)
- Apply **ThreadLocal** carefully (can cause memory leaks)
- Handle errors gracefully in async contexts

### Thread Safety

```java
// ✅ Good: Immutable, thread-safe
public record Account(String id, Money balance, List<Transaction> transactions) {
    public Account {
        transactions = List.copyOf(transactions); // Defensive copy
    }
}

// ✅ Good: Concurrent collection
private final ConcurrentHashMap<String, Account> accountCache = new ConcurrentHashMap<>();

// ❌ Avoid: Mutable shared state
private BigDecimal balance; // Not thread-safe
public void updateBalance(BigDecimal amount) {
    this.balance = this.balance.add(amount); // Race condition!
}
```

## REST API Design (Framework-Agnostic)

### HTTP Endpoints

```java
// ✅ Good: Clean interface definition
public interface AccountController {

    Response createAccount(CreateAccountRequest request);

    Response getAccount(String accountId);

    Response updateAccount(String accountId, UpdateAccountRequest request);

    Response deleteAccount(String accountId);
}

// Implementation example (works with JAX-RS, Spring MVC, etc.)
public class AccountControllerImpl implements AccountController {

    private final AccountService accountService;

    public AccountControllerImpl(AccountService accountService) {
        this.accountService = accountService;
    }

    @Override
    public Response createAccount(CreateAccountRequest request) {
        var account = accountService.createAccount(request);
        return Response.created(URI.create("/accounts/" + account.id()))
            .entity(account)
            .build();
    }
}
```

### HTTP Status Codes

- **200 OK**: Successful GET, PUT, PATCH
- **201 Created**: Successful POST (include Location header)
- **204 No Content**: Successful DELETE
- **400 Bad Request**: Validation errors
- **401 Unauthorized**: Missing/invalid authentication
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource doesn't exist
- **409 Conflict**: Business rule violation
- **422 Unprocessable Entity**: Business validation failure
- **500 Internal Server Error**: Unexpected errors

### Error Response Format

```java
public record ErrorResponse(
    String code,
    String message,
    Instant timestamp,
    List<FieldError> fieldErrors
) {
    public record FieldError(String field, String error) {}
}
```

## Validation (Framework-Agnostic)

### Bean Validation (JSR-380)

```java
// ✅ Good: Declarative validation
public record CreateAccountRequest(
    @NotBlank(message = "Customer ID is required")
    String customerId,

    @NotNull(message = "Initial balance is required")
    @DecimalMin(value = "0.0", message = "Balance must be positive")
    BigDecimal initialBalance,

    @NotNull
    @Valid
    Address address
) {}

public record Address(
    @NotBlank String street,
    @NotBlank String city,
    @Pattern(regexp = "\\d{5}", message = "Invalid ZIP code")
    String zipCode
) {}
```

### Custom Validators

```java
// ✅ Good: Reusable business validation
public class AccountNumberValidator {

    public void validate(String accountNumber) {
        if (accountNumber == null || accountNumber.isBlank()) {
            throw new ValidationException("Account number is required");
        }
        if (!accountNumber.matches("\\d{10}")) {
            throw new ValidationException("Account number must be 10 digits");
        }
        if (!isValidChecksum(accountNumber)) {
            throw new ValidationException("Invalid account number checksum");
        }
    }

    private boolean isValidChecksum(String accountNumber) {
        // Luhn algorithm or custom logic
        return true;
    }
}
```

### Validation at Boundaries

- Validate at **API layer** (controllers, message handlers)
- Return **clear error messages** with field-level details
- Use **domain validation** for business rules
- Fail fast with **IllegalArgumentException** in constructors

```java
// ✅ Good: Validation in value object constructor
public record Email(String value) {
    public Email {
        if (value == null || !value.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }
}
```

## Exception Handling (Framework-Agnostic)

### Custom Exceptions

```java
// ✅ Good: Specific, informative exceptions
public class AccountNotFoundException extends RuntimeException {
    private final String accountId;

    public AccountNotFoundException(String accountId) {
        super("Account not found: " + accountId);
        this.accountId = accountId;
    }

    public String getAccountId() {
        return accountId;
    }
}

public class InsufficientFundsException extends RuntimeException {
    private final BigDecimal available;
    private final BigDecimal required;

    public InsufficientFundsException(BigDecimal available, BigDecimal required) {
        super(String.format("Insufficient funds: available=%s, required=%s",
            available, required));
        this.available = available;
        this.required = required;
    }
}
```

### Error Handling Strategy

```java
// ✅ Good: Centralized error mapping
public class ErrorMapper {

    public ErrorResponse map(Exception exception) {
        return switch (exception) {
            case AccountNotFoundException e -> new ErrorResponse(
                "ACCOUNT_NOT_FOUND",
                e.getMessage(),
                Instant.now(),
                List.of()
            );
            case InsufficientFundsException e -> new ErrorResponse(
                "INSUFFICIENT_FUNDS",
                e.getMessage(),
                Instant.now(),
                List.of()
            );
            case ValidationException e -> new ErrorResponse(
                "VALIDATION_ERROR",
                e.getMessage(),
                Instant.now(),
                extractFieldErrors(e)
            );
            default -> new ErrorResponse(
                "INTERNAL_ERROR",
                "An unexpected error occurred",
                Instant.now(),
                List.of()
            );
        };
    }
}
```

## Persistence (Framework-Agnostic)

### Repository Pattern

```java
// ✅ Good: Framework-agnostic port/interface
public interface AccountRepository {

    Optional<Account> findById(String id);

    List<Account> findByCustomerId(String customerId);

    Account save(Account account);

    void deleteById(String id);

    boolean existsById(String id);
}

// Implementation can be JPA, JDBC, NoSQL, etc.
```

### Entity Design

```java
// ✅ Good: Rich domain model with behavior
public class Account {
    private final String id;
    private final String customerId;
    private Money balance;
    private final List<Transaction> transactions;
    private Long version; // For optimistic locking
    private Instant createdAt;
    private Instant updatedAt;

    public void withdraw(Money amount) {
        if (balance.isLessThan(amount)) {
            throw new InsufficientFundsException(balance.amount(), amount.amount());
        }
        this.balance = balance.subtract(amount);
        addTransaction(new Transaction(TransactionType.WITHDRAWAL, amount));
    }

    public void deposit(Money amount) {
        this.balance = balance.add(amount);
        addTransaction(new Transaction(TransactionType.DEPOSIT, amount));
    }

    private void addTransaction(Transaction transaction) {
        this.transactions.add(transaction);
    }
}

// ❌ Avoid: Anemic domain model
public class Account {
    private String id;
    private BigDecimal balance;
    // Only getters/setters, no behavior
}
```

### Value Objects

```java
// ✅ Good: Immutable value object
public record Money(BigDecimal amount, Currency currency) {
    public Money {
        Objects.requireNonNull(amount, "Amount cannot be null");
        Objects.requireNonNull(currency, "Currency cannot be null");
        if (amount.scale() > 2) {
            throw new IllegalArgumentException("Amount cannot have more than 2 decimal places");
        }
    }

    public Money add(Money other) {
        validateSameCurrency(other);
        return new Money(amount.add(other.amount), currency);
    }

    public Money subtract(Money other) {
        validateSameCurrency(other);
        return new Money(amount.subtract(other.amount), currency);
    }

    public boolean isLessThan(Money other) {
        validateSameCurrency(other);
        return amount.compareTo(other.amount) < 0;
    }

    private void validateSameCurrency(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException("Cannot operate on different currencies");
        }
    }
}
```

### Optimistic Locking

```java
// ✅ Good: Handle concurrent updates
public interface AccountRepository {

    Account save(Account account) throws OptimisticLockException;
}

// Service layer handling
public void updateBalance(String accountId, BigDecimal amount) {
    int maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
        try {
            var account = repository.findById(accountId)
                .orElseThrow(() -> new AccountNotFoundException(accountId));

            account.updateBalance(amount);
            repository.save(account);
            return;
        } catch (OptimisticLockException e) {
            if (i == maxRetries - 1) throw e;
            // Retry with exponential backoff
            Thread.sleep((long) Math.pow(2, i) * 100);
        }
    }
}
```

### Database Best Practices

- Use **UUIDs** for distributed systems
- Implement **soft deletes** where audit is required
- Use **optimistic locking** for concurrent updates
- Add **audit fields** (createdAt, updatedAt, createdBy, updatedBy)
- Define **database constraints** (NOT NULL, CHECK, UNIQUE, FK)
- Use **pagination** for large result sets
- Implement **caching** strategically

## Security (Banking Context - Framework-Agnostic)

### Authentication & Authorization

```java
// ✅ Good: Framework-agnostic security context
public interface SecurityContext {
    String getCurrentUserId();
    Set<String> getCurrentUserRoles();
    boolean hasRole(String role);
    boolean hasPermission(String permission);
}

// Usage in service
public class TransactionService {
    private final SecurityContext securityContext;

    public Transaction processTransaction(TransactionRequest request) {
        requirePermission("TRANSACTION_CREATE");

        var userId = securityContext.getCurrentUserId();
        // Process with audit
    }

    private void requirePermission(String permission) {
        if (!securityContext.hasPermission(permission)) {
            throw new ForbiddenException("Insufficient permissions");
        }
    }
}
```

### Sensitive Data Handling

```java
// ✅ Good: Masking sensitive data
public record AccountDto(
    String accountId,
    String customerId,
    @JsonIgnore String accountNumber,  // Never serialize
    BigDecimal balance
) {
    public String getMaskedAccountNumber() {
        return maskAccountNumber(accountNumber);
    }

    private static String maskAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.length() < 4) {
            return "****";
        }
        return "******" + accountNumber.substring(accountNumber.length() - 4);
    }
}

// ✅ Good: Secure logging
public class SecureLogger {

    public void logAccountAccess(String accountNumber, String action) {
        log.info("Account access: account={}, action={}",
            maskAccountNumber(accountNumber),
            action);
    }

    private String maskAccountNumber(String accountNumber) {
        return "****" + accountNumber.substring(accountNumber.length() - 4);
    }
}

// ❌ Avoid: Logging sensitive data
log.info("Processing account: {}", accountNumber); // ❌ PII in logs
```

### Input Validation & Sanitization

```java
// ✅ Good: Sanitize and validate input
public class InputSanitizer {

    public String sanitizeAccountId(String input) {
        if (input == null) {
            throw new IllegalArgumentException("Account ID cannot be null");
        }

        // Remove any non-alphanumeric characters
        String sanitized = input.replaceAll("[^a-zA-Z0-9-]", "");

        if (!sanitized.matches("^[A-Z0-9]{8,20}$")) {
            throw new IllegalArgumentException("Invalid account ID format");
        }

        return sanitized;
    }

    public BigDecimal sanitizeAmount(String input) {
        try {
            BigDecimal amount = new BigDecimal(input);
            if (amount.scale() > 2) {
                amount = amount.setScale(2, RoundingMode.HALF_UP);
            }
            return amount;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid amount format", e);
        }
    }
}
```

### Data Encryption

```java
// ✅ Good: Encrypt sensitive data at rest
public interface EncryptionService {
    String encrypt(String plaintext);
    String decrypt(String ciphertext);
}

public class AccountService {
    private final EncryptionService encryptionService;

    public void storeAccountDetails(Account account) {
        String encryptedPin = encryptionService.encrypt(account.getPin());
        // Store encrypted PIN
    }
}
```

### Security Best Practices

- Use **OAuth 2.0 / OpenID Connect** for authentication
- Implement **JWT validation** properly (signature, expiration, issuer)
- Apply **least privilege principle**
- **Encrypt** sensitive data at rest (PINs, card numbers)
- Use **HTTPS** for all communications
- Implement **rate limiting** to prevent abuse
- Apply **input sanitization** to prevent injection attacks
- **Never log PII** (Personally Identifiable Information)
- Use **secure random** for generating tokens/IDs
- Implement **session timeout** and **idle timeout**
- Validate **CORS** origins carefully

> **Note**: For detailed security guidelines, see `.github/copilot-instructions-security.md`
> For logging standards, see `.github/copilot-instructions-logging.md`
> For testing standards, see `.github/copilot-instructions-testing.md`

## Cloud Best Practices (Multi-Cloud)

### Message Queues / Event Streaming

```java
// ✅ Good: Abstract messaging interface
public interface MessagePublisher {
    void publish(String topic, Object message);
    void publishWithDelay(String topic, Object message, Duration delay);
}

public interface MessageConsumer {
    void subscribe(String topic, MessageHandler handler);
}

// Implementation can be Azure Service Bus, AWS SQS, Kafka, RabbitMQ, etc.
```

### Message Processing Best Practices

- Implement **idempotency** (process messages safely multiple times)
- Use **dead letter queues** for failed messages
- Set appropriate **message TTL** (time-to-live)
- Implement **retry policies** with exponential backoff
- Use **transactions** for exactly-once processing when needed
- Handle **poison messages** gracefully

```java
// ✅ Good: Idempotent message handler
public class TransactionMessageHandler implements MessageHandler {

    private final TransactionRepository repository;
    private final Set<String> processedMessageIds = ConcurrentHashMap.newKeySet();

    @Override
    public void handle(Message message) {
        String messageId = message.getId();

        // Idempotency check
        if (processedMessageIds.contains(messageId)) {
            log.info("Message already processed, skipping: messageId={}", messageId);
            return;
        }

        try {
            processTransaction(message.getBody());
            processedMessageIds.add(messageId);
            message.acknowledge();
        } catch (Exception e) {
            log.error("Failed to process message: messageId={}", messageId, e);
            message.reject();
        }
    }
}
```

### Configuration Management

```java
// ✅ Good: Externalized configuration
public interface ConfigurationProvider {
    String getString(String key);
    String getString(String key, String defaultValue);
    int getInt(String key);
    boolean getBoolean(String key);
    Duration getDuration(String key);
}

// Usage
public class TransactionService {
    private final Duration timeout;
    private final int maxRetries;

    public TransactionService(ConfigurationProvider config) {
        this.timeout = config.getDuration("transaction.timeout");
        this.maxRetries = config.getInt("transaction.max-retries");
    }
}
```

### Secrets Management

```java
// ✅ Good: Abstract secrets retrieval
public interface SecretProvider {
    String getSecret(String secretName);
    void refreshSecrets();
}

// Implementation can be Azure Key Vault, AWS Secrets Manager, HashiCorp Vault, etc.
public class DatabaseConnectionFactory {

    private final SecretProvider secretProvider;

    public DataSource createDataSource() {
        String password = secretProvider.getSecret("database-password");
        // Create connection with secret
    }
}
```

### Resilience Patterns

```java
// ✅ Good: Circuit breaker pattern
public class ResilientServiceClient {

    private final CircuitBreaker circuitBreaker;
    private final Retry retry;

    public CompletableFuture<Response> callService(Request request) {
        return retry.executeSupplier(() ->
            circuitBreaker.executeSupplier(() ->
                doCallService(request)
            )
        );
    }

    private Response doCallService(Request request) {
        // Actual service call
    }
}

// Library-agnostic: can use Resilience4j, Failsafe, etc.
```

### Distributed Tracing

```java
// ✅ Good: Propagate trace context
public class TracingFilter {

    public void filter(Request request) {
        String traceId = request.getHeader("X-Trace-ID");
        if (traceId == null) {
            traceId = UUID.randomUUID().toString();
        }

        String spanId = UUID.randomUUID().toString();

        // Set in MDC for logging
        MDC.put("traceId", traceId);
        MDC.put("spanId", spanId);

        // Propagate to downstream services
        request.setHeader("X-Trace-ID", traceId);
        request.setHeader("X-Span-ID", spanId);
    }
}
```

## Performance & Optimization

### Memory Management

```java
// ✅ Good: Use try-with-resources for auto-cleanup
public List<Transaction> readTransactions(String filePath) {
    try (var reader = new BufferedReader(new FileReader(filePath))) {
        return reader.lines()
            .map(this::parseTransaction)
            .collect(Collectors.toList());
    } catch (IOException e) {
        throw new RuntimeException("Failed to read transactions", e);
    }
}

// ✅ Good: Use weak references for caches
public class AccountCache {
    private final Map<String, WeakReference<Account>> cache = new ConcurrentHashMap<>();

    public Optional<Account> get(String accountId) {
        WeakReference<Account> ref = cache.get(accountId);
        return ref != null ? Optional.ofNullable(ref.get()) : Optional.empty();
    }

    public void put(String accountId, Account account) {
        cache.put(accountId, new WeakReference<>(account));
    }
}

// ❌ Avoid: Memory leaks
public class LeakyCache {
    private final Map<String, Account> cache = new HashMap<>(); // Never clears!

    public void put(String key, Account value) {
        cache.put(key, value); // Will grow indefinitely
    }
}
```

### Efficient Collections

```java
// ✅ Good: Right collection for the job
List<String> accountIds = new ArrayList<>();           // Fast random access
Set<String> uniqueCustomers = new HashSet<>();         // Fast lookups, no duplicates
Map<String, Account> accountMap = new HashMap<>();     // Fast key-based access
Queue<Transaction> pending = new LinkedList<>();       // FIFO operations

// For concurrent access
Map<String, Account> cache = new ConcurrentHashMap<>();
List<String> syncList = Collections.synchronizedList(new ArrayList<>());
Set<String> syncSet = ConcurrentHashMap.newKeySet();

// ✅ Good: Initialize with capacity when size is known
List<String> ids = new ArrayList<>(1000);              // Avoid resizing
Map<String, String> map = new HashMap<>(1000);         // Avoid rehashing

// ❌ Avoid: Wrong collection type
List<String> uniqueIds = new ArrayList<>();            // Use Set instead
uniqueIds.contains(id);                                 // O(n) instead of O(1)
```

### Stream API Performance

```java
// ✅ Good: Use parallel streams for CPU-intensive operations on large datasets
List<Transaction> results = transactions.parallelStream()
    .filter(t -> t.amount().compareTo(BigDecimal.valueOf(1000)) > 0)
    .map(this::enrichTransaction)
    .collect(Collectors.toList());

// ❌ Avoid: Parallel streams for small datasets or I/O operations
List<Account> accounts = smallList.parallelStream()    // Overhead > benefit
    .map(repository::findById)                         // I/O bound!
    .collect(Collectors.toList());

// ✅ Good: Short-circuit operations
Optional<Transaction> first = transactions.stream()
    .filter(t -> t.status() == Status.PENDING)
    .findFirst();                                      // Stops at first match

// ✅ Good: Use primitive streams to avoid boxing
int sum = IntStream.range(0, 1000)
    .filter(n -> n % 2 == 0)
    .sum();                                            // No boxing overhead
```

### Database Query Optimization

```java
// ✅ Good: Fetch only what you need
public List<AccountSummary> getAccountSummaries(String customerId) {
    return repository.findAccountSummaries(customerId); // Projection, not full entity
}

// ✅ Good: Use batch operations
public void updateBalances(List<AccountUpdate> updates) {
    repository.batchUpdate(updates);                   // Single DB round-trip
}

// ✅ Good: Implement pagination for large result sets
public Page<Transaction> getTransactions(String accountId, int page, int size) {
    return repository.findByAccountId(accountId, PageRequest.of(page, size));
}

// ❌ Avoid: N+1 query problem
public List<Account> getAccountsWithTransactions(List<String> accountIds) {
    return accountIds.stream()
        .map(id -> {
            Account account = repository.findById(id);
            account.setTransactions(transactionRepo.findByAccountId(id)); // ❌ N queries!
            return account;
        })
        .collect(Collectors.toList());
}

// ✅ Good: Fetch associations in one query
public List<Account> getAccountsWithTransactions(List<String> accountIds) {
    return repository.findByIdWithTransactions(accountIds); // Single query with JOIN
}
```

### Caching Strategies

```java
// ✅ Good: Cache expensive computations
public class AccountBalanceService {

    private final LoadingCache<String, BigDecimal> balanceCache = Caffeine.newBuilder()
        .maximumSize(10_000)
        .expireAfterWrite(5, TimeUnit.MINUTES)
        .build(this::calculateBalance);

    public BigDecimal getBalance(String accountId) {
        return balanceCache.get(accountId);
    }

    private BigDecimal calculateBalance(String accountId) {
        // Expensive calculation
    }

    public void invalidateCache(String accountId) {
        balanceCache.invalidate(accountId);
    }
}

// Cache invalidation strategies:
// - Time-based: expireAfterWrite, expireAfterAccess
// - Size-based: maximumSize, maximumWeight
// - Manual: invalidate on updates
```

### Async Processing

```java
// ✅ Good: Process independently, aggregate results
public CompletableFuture<AccountDetails> getAccountDetails(String accountId) {
    CompletableFuture<Account> accountFuture =
        CompletableFuture.supplyAsync(() -> accountRepo.findById(accountId));

    CompletableFuture<List<Transaction>> transactionsFuture =
        CompletableFuture.supplyAsync(() -> transactionRepo.findByAccountId(accountId));

    CompletableFuture<CustomerInfo> customerFuture =
        CompletableFuture.supplyAsync(() -> customerService.getInfo(accountId));

    return CompletableFuture.allOf(accountFuture, transactionsFuture, customerFuture)
        .thenApply(v -> new AccountDetails(
            accountFuture.join(),
            transactionsFuture.join(),
            customerFuture.join()
        ));
}
```

### String Operations

```java
// ✅ Good: Use StringBuilder for concatenation in loops
StringBuilder sb = new StringBuilder();
for (Transaction t : transactions) {
    sb.append(t.id()).append(",");
}
String result = sb.toString();

// ❌ Avoid: String concatenation in loops
String result = "";
for (Transaction t : transactions) {
    result += t.id() + ",";                            // Creates new String each iteration!
}

// ✅ Good: Use String.format or text blocks for readability
String query = """
    SELECT * FROM accounts
    WHERE customer_id = ?
    AND balance > ?
    """;
```

### JVM Monitoring

- Monitor **heap usage** (young gen, old gen)
- Watch **GC frequency and duration**
- Track **thread count** and thread states
- Monitor **CPU usage** per thread
- Profile with tools: **JProfiler**, **YourKit**, **VisualVM**
- Use **JMX** for runtime metrics
- Enable **GC logging** for analysis

## Git Commit Messages

```
feat(accounts): add account creation endpoint
fix(transactions): resolve race condition in balance update
refactor(domain): extract value object for Money
test(transactions): add edge cases for concurrent updates
docs(readme): update API documentation
perf(queries): optimize account lookup query
chore(deps): update dependencies to latest versions
```

### Format

- Use **conventional commits** format
- Keep first line **under 50 characters**
- Use **imperative mood** ("add" not "added")
- Reference **ticket numbers** where applicable (e.g., "feat(auth): add OAuth support [JIRA-123]")
- Add body for complex changes (separated by blank line)

## Modern Java Features (Java 17+)

### Records

```java
// ✅ Good: Use records for immutable DTOs and value objects
public record Money(BigDecimal amount, Currency currency) {
    // Compact constructor for validation
    public Money {
        Objects.requireNonNull(amount);
        Objects.requireNonNull(currency);
        if (amount.scale() > 2) {
            throw new IllegalArgumentException("Max 2 decimal places");
        }
    }

    // Custom methods
    public Money add(Money other) {
        validateSameCurrency(other);
        return new Money(amount.add(other.amount), currency);
    }
}

// ❌ Avoid: Mutable data classes
public class Money {
    private BigDecimal amount;
    public void setAmount(BigDecimal amount) { ... }
}
```

### Sealed Classes

```java
// ✅ Good: Restricted class hierarchies
public sealed interface PaymentMethod
    permits CreditCard, DebitCard, BankTransfer {
}

public final class CreditCard implements PaymentMethod {
    private final String cardNumber;
    private final String cvv;
}

public final class DebitCard implements PaymentMethod {
    private final String cardNumber;
    private final String pin;
}

public non-sealed class BankTransfer implements PaymentMethod {
    // Can be extended
}

// Exhaustive pattern matching
public BigDecimal calculateFee(PaymentMethod method) {
    return switch (method) {
        case CreditCard card -> BigDecimal.valueOf(2.5);
        case DebitCard card -> BigDecimal.valueOf(1.0);
        case BankTransfer transfer -> BigDecimal.ZERO;
        // No default needed - compiler ensures exhaustiveness!
    };
}
```

### Pattern Matching

```java
// ✅ Good: Pattern matching for instanceof
public String formatAccount(Object obj) {
    if (obj instanceof Account account && account.isActive()) {
        return "Active account: " + account.getId();
    } else if (obj instanceof String id) {
        return "Account ID: " + id;
    }
    return "Unknown";
}

// ✅ Good: Switch expressions with patterns
public BigDecimal calculateDiscount(Customer customer) {
    return switch (customer) {
        case PremiumCustomer p when p.yearsOfMembership() > 5
            -> BigDecimal.valueOf(0.15);
        case PremiumCustomer p
            -> BigDecimal.valueOf(0.10);
        case RegularCustomer r when r.totalPurchases() > 10000
            -> BigDecimal.valueOf(0.05);
        case RegularCustomer r
            -> BigDecimal.ZERO;
        default
            -> BigDecimal.ZERO;
    };
}
```

### Text Blocks

```java
// ✅ Good: Multi-line strings with text blocks
String json = """
    {
        "accountId": "%s",
        "balance": %s,
        "currency": "%s"
    }
    """.formatted(accountId, balance, currency);

String sql = """
    SELECT a.*, c.name
    FROM accounts a
    JOIN customers c ON a.customer_id = c.id
    WHERE a.balance > ?
    AND a.status = 'ACTIVE'
    """;
```

### Virtual Threads (Java 21+)

```java
// ✅ Good: Handle massive concurrency with virtual threads
public void processTransactions(List<Transaction> transactions) {
    try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
        transactions.forEach(transaction ->
            executor.submit(() -> processTransaction(transaction))
        );
    }
}

// Perfect for I/O-bound operations with high concurrency
```

## Functional Programming Patterns

### Optional Usage

```java
// ✅ Good: Proper Optional usage
public Optional<Account> findAccount(String id) {
    return Optional.ofNullable(repository.findById(id));
}

// ✅ Good: Transform with map/flatMap
public Optional<BigDecimal> getAccountBalance(String id) {
    return findAccount(id)
        .map(Account::getBalance)
        .map(Money::amount);
}

// ✅ Good: Handle absence
account.ifPresentOrElse(
    acc -> log.info("Found account: {}", acc.getId()),
    () -> log.warn("Account not found")
);

// ❌ Avoid: Misusing Optional
public Optional<Account> createAccount() {
    return Optional.of(new Account()); // ❌ Never Optional for creation
}

account.get(); // ❌ Defeats the purpose
if (account.isPresent()) { // ❌ Use ifPresent or orElse
    account.get().doSomething();
}
```

### Immutability

```java
// ✅ Good: Immutable collections
List<Transaction> transactions = List.of(t1, t2, t3);
Set<String> accountIds = Set.of("ACC1", "ACC2");
Map<String, Account> accounts = Map.of(
    "ACC1", account1,
    "ACC2", account2
);

// ✅ Good: Defensive copies
public class Account {
    private final List<Transaction> transactions;

    public Account(List<Transaction> transactions) {
        this.transactions = List.copyOf(transactions); // Immutable copy
    }

    public List<Transaction> getTransactions() {
        return transactions; // Already immutable
    }
}

// ❌ Avoid: Exposing mutable state
public List<Transaction> getTransactions() {
    return transactions; // ❌ If transactions is ArrayList
}
```

### Function Composition

```java
// ✅ Good: Compose functions for reusability
Function<Transaction, BigDecimal> extractAmount = Transaction::getAmount;
Function<BigDecimal, BigDecimal> addTax = amount -> amount.multiply(BigDecimal.valueOf(1.1));
Function<BigDecimal, String> formatCurrency = amount -> "$" + amount;

Function<Transaction, String> formatTransactionWithTax =
    extractAmount.andThen(addTax).andThen(formatCurrency);

String result = formatTransactionWithTax.apply(transaction);

// ✅ Good: Predicates composition
Predicate<Transaction> isLarge = t -> t.getAmount().compareTo(BigDecimal.valueOf(1000)) > 0;
Predicate<Transaction> isPending = t -> t.getStatus() == Status.PENDING;
Predicate<Transaction> isLargeAndPending = isLarge.and(isPending);

List<Transaction> filtered = transactions.stream()
    .filter(isLargeAndPending)
    .collect(Collectors.toList());
```

## Code Review Checklist

- [ ] Follows SOLID principles
- [ ] No blocking operations in reactive code
- [ ] Proper error handling
- [ ] Sensitive data properly secured
- [ ] Tests added/updated
- [ ] Logs are meaningful and secure
- [ ] Performance considerations addressed
- [ ] Documentation updated
- [ ] No code smells (long methods, god classes, etc.)

## Common Anti-Patterns to Avoid

❌ **God Classes** - Classes with too many responsibilities
❌ **Anemic Domain Model** - Domain objects with no behavior
❌ **Primitive Obsession** - Using primitives instead of value objects
❌ **Magic Numbers** - Hardcoded values without constants
❌ **Exception Swallowing** - Empty catch blocks
❌ **Premature Optimization** - Optimizing before measuring
❌ **Copy-Paste Programming** - Duplicated code
❌ **Shotgun Surgery** - One change requires many small changes

## Banking-Specific Requirements

### Transaction Handling

- Use **database transactions** with proper isolation levels
- Implement **idempotency** for all state-changing operations
- Add **audit trails** for all financial operations
- Use **BigDecimal** for monetary calculations (NEVER float/double)

### Compliance

- Implement **data retention policies**
- Add **audit logging** for all access to sensitive data
- Support **GDPR** requirements (right to be forgotten)
- Maintain **regulatory compliance** (PCI-DSS, SOX, etc.)

---

**Remember**: Code is read more often than it's written. Optimize for readability and maintainability! 🚀
