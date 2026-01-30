# GitHub Copilot Instructions - Pure Java

> **Pure Java**: These instructions apply to ALL Java code regardless of framework.
> Use alongside framework-specific instructions when applicable.

## Java Language Standards

### Version Requirements
- **Minimum**: Java 17 (LTS)
- **Preferred**: Java 21+ (for virtual threads and modern features)
- **Never**: Java 8 or earlier in new code

### Language Features (Java 17+)

#### Records (Immutable Data)
```java
// ✅ PERFECT: Use records for immutable DTOs and value objects
public record Money(BigDecimal amount, Currency currency) {
    // Compact constructor for validation
    public Money {
        Objects.requireNonNull(amount, "Amount cannot be null");
        Objects.requireNonNull(currency, "Currency cannot be null");
        if (amount.scale() > 2) {
            throw new IllegalArgumentException("Amount cannot have more than 2 decimal places");
        }
    }
    
    // Custom methods
    public Money add(Money other) {
        validateSameCurrency(other);
        return new Money(amount.add(other.amount), currency);
    }
    
    public Money subtract(Money other) {
        validateSameCurrency(other);
        return new Money(amount.subtract(other.amount), currency);
    }
    
    public boolean isGreaterThan(Money other) {
        validateSameCurrency(other);
        return amount.compareTo(other.amount) > 0;
    }
    
    private void validateSameCurrency(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException(
                String.format("Cannot operate on different currencies: %s vs %s", 
                    currency.getCurrencyCode(), 
                    other.currency.getCurrencyCode())
            );
        }
    }
}

// ❌ AVOID: Mutable classes for data
public class Money {
    private BigDecimal amount;
    public void setAmount(BigDecimal amount) { ... } // ❌ Mutable!
}
```

#### Sealed Classes (Restricted Hierarchies)
```java
// ✅ PERFECT: Sealed classes for exhaustive pattern matching
public sealed interface PaymentMethod 
    permits CreditCard, DebitCard, BankTransfer, DigitalWallet {
}

public final record CreditCard(String number, String cvv, YearMonth expiry) 
    implements PaymentMethod {
    public CreditCard {
        Objects.requireNonNull(number);
        Objects.requireNonNull(cvv);
        Objects.requireNonNull(expiry);
    }
}

public final record DebitCard(String number, String pin) 
    implements PaymentMethod {
    public DebitCard {
        Objects.requireNonNull(number);
        Objects.requireNonNull(pin);
    }
}

public final record BankTransfer(String accountNumber, String routingNumber) 
    implements PaymentMethod {
}

public non-sealed class DigitalWallet implements PaymentMethod {
    // Can be extended by third-party integrations
}

// ✅ PERFECT: Exhaustive pattern matching
public BigDecimal calculateFee(PaymentMethod method) {
    return switch (method) {
        case CreditCard cc -> BigDecimal.valueOf(2.5);
        case DebitCard dc -> BigDecimal.valueOf(1.0);
        case BankTransfer bt -> BigDecimal.ZERO;
        case DigitalWallet dw -> BigDecimal.valueOf(0.5);
        // No default needed - compiler ensures exhaustiveness!
    };
}
```

#### Pattern Matching for instanceof
```java
// ✅ PERFECT: Pattern matching with guards
public String formatTransaction(Object obj) {
    return switch (obj) {
        case Transaction t when t.amount().compareTo(BigDecimal.valueOf(10000)) > 0 ->
            "Large transaction: " + t.id();
        case Transaction t ->
            "Regular transaction: " + t.id();
        case String id ->
            "Transaction ID: " + id;
        case null ->
            "No transaction";
        default ->
            "Unknown type";
    };
}

// ✅ PERFECT: instanceof with pattern variable
public void processAccount(Object obj) {
    if (obj instanceof Account account && account.isActive()) {
        log.info("Processing active account: {}", account.getId());
    } else if (obj instanceof String accountId) {
        Account account = repository.findById(accountId);
        processAccount(account);
    }
}
```

#### Text Blocks
```java
// ✅ PERFECT: Multi-line strings
String json = """
    {
        "transactionId": "%s",
        "accountId": "%s",
        "amount": %s,
        "currency": "%s",
        "timestamp": "%s"
    }
    """.formatted(
        transaction.id(),
        transaction.accountId(),
        transaction.amount(),
        transaction.currency(),
        transaction.timestamp()
    );

String sql = """
    SELECT 
        a.account_id,
        a.balance,
        c.customer_name,
        c.email
    FROM accounts a
    INNER JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.status = ?
      AND a.balance > ?
    ORDER BY a.created_at DESC
    """;

// ❌ AVOID: String concatenation
String sql = "SELECT a.account_id, a.balance " +
             "FROM accounts a " +
             "WHERE a.status = ?"; // ❌ Hard to read
```

#### Virtual Threads (Java 21+)
```java
// ✅ PERFECT: Virtual threads for high-concurrency I/O
public class TransactionProcessor {
    
    public void processTransactionsBatch(List<Transaction> transactions) {
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            List<Future<TransactionResult>> futures = transactions.stream()
                .map(transaction -> executor.submit(() -> processTransaction(transaction)))
                .toList();
            
            // Wait for all to complete
            for (Future<TransactionResult> future : futures) {
                try {
                    TransactionResult result = future.get();
                    log.info("Transaction processed: {}", result.id());
                } catch (ExecutionException e) {
                    log.error("Transaction failed", e.getCause());
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Processing interrupted", e);
        }
    }
}

// Perfect for: REST API calls, database queries, file I/O
// NOT for: CPU-intensive computations
```

## Naming Conventions

### Classes and Interfaces
```java
// ✅ GOOD: Descriptive, PascalCase
public class TransactionService { }
public class AccountRepository { }
public interface PaymentGateway { }
public record CustomerDto(...) { }
public class InsufficientFundsException extends RuntimeException { }

// ❌ BAD: Generic, unclear
public class Manager { }
public class Helper { }
public class Util { }
public interface IRepository { } // No "I" prefix!
```

### Methods and Variables
```java
// ✅ GOOD: Verb-based, camelCase, descriptive
public void processTransaction(Transaction transaction) { }
public Account findAccountById(String accountId) { }
public boolean isAccountActive(Account account) { }
private BigDecimal calculateTotalBalance(List<Account> accounts) { }

private final AccountRepository accountRepository;
private final BigDecimal dailyLimit;
private String transactionId;

// ❌ BAD: Unclear, abbreviated
public void proc(Transaction t) { } // ❌ Abbreviated
public Account get(String id) { } // ❌ Too generic
private boolean flag; // ❌ Meaningless name
private BigDecimal amt; // ❌ Abbreviated
```

### Constants
```java
// ✅ GOOD: UPPER_SNAKE_CASE, descriptive
public static final int MAX_RETRY_ATTEMPTS = 3;
public static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(30);
public static final BigDecimal MINIMUM_BALANCE = new BigDecimal("100.00");
private static final String DATE_PATTERN = "yyyy-MM-dd";

// ❌ BAD
public static final int MAX = 3; // ❌ Not descriptive enough
private static final String PATTERN = "yyyy-MM-dd"; // ❌ Too generic
```

### Packages
```java
// ✅ GOOD: Domain-driven, lowercase
com.bank.accounts.domain
com.bank.accounts.application
com.bank.accounts.infrastructure
com.bank.transactions.domain
com.bank.payments.domain

// ❌ BAD: Technical, not domain-driven
com.bank.utils
com.bank.helpers
com.bank.services
```

## SOLID Principles

### Single Responsibility Principle (SRP)
```java
// ✅ GOOD: Each class has one reason to change
public class TransactionValidator {
    public ValidationResult validate(Transaction transaction) {
        // Only validates transactions
    }
}

public class TransactionProcessor {
    public TransactionResult process(Transaction transaction) {
        // Only processes transactions
    }
}

public class TransactionNotifier {
    public void notifySuccess(Transaction transaction) {
        // Only sends notifications
    }
}

// ❌ BAD: God class with multiple responsibilities
public class TransactionManager {
    public ValidationResult validate(Transaction t) { }
    public TransactionResult process(Transaction t) { }
    public void sendNotification(Transaction t) { }
    public void saveToDatabase(Transaction t) { }
    public void generateReport(Transaction t) { }
    // ❌ Too many responsibilities!
}
```

### Open/Closed Principle (OCP)
```java
// ✅ GOOD: Open for extension, closed for modification
public interface FeeCalculator {
    BigDecimal calculate(Transaction transaction);
}

public class StandardFeeCalculator implements FeeCalculator {
    public BigDecimal calculate(Transaction transaction) {
        return transaction.amount().multiply(new BigDecimal("0.025"));
    }
}

public class PremiumFeeCalculator implements FeeCalculator {
    public BigDecimal calculate(Transaction transaction) {
        return transaction.amount().multiply(new BigDecimal("0.01"));
    }
}

// Easy to add new calculators without modifying existing code
public class WholesaleFeeCalculator implements FeeCalculator {
    public BigDecimal calculate(Transaction transaction) {
        return transaction.amount().multiply(new BigDecimal("0.005"));
    }
}

// ❌ BAD: Requires modification to add new behavior
public class FeeCalculator {
    public BigDecimal calculate(Transaction t, String type) {
        if (type.equals("STANDARD")) {
            return t.amount().multiply(new BigDecimal("0.025"));
        } else if (type.equals("PREMIUM")) {
            return t.amount().multiply(new BigDecimal("0.01"));
        }
        // ❌ Need to modify this method to add new types
    }
}
```

### Liskov Substitution Principle (LSP)
```java
// ✅ GOOD: Subtypes can replace base types
public interface Account {
    Money getBalance();
    void deposit(Money amount);
}

public class SavingsAccount implements Account {
    public Money getBalance() { /* implementation */ }
    
    public void deposit(Money amount) {
        // Accepts any positive amount
        if (amount.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        // Process deposit
    }
}

public class CheckingAccount implements Account {
    public Money getBalance() { /* implementation */ }
    
    public void deposit(Money amount) {
        // Same contract as interface
        if (amount.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        // Process deposit
    }
}

// ❌ BAD: Subtype violates contract
public class RestrictedAccount implements Account {
    public void deposit(Money amount) {
        // ❌ Adds unexpected restriction
        if (amount.amount().compareTo(new BigDecimal("1000")) > 0) {
            throw new IllegalArgumentException("Cannot deposit more than 1000");
        }
    }
}
```

### Interface Segregation Principle (ISP)
```java
// ✅ GOOD: Specific interfaces
public interface Readable {
    Account read(String id);
}

public interface Writable {
    void write(Account account);
}

public interface Deletable {
    void delete(String id);
}

public class AccountRepository implements Readable, Writable, Deletable {
    // Implements all operations
}

public class ReadOnlyAccountRepository implements Readable {
    // Only implements read operations
}

// ❌ BAD: Fat interface
public interface Repository {
    Account read(String id);
    void write(Account account);
    void delete(String id);
    void backup();
    void restore();
    void migrate();
    // ❌ Forces all implementations to implement all methods
}
```

### Dependency Inversion Principle (DIP)
```java
// ✅ GOOD: Depend on abstractions
public class TransactionService {
    private final TransactionRepository repository;
    private final EventPublisher eventPublisher;
    
    public TransactionService(
            TransactionRepository repository,  // Interface
            EventPublisher eventPublisher) {   // Interface
        this.repository = Objects.requireNonNull(repository);
        this.eventPublisher = Objects.requireNonNull(eventPublisher);
    }
}

// ❌ BAD: Depend on concrete classes
public class TransactionService {
    private final JdbcTransactionRepository repository; // ❌ Concrete class
    private final KafkaEventPublisher eventPublisher;   // ❌ Concrete class
    
    public TransactionService() {
        this.repository = new JdbcTransactionRepository(); // ❌ Hard dependency
        this.eventPublisher = new KafkaEventPublisher();   // ❌ Hard dependency
    }
}
```

## Value Objects Pattern

```java
// ✅ PERFECT: Value objects with behavior
public record AccountNumber(String value) {
    public AccountNumber {
        Objects.requireNonNull(value, "Account number cannot be null");
        if (!value.matches("\\d{10}")) {
            throw new IllegalArgumentException("Account number must be 10 digits");
        }
        if (!isValidChecksum(value)) {
            throw new IllegalArgumentException("Invalid account number checksum");
        }
    }
    
    private static boolean isValidChecksum(String accountNumber) {
        // Luhn algorithm or custom validation
        return true;
    }
    
    public String masked() {
        return "******" + value.substring(6);
    }
}

public record Email(String value) {
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    
    public Email {
        Objects.requireNonNull(value, "Email cannot be null");
        if (!value.matches(EMAIL_REGEX)) {
            throw new IllegalArgumentException("Invalid email format: " + value);
        }
    }
    
    public String domain() {
        return value.substring(value.indexOf('@') + 1);
    }
}

public record PhoneNumber(String value) {
    public PhoneNumber {
        Objects.requireNonNull(value, "Phone number cannot be null");
        String cleaned = value.replaceAll("[^0-9]", "");
        if (cleaned.length() < 10 || cleaned.length() > 15) {
            throw new IllegalArgumentException("Invalid phone number length");
        }
    }
    
    public String formatted() {
        String cleaned = value.replaceAll("[^0-9]", "");
        if (cleaned.length() == 10) {
            return String.format("(%s) %s-%s",
                cleaned.substring(0, 3),
                cleaned.substring(3, 6),
                cleaned.substring(6));
        }
        return value;
    }
}
```

## Domain Entities

```java
// ✅ PERFECT: Rich domain model with behavior
public class Account {
    private final String id;
    private final String customerId;
    private Money balance;
    private AccountStatus status;
    private final List<Transaction> transactions;
    private Long version; // Optimistic locking
    private final Instant createdAt;
    private Instant updatedAt;
    
    public Account(String id, String customerId, Money initialBalance) {
        this.id = Objects.requireNonNull(id);
        this.customerId = Objects.requireNonNull(customerId);
        this.balance = Objects.requireNonNull(initialBalance);
        this.status = AccountStatus.ACTIVE;
        this.transactions = new ArrayList<>();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }
    
    // Business logic in the entity
    public void deposit(Money amount) {
        validateIsActive();
        validatePositiveAmount(amount);
        
        this.balance = balance.add(amount);
        addTransaction(new Transaction(TransactionType.DEPOSIT, amount));
        this.updatedAt = Instant.now();
    }
    
    public void withdraw(Money amount) {
        validateIsActive();
        validatePositiveAmount(amount);
        validateSufficientFunds(amount);
        
        this.balance = balance.subtract(amount);
        addTransaction(new Transaction(TransactionType.WITHDRAWAL, amount));
        this.updatedAt = Instant.now();
    }
    
    public void close() {
        if (!balance.amount().equals(BigDecimal.ZERO)) {
            throw new IllegalStateException("Cannot close account with non-zero balance");
        }
        this.status = AccountStatus.CLOSED;
        this.updatedAt = Instant.now();
    }
    
    public boolean isActive() {
        return status == AccountStatus.ACTIVE;
    }
    
    private void validateIsActive() {
        if (!isActive()) {
            throw new IllegalStateException("Account is not active");
        }
    }
    
    private void validatePositiveAmount(Money amount) {
        if (amount.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
    }
    
    private void validateSufficientFunds(Money amount) {
        if (balance.isLessThan(amount)) {
            throw new InsufficientFundsException(balance, amount);
        }
    }
    
    private void addTransaction(Transaction transaction) {
        this.transactions.add(transaction);
    }
    
    // Getters (no setters - encapsulation!)
    public String getId() { return id; }
    public String getCustomerId() { return customerId; }
    public Money getBalance() { return balance; }
    public AccountStatus getStatus() { return status; }
    public List<Transaction> getTransactions() { return List.copyOf(transactions); }
    public Long getVersion() { return version; }
}

// ❌ BAD: Anemic domain model
public class Account {
    private String id;
    private BigDecimal balance;
    
    // Only getters/setters, no behavior
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }
}
```

## Functional Programming Patterns

### Optional Usage
```java
// ✅ GOOD: Proper Optional usage
public Optional<Account> findAccount(String id) {
    return Optional.ofNullable(accountMap.get(id));
}

public Money getAccountBalance(String accountId) {
    return findAccount(accountId)
        .map(Account::getBalance)
        .orElse(Money.ZERO);
}

public void processAccount(String accountId) {
    findAccount(accountId).ifPresentOrElse(
        account -> log.info("Found account: {}", account.getId()),
        () -> log.warn("Account not found: {}", accountId)
    );
}

// ❌ BAD: Misusing Optional
public Optional<Account> createAccount() {
    return Optional.of(new Account()); // ❌ Never Optional for creation
}

Optional<Account> account = findAccount(id);
if (account.isPresent()) {           // ❌ Use ifPresent() instead
    Account acc = account.get();
}
```

### Streams API
```java
// ✅ GOOD: Functional data processing
public BigDecimal calculateTotalBalance(List<Account> accounts) {
    return accounts.stream()
        .filter(Account::isActive)
        .map(Account::getBalance)
        .map(Money::amount)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}

public List<Account> getHighValueAccounts(List<Account> accounts, BigDecimal threshold) {
    return accounts.stream()
        .filter(account -> account.getBalance().isGreaterThan(new Money(threshold, USD)))
        .sorted(Comparator.comparing(Account::getBalance).reversed())
        .toList();
}

// ✅ GOOD: Collectors for complex aggregations
public Map<AccountStatus, Long> getAccountCountByStatus(List<Account> accounts) {
    return accounts.stream()
        .collect(Collectors.groupingBy(
            Account::getStatus,
            Collectors.counting()
        ));
}
```

### Immutability
```java
// ✅ GOOD: Immutable by default
public record Transaction(
    String id,
    String accountId,
    Money amount,
    TransactionType type,
    Instant timestamp
) {
    public Transaction {
        Objects.requireNonNull(id);
        Objects.requireNonNull(accountId);
        Objects.requireNonNull(amount);
        Objects.requireNonNull(type);
        Objects.requireNonNull(timestamp);
    }
}

// ✅ GOOD: Defensive copying
public class Account {
    private final List<Transaction> transactions;
    
    public Account(List<Transaction> transactions) {
        this.transactions = new ArrayList<>(transactions); // Defensive copy
    }
    
    public List<Transaction> getTransactions() {
        return List.copyOf(transactions); // Immutable view
    }
}
```

## Exception Handling

### Custom Exceptions
```java
// ✅ GOOD: Specific, informative exceptions
public class InsufficientFundsException extends RuntimeException {
    private final Money available;
    private final Money required;
    
    public InsufficientFundsException(Money available, Money required) {
        super(String.format("Insufficient funds: available=%s, required=%s", 
            available, required));
        this.available = available;
        this.required = required;
    }
    
    public Money getAvailable() { return available; }
    public Money getRequired() { return required; }
}

public class AccountNotFoundException extends RuntimeException {
    private final String accountId;
    
    public AccountNotFoundException(String accountId) {
        super("Account not found: " + accountId);
        this.accountId = accountId;
    }
    
    public String getAccountId() { return accountId; }
}
```

### Exception Best Practices
```java
// ✅ GOOD: Specific exception handling
public Account getAccount(String accountId) {
    Objects.requireNonNull(accountId, "Account ID cannot be null");
    
    return repository.findById(accountId)
        .orElseThrow(() -> new AccountNotFoundException(accountId));
}

// ✅ GOOD: Don't swallow exceptions
public void processTransaction(Transaction transaction) {
    try {
        validate(transaction);
        execute(transaction);
    } catch (ValidationException e) {
        log.error("Validation failed for transaction: {}", transaction.getId(), e);
        throw new TransactionException("Transaction validation failed", e);
    }
}

// ❌ BAD: Swallowing exceptions
try {
    processTransaction(transaction);
} catch (Exception e) {
    // ❌ Silent failure!
}

// ❌ BAD: Catching too broad
try {
    processTransaction(transaction);
} catch (Exception e) { // ❌ Too broad!
    log.error("Error", e);
}
```

## Performance Best Practices

### String Operations
```java
// ✅ GOOD: StringBuilder for concatenation in loops
public String buildTransactionReport(List<Transaction> transactions) {
    StringBuilder sb = new StringBuilder();
    for (Transaction t : transactions) {
        sb.append("ID: ").append(t.id())
          .append(", Amount: ").append(t.amount())
          .append("\n");
    }
    return sb.toString();
}

// ❌ BAD: String concatenation in loop
String report = "";
for (Transaction t : transactions) {
    report += "ID: " + t.id() + ", Amount: " + t.amount() + "\n"; // ❌ Creates new String each iteration
}
```

### Collections
```java
// ✅ GOOD: Right collection, right capacity
List<String> ids = new ArrayList<>(1000);  // Known size
Map<String, Account> cache = new HashMap<>(1000);
Set<String> uniqueIds = new HashSet<>(1000);

// ✅ GOOD: Use primitive streams to avoid boxing
int sum = IntStream.range(0, 1000)
    .filter(n -> n % 2 == 0)
    .sum();

// ❌ BAD: Boxing overhead
int sum = Stream.iterate(0, n -> n + 1)
    .limit(1000)
    .filter(n -> n % 2 == 0)
    .mapToInt(Integer::intValue)
    .sum();
```

## Code Quality Checklist

Before committing pure Java code:
- [ ] Using Java 17+ features appropriately
- [ ] All classes follow Single Responsibility Principle
- [ ] Using records for immutable data
- [ ] Value objects for domain concepts
- [ ] No primitive obsession (using value objects)
- [ ] Proper null handling (Optional, Objects.requireNonNull)
- [ ] No resource leaks (try-with-resources)
- [ ] Meaningful names (classes, methods, variables)
- [ ] Immutability by default
- [ ] Proper exception handling
- [ ] No code smells (god classes, long methods, etc.)

---

**Pure Java, Clean Code, Production Ready** ☕
