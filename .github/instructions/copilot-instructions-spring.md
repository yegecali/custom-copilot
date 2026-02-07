# GitHub Copilot Instructions - Spring Boot

> **Spring Boot Specific**: Use alongside `copilot-instructions-java.md` for pure Java standards.
> These instructions apply ONLY to Spring Boot projects.

## Spring Boot Version
- **Minimum**: Spring Boot 3.2.x
- **Spring Framework**: 6.1.x+
- **Java**: 17+ (Required for Spring Boot 3.x)

## Dependency Injection

### Constructor Injection (MANDATORY)
```java
// ✅ PERFECT: Constructor injection with final fields
@Service
public class TransactionService {
    private final TransactionRepository repository;
    private final EventPublisher eventPublisher;
    private final TransactionValidator validator;
    
    public TransactionService(
            TransactionRepository repository,
            EventPublisher eventPublisher,
            TransactionValidator validator) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
        this.validator = validator;
    }
}

// ❌ BAD: Field injection
@Service
public class TransactionService {
    @Autowired // ❌ Field injection
    private TransactionRepository repository;
    
    @Autowired // ❌ Not testable
    private EventPublisher eventPublisher;
}

// ❌ BAD: Setter injection
@Service
public class TransactionService {
    private TransactionRepository repository;
    
    @Autowired
    public void setRepository(TransactionRepository repository) { // ❌ Mutable
        this.repository = repository;
    }
}
```

## REST Controllers

### Controller Design
```java
// ✅ PERFECT: Clean REST controller
@RestController
@RequestMapping("/api/v1/accounts")
@Validated
public class AccountController {
    private final AccountService accountService;
    
    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<AccountDto> createAccount(
            @Valid @RequestBody CreateAccountRequest request) {
        
        AccountDto account = accountService.createAccount(request);
        
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(account.accountId())
            .toUri();
        
        return ResponseEntity.created(location).body(account);
    }
    
    @GetMapping("/{accountId}")
    public ResponseEntity<AccountDto> getAccount(
            @PathVariable @NotBlank String accountId) {
        
        return accountService.findById(accountId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{accountId}")
    public ResponseEntity<AccountDto> updateAccount(
            @PathVariable @NotBlank String accountId,
            @Valid @RequestBody UpdateAccountRequest request) {
        
        AccountDto updated = accountService.update(accountId, request);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{accountId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ResponseEntity<Void> deleteAccount(@PathVariable @NotBlank String accountId) {
        accountService.delete(accountId);
        return ResponseEntity.noContent().build();
    }
}

// ❌ BAD: Mixing business logic in controller
@RestController
public class AccountController {
    
    @Autowired
    private AccountRepository repository; // ❌ Repository in controller!
    
    @PostMapping("/accounts")
    public Account create(@RequestBody Account account) { // ❌ Exposing entity
        // ❌ Business logic in controller
        if (account.getBalance().compareTo(BigDecimal.ZERO) < 0) {
            throw new RuntimeException("Invalid balance");
        }
        return repository.save(account);
    }
}
```

### Exception Handling
```java
// ✅ PERFECT: Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    @ExceptionHandler(AccountNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleAccountNotFound(AccountNotFoundException ex) {
        log.warn("Account not found: {}", ex.getAccountId());
        
        return new ErrorResponse(
            "ACCOUNT_NOT_FOUND",
            ex.getMessage(),
            Instant.now(),
            List.of()
        );
    }
    
    @ExceptionHandler(InsufficientFundsException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ErrorResponse handleInsufficientFunds(InsufficientFundsException ex) {
        log.warn("Insufficient funds: available={}, required={}", 
            ex.getAvailable(), ex.getRequired());
        
        return new ErrorResponse(
            "INSUFFICIENT_FUNDS",
            ex.getMessage(),
            Instant.now(),
            List.of()
        );
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidationErrors(MethodArgumentNotValidException ex) {
        List<FieldError> fieldErrors = ex.getBindingResult().getFieldErrors().stream()
            .map(error -> new FieldError(error.getField(), error.getDefaultMessage()))
            .toList();
        
        return new ErrorResponse(
            "VALIDATION_ERROR",
            "Validation failed",
            Instant.now(),
            fieldErrors
        );
    }
    
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleUnexpectedError(Exception ex) {
        log.error("Unexpected error occurred", ex);
        
        // Don't expose internal details to client
        return new ErrorResponse(
            "INTERNAL_ERROR",
            "An unexpected error occurred",
            Instant.now(),
            List.of()
        );
    }
}

public record ErrorResponse(
    String code,
    String message,
    Instant timestamp,
    List<FieldError> fieldErrors
) {
    public record FieldError(String field, String message) {}
}
```

## Validation

### Bean Validation
```java
// ✅ PERFECT: Comprehensive validation
public record CreateAccountRequest(
    @NotBlank(message = "Customer ID is required")
    @Size(min = 5, max = 50, message = "Customer ID must be between 5 and 50 characters")
    String customerId,
    
    @NotNull(message = "Initial balance is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Initial balance must be non-negative")
    @Digits(integer = 10, fraction = 2, message = "Invalid balance format")
    BigDecimal initialBalance,
    
    @NotNull(message = "Account type is required")
    AccountType accountType,
    
    @Valid
    @NotNull(message = "Address is required")
    Address address
) {}

public record Address(
    @NotBlank(message = "Street is required")
    String street,
    
    @NotBlank(message = "City is required")
    String city,
    
    @NotBlank(message = "State is required")
    @Size(min = 2, max = 2, message = "State must be 2 characters")
    String state,
    
    @NotBlank(message = "ZIP code is required")
    @Pattern(regexp = "\\d{5}(-\\d{4})?", message = "Invalid ZIP code format")
    String zipCode
) {}
```

### Custom Validators
```java
// ✅ PERFECT: Custom validation annotation
@Documented
@Constraint(validatedBy = ValidAccountNumberValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidAccountNumber {
    String message() default "Invalid account number";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

public class ValidAccountNumberValidator 
        implements ConstraintValidator<ValidAccountNumber, String> {
    
    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return true; // Use @NotNull for null checks
        }
        
        // Validate format
        if (!value.matches("\\d{10}")) {
            return false;
        }
        
        // Validate checksum (Luhn algorithm)
        return isValidChecksum(value);
    }
    
    private boolean isValidChecksum(String accountNumber) {
        // Luhn algorithm implementation
        return true;
    }
}

// Usage
public record AccountRequest(
    @NotBlank
    @ValidAccountNumber
    String accountNumber
) {}
```

## Data Access (Spring Data JPA)

### Repository Pattern
```java
// ✅ PERFECT: Repository interface
public interface AccountRepository extends JpaRepository<Account, String> {
    
    @Query("SELECT a FROM Account a WHERE a.customerId = :customerId AND a.status = 'ACTIVE'")
    List<Account> findActiveAccountsByCustomerId(@Param("customerId") String customerId);
    
    @Query("SELECT a FROM Account a JOIN FETCH a.transactions WHERE a.id = :id")
    Optional<Account> findByIdWithTransactions(@Param("id") String id);
    
    @Modifying
    @Query("UPDATE Account a SET a.status = 'CLOSED' WHERE a.id = :id")
    int closeAccount(@Param("id") String id);
    
    boolean existsByCustomerIdAndStatus(String customerId, AccountStatus status);
}
```

### Entity Design
```java
// ✅ PERFECT: JPA entity with proper annotations
@Entity
@Table(name = "accounts", indexes = {
    @Index(name = "idx_customer_id", columnList = "customer_id"),
    @Index(name = "idx_status", columnList = "status")
})
public class Account {
    
    @Id
    @Column(name = "account_id", length = 50)
    private String id;
    
    @Column(name = "customer_id", nullable = false, length = 50)
    private String customerId;
    
    @Column(name = "balance", nullable = false, precision = 19, scale = 2)
    private BigDecimal balance;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private AccountStatus status;
    
    @OneToMany(mappedBy = "account", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Transaction> transactions = new ArrayList<>();
    
    @Version
    @Column(name = "version")
    private Long version;
    
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
    
    // Constructors, getters, business methods
}
```

## Configuration

### Application Properties
```yaml
# application.yml
spring:
  application:
    name: account-service
  
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
        jdbc:
          batch_size: 20
    show-sql: false
  
  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false
  
server:
  port: 8080
  shutdown: graceful
  
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
  
logging:
  level:
    root: INFO
    com.bank: DEBUG
```

### Configuration Classes
```java
// ✅ PERFECT: Configuration class
@Configuration
public class ApplicationConfig {
    
    @Bean
    public ObjectMapper objectMapper() {
        return JsonMapper.builder()
            .addModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            .build();
    }
    
    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
            .setConnectTimeout(Duration.ofSeconds(10))
            .setReadTimeout(Duration.ofSeconds(30))
            .build();
    }
    
    @Bean
    public AsyncTaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(50);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

## Reactive Spring (WebFlux)

### Reactive Controller
```java
// ✅ PERFECT: WebFlux reactive controller
@RestController
@RequestMapping("/api/v1/accounts")
public class ReactiveAccountController {
    private final AccountService accountService;
    
    public ReactiveAccountController(AccountService accountService) {
        this.accountService = accountService;
    }
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<AccountDto> createAccount(@Valid @RequestBody CreateAccountRequest request) {
        return accountService.createAccount(request);
    }
    
    @GetMapping("/{accountId}")
    public Mono<ResponseEntity<AccountDto>> getAccount(@PathVariable String accountId) {
        return accountService.findById(accountId)
            .map(ResponseEntity::ok)
            .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping
    public Flux<AccountDto> getAllAccounts(@RequestParam(required = false) String customerId) {
        if (customerId != null) {
            return accountService.findByCustomerId(customerId);
        }
        return accountService.findAll();
    }
}
```

### Reactive Repository (R2DBC)
```java
// ✅ PERFECT: R2DBC repository
public interface ReactiveAccountRepository extends ReactiveCrudRepository<Account, String> {
    
    @Query("SELECT * FROM accounts WHERE customer_id = :customerId")
    Flux<Account> findByCustomerId(String customerId);
    
    @Query("SELECT * FROM accounts WHERE status = :status")
    Flux<Account> findByStatus(AccountStatus status);
    
    @Modifying
    @Query("UPDATE accounts SET balance = :balance, version = version + 1 " +
           "WHERE id = :id AND version = :version")
    Mono<Integer> updateBalanceWithOptimisticLock(
        String id, 
        BigDecimal balance, 
        Long version
    );
}
```

### Reactive Service
```java
// ✅ PERFECT: Reactive service
@Service
public class ReactiveAccountService {
    private final ReactiveAccountRepository repository;
    private final EventPublisher eventPublisher;
    
    public ReactiveAccountService(
            ReactiveAccountRepository repository,
            EventPublisher eventPublisher) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
    }
    
    public Mono<AccountDto> createAccount(CreateAccountRequest request) {
        return Mono.defer(() -> {
            Account account = new Account(
                UUID.randomUUID().toString(),
                request.customerId(),
                request.initialBalance()
            );
            
            return repository.save(account)
                .flatMap(saved -> publishEvent(saved).thenReturn(saved))
                .map(this::toDto)
                .timeout(Duration.ofSeconds(30))
                .retry(3)
                .onErrorMap(TimeoutException.class, 
                    e -> new ServiceUnavailableException("Account creation timeout"));
        });
    }
    
    public Mono<AccountDto> findById(String id) {
        return repository.findById(id)
            .map(this::toDto)
            .switchIfEmpty(Mono.error(new AccountNotFoundException(id)));
    }
    
    private Mono<Void> publishEvent(Account account) {
        AccountCreatedEvent event = new AccountCreatedEvent(
            account.getId(),
            account.getCustomerId(),
            Instant.now()
        );
        return eventPublisher.publish(event);
    }
    
    private AccountDto toDto(Account account) {
        return new AccountDto(
            account.getId(),
            account.getCustomerId(),
            account.getBalance()
        );
    }
}
```

## Transaction Management

### Declarative Transactions
```java
// ✅ PERFECT: Service with transactions
@Service
public class TransactionService {
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    
    @Transactional
    public TransactionResult transfer(String fromAccountId, String toAccountId, Money amount) {
        Account fromAccount = accountRepository.findById(fromAccountId)
            .orElseThrow(() -> new AccountNotFoundException(fromAccountId));
        
        Account toAccount = accountRepository.findById(toAccountId)
            .orElseThrow(() -> new AccountNotFoundException(toAccountId));
        
        fromAccount.withdraw(amount);
        toAccount.deposit(amount);
        
        accountRepository.save(fromAccount);
        accountRepository.save(toAccount);
        
        Transaction transaction = new Transaction(
            UUID.randomUUID().toString(),
            fromAccountId,
            toAccountId,
            amount,
            TransactionType.TRANSFER
        );
        
        transactionRepository.save(transaction);
        
        return new TransactionResult(transaction.getId(), TransactionStatus.COMPLETED);
    }
    
    @Transactional(readOnly = true)
    public List<Transaction> getTransactionHistory(String accountId) {
        return transactionRepository.findByAccountIdOrderByTimestampDesc(accountId);
    }
}
```

## Spring Boot Best Practices Checklist

- [ ] Constructor injection for all dependencies
- [ ] @Validated on controllers
- [ ] @Valid on request bodies
- [ ] Global exception handler with @RestControllerAdvice
- [ ] Proper HTTP status codes
- [ ] DTOs for API layer (don't expose entities)
- [ ] @Transactional on service methods (not repositories)
- [ ] readOnly = true for read-only transactions
- [ ] Externalized configuration (no hardcoded values)
- [ ] Actuator endpoints enabled
- [ ] Connection pooling configured
- [ ] Proper logging configuration

---

**Spring Boot 3.x - Modern, Reactive, Production Ready** 🍃
